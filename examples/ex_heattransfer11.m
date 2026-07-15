function [ fea, out ] = ex_heattransfer11( varargin )
%EX_HEATTRANSFER11 Design optimization for cooling with target temperature.
%
%   [ FEA, OUT ] = EX_HEATTRANSFER11( VARARGIN ) Heat transfer example
%   for cooling of a heated block using cooling pipes. An optimization
%   problem is defined and set up to reach (but not exceed) a target
%   temperature, Tstar, with n=1-9 number of cooling pipes with variable
%   diameter, D = 5-18 mm.
%
%       +--------------------------------+
%       |        Heated Top Block        |
%       +--------------------------------+   T(x,n,D) <= Tstar
%       |  Cooling Plate with n x Pipes  |
%       |    (D)  ( )  ( )  ( )  ( )     |
%       +--------------------------------+
%
%   Accepts the following property/value pairs.
%
%       Input       Value/{Default}        Description
%       -----------------------------------------------------------------------------------
%       npipes      array {[1, 9]}         Minimum and maximum number of pipes
%       diam        array {[0.005, 0.018]} Minimum and maximum pipe diameter
%       Tstar       scalar {358.15}        Target temperature [K]
%       iplot       scalar 0/{1}           Plot solution and error (=1)
%                                                                                         .
%       Output      Value/(Size)           Description
%       -----------------------------------------------------------------------------------
%       fea         struct                 Problem definition struct
%       out         struct                 Output struct
%
%   See also FMINBND

% Copyright 2013-2026 Precise Simulation, Ltd.

cOptDef = { 'npipes',   [1, 9];
            'diam',     [0.005, 0.019];
            'Tstar',    358.15;
            'iplot',    1;
            'tol',      0.1;
            'fid',      1 };
[got,opt] = parseopt( cOptDef, varargin{:} );

feaCache = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );  % Handle (in-place) cache.


% Outer loop: evaluate all integer n (starting D from previous result).
if( ~isempty(opt.fid) )
  fprintf(opt.fid, '%-4s %-10s %-12s %-12s %-10s\n', 'n', 'D (m)', 'Tmax (K)', 'Cost', 'FEA calls');
  fprintf(opt.fid, '%s\n', repmat('-', 1, 51));
end

penaltyWeight = 1e4;
D0 = (opt.diam(1) + opt.diam(2)) / 2;
nValues = opt.npipes(1):opt.npipes(2);
res = struct('n', {}, 'D', {}, 'cost', {}, 'ff', {});

for it = 1:length(nValues)
  n = nValues(it);
  [Dopt, cost, ff] = innerOpt(n, opt.Tstar, opt.diam(1), opt.diam(2), penaltyWeight, D0, feaCache);
  res(it) = struct('n', n, 'D', Dopt, 'cost', cost, 'ff', ff);
  D0 = Dopt;   % Warm start next n.


  if( ~isempty(opt.fid) )
    fprintf(opt.fid, '%-4d %-10.4f %-12.2f %-12.4f %-10d\n', ...
            n, Dopt, opt.Tstar+ff.Ineq, cost, feaCache.Count);
  end
end


% Select best feasible result.
costs    = [res.cost];
[~, idx] = min(costs);
best     = res(idx);
Tmax     = opt.Tstar + best.ff.Ineq;

if( ~isempty(opt.fid) )
  fprintf(opt.fid, '\n--- Optimal solution ---\n');
  fprintf(opt.fid, 'Number of pipes : %d\n', best.n);
  fprintf(opt.fid, 'Pipe diameter   : %.4f m\n', best.D);
  fprintf(opt.fid, 'Max temperature : %.2f K (%.2f C)\n', Tmax, Tmax - 273.15);
  fprintf(opt.fid, 'Objective value : %.4f K\n',  best.ff.Fval);
  yn = 'No'; if( ff.Ineq <= 0 ), yn = 'Yes'; end
  fprintf(opt.fid, 'Feasible        : %s\n', yn);
  fprintf(opt.fid, 'Total FEA calls : %d\n', feaCache.Count);
end

[~,fea] = l_run_fea_optimization_problem([best.n; best.D], opt.Tstar);


% Error checking.
out.err = abs(opt.Tstar - Tmax);
out.pass = out.err < opt.tol;


% Postprocessing.
if( opt.iplot )
  postplot( fea, 'surfexpr', 'T' )

  % Mirror solution.
  fea_mirror = fea;
  fea_mirror.geom = l_block_cooling_geometry( best.n, best.D, 3 );  % 3D geometry for plotting.
  fea_mirror.grid.p(1,:) = 0.2 - fea_mirror.grid.p(1,:);  % Offset and mirror grid points.
  postplot( fea_mirror, 'surfexpr', 'T' )

  title(sprintf('Optimal solution: n=%d pipes, D=%.4f m | T_{max}=%.2f K', ...
                best.n, best.D, Tmax));
end


if( ~nargout )
  clear fea out
end


%------------------------------------------------------------------------------%
function [ ff ] = cachedFEA( n, D, Tstar, cache )
% Global FEA problem struct cache.

key = sprintf('%d_%.8f', n, D);

if( isKey(cache, key) )
  ff = cache(key);
else
  ff = l_run_fea_optimization_problem([n; D], Tstar);
  cache(key) = ff;
end

%------------------------------------------------------------------------------%
function [ Dopt, cost, ff ] = innerOpt( n, Tstar, Dmin, Dmax, penaltyWeight, D0, cache )
% Inner optimisation: fminbnd over D for fixed n.

f = @(D) penObj(D, n, Tstar, penaltyWeight, cache);

% Warm-start: shrink bracket around previous n's optimal D.
bracketHalf = (Dmax - Dmin) * 0.3;
a = max(Dmin, D0 - bracketHalf);
b = min(Dmax, D0 + bracketHalf);

opts = optimset('TolX', 1e-4, 'Display', 'off');
[Dopt, cost] = fminbnd( f, a, b, opts );
ff = cachedFEA( n, Dopt, Tstar, cache );

% Fallback: if warm-start bracket missed the minimum, search full range.
if( ff.Ineq > 1e-2 )
  [Dopt2, cost2] = fminbnd( f, Dmin, Dmax, opts );
  if( cost2 < cost )
    Dopt = Dopt2;
    cost = cost2;
    ff = cachedFEA( n, Dopt, Tstar, cache );
  end
end

%------------------------------------------------------------------------------%
function [ cost ] = penObj( D, n, Tstar, penaltyWeight, cache )
% Penalised objective.

ff = cachedFEA(n, D, Tstar, cache);
cost = ff.Fval + penaltyWeight * max(0, ff.Ineq);

%------------------------------------------------------------------------------%
function [ ff, fea ] = l_run_fea_optimization_problem( v, T )

fea = l_define_fea_problem( v(1), v(2) );

% Parse and solve FEA problem.
fea = parsephys( fea );
fea = parseprob( fea );

fea.sol.u = solvestat( fea, 'fid', [] );

% Find highest temperature.
[~, Tmax] = minmaxsubd( 'T', fea );

% Evaluate objective.
ff.Fval = abs(T - Tmax);

% Evaluate constraints.
ff.Ineq = Tmax - T;

%------------------------------------------------------------------------------%
function [ fea ] = l_define_fea_problem( n_pipes, diameter )

fea.sdim = {'x', 'y', 'z'};

% Geometry and grid.
[fea.grid, pipe_boundaries, external_boundaries, symmetry_boundaries] = l_block_cooling_mesh( n_pipes, diameter );


% Heat transfer physics mode.
fea = addphys(fea, @heattransfer);


% Specify equation coefficients.

% Thermal conductivity (k_ht = coef{3,:}) of the top block that produces heat (subdomain 1).
fea.phys.ht.eqn.coef{3,end}{1} = 80;

% Thermal conductivity (k_ht = coef{3,:}) of the cooling plate (subdomain 2).
fea.phys.ht.eqn.coef{3,end}{2} = 0.5;

% Heat source (q_ht = coef{7,:}) in the top block (subdomain 1).
powerW = 0.5e3;
l = 0.4; w = 0.2; h = 0.02;
volume = w * l * h;
q_ht = powerW / volume;
fea.phys.ht.eqn.coef{7,end}{1} = q_ht;


% Specify boundary conditions.

% Natural convection (bc_type = 4) for external faces of the top block and cooling plate.
c_ht = 20;
T_ambient = 298.15;
fea.phys.ht.bdr.sel(external_boundaries) = 4;
[fea.phys.ht.bdr.coef{4,end}{external_boundaries}] = deal({0, c_ht, T_ambient, 0, 0});

% Forced convection (bc_type = 4) pipe faces.
fea.phys.ht.bdr.sel(pipe_boundaries) = 4;

% Compute heat transfer coefficient for convective boundary condition.
m_flow = 0.02;  % Mass flow rate [kg/s].
miu = 0.001002;  % Dynamic viscosity of water at 293.15 K [kg/(m*s)].
Re = (4 * m_flow)/(pi * diameter * miu);  % Reynolds number.
Pr = 7.2;  % Prandtl number of water at 293.15 K.
if( Re >= 10000 )
  Nu = 0.023 * Re^0.8 * Pr^0.4;  % Nusselt number, use Dittus-Boelter equation for high Re.
else
  Nu = 3.66;  % else Assume Nu constant.
end
k = 0.598;  % Thermal conductivity of water at 293.15 K [W/(m*K)].
c_ht = (Nu * k) / diameter;  % Heat transfer coefficient.
T_ambient = 278.15;

[fea.phys.ht.bdr.coef{4,end}{pipe_boundaries}] = deal({0, c_ht, T_ambient, 0, 0});

% Symmetry boundaries (bc_type = 3).
fea.phys.ht.bdr.sel(symmetry_boundaries) = 3;

%------------------------------------------------------------------------------%
function [ grid, pipe_boundaries, external_boundaries, symmetry_boundaries ] = l_block_cooling_mesh( n_pipes, diameter )
% Generate 2D grid, and extrude to 3D.

geom2 = l_block_cooling_geometry( n_pipes, diameter, 2 );

grid2 = gridgen( geom2, 'hmax', 0.0025, 'fid', [] );

l = 0.4;
grid = gridextrude( grid2, 20, l, -2 );

% Subdomain 1 (top), subdomain 2 (bottom cooling block).
if( n_pipes == 1 )
  pipe_boundaries = [6, 7];
  external_boundaries = [2:4, 9, 10:13];
  symmetry_boundaries = [1, 5, 8];

elseif( mod(n_pipes,2) == 0 )  % even: no pipe in symmetry plane
  pipe_boundaries = 6 + (1:4*n_pipes/2);
  external_boundaries = [2:4, 6, pipe_boundaries(end) + (1:4)];
  symmetry_boundaries = [1, 5];

else  % odd: pipe in symmetry plane
  pipe_boundaries = [6, 7, 9 + (1:4*floor(n_pipes/2))];
  external_boundaries = [2:4, 9, pipe_boundaries(end) + (1:4)];
  symmetry_boundaries = [1, 5, 8];
end

%------------------------------------------------------------------------------%
function [ geom ] = l_block_cooling_geometry( n_pipes, diameter, dim )
% Generate geometry (full 3D or 2D slice).

w = 0.2;   % width
h = 0.02;  % height
l = 0.4;   % length

persistent top block dim0
if( isempty(top) || ~isequal(dim,dim0) )
  if( dim == 2 )
    top = gobj_rectangle( 0, w/2, h, 2*h, 'TOP_PLATE' );
    block = gobj_rectangle( 0, w/2, 0, h, 'COOLING_BLOCK' );
  else
    top = gobj_block( 0, w, 0, -l, h, 2*h, 'TOP_PLATE' );
    block = gobj_block( 0, w, 0, -l, 0, h, 'COOLING_BLOCK' );
  end
  dim0 = dim;
end

geom.objects = {top, block};

edge_gap = 1.1 * diameter/2;
formula = 'COOLING_BLOCK';
if( n_pipes == 1 )
  xc = w/2;
else
  xc = linspace( edge_gap, w - edge_gap, n_pipes );
end

for i=1:n_pipes
  tag_i = sprintf('C%d', i);
  if( dim == 2 )
    C_i = gobj_circle( [xc(i), h/2], diameter/2, tag_i );
  else
    C_i = gobj_cylinder( [xc(i), 0, h/2], diameter/2, -l, [0, 1, 0], tag_i );
  end

  geom.objects = [geom.objects, {C_i}];
  formula = [formula, ' - ', tag_i];
  if( dim == 2 && i == ceil(n_pipes/2) )
    break
  end
end

geom = geom_apply_formula( geom, formula );
