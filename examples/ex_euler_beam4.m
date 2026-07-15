function [ fea, out ] = ex_euler_beam4( varargin )
%EX_EULER_BEAM4 1D Euler-Bernoulli beam model example.
%
%   [ FEA, OUT ] = EX_EULER_BEAM4( VARARGIN ) 1D Euler-Bernoulli beam model example,
%   simply supported cantilever beam central point load. Accepts the
%   following property/value pairs.
%
%       Input       Value/{Default}        Description
%       -----------------------------------------------------------------------------------
%       L           scalar {2}             Beam length
%       E           scalar {3}             Elastic modulus
%       I           expression {4}         Cross section moment of intertia
%       q           expression {-5}        Point load
%       nx          scalar {40}            Number of grid cells
%       iplot       scalar 0/{1}           Plot solution (=1)
%                                                                                         .
%       Output      Value/(Size)           Description
%       -----------------------------------------------------------------------------------
%       fea         struct                 Problem definition struct
%       out         struct                 Output struct

% Copyright 2013-2026 Precise Simulation, Ltd.


cOptDef = { 'L',        2;
            'E',        3;
            'I',        4;
            'q',       -5;
            'nx'        40;
            'iplot',    1;
            'tol',      1e-2;
            'fid',      1 };
[got,opt] = parseopt( cOptDef, varargin{:} );
fid       = opt.fid;


% Geometry definition
fea.sdim = {'x'};
fea.geom.objects = {gobj_line([0; opt.L/2], 'L1'), ...
                    gobj_line([opt.L/2; opt.L], 'L2')};


% Grid generation.
fea.grid = gridgen(fea, 'gridgen', 'line', 'hmax', opt.L/opt.nx, 'fid', fid);


% Problem and equation definitions.
fea = addphys( fea, @eulerbeam );
fea.phys.eb.eqn.coef = { 'rho_eb', 'rho', 'Density',                          { 1 };
                         'A_eb',     'A', 'Cross section area',               { 1 };
                         'E_eb',     'E', 'Modulus of elasticity',            { opt.E };
                         'I_eb',     'I', 'Cross section moment of intertia', { opt.I };
                         'q_eb',     'q', 'Distributed load/force',           { 0 };
                         'v0_eb',   'v0', 'Initial condition for v',          { 0 } };

% Parse problem.
fea = parsephys( fea );
fea = parseprob( fea );


% Coefficients and equation/postprocessing expressions.
fea.expr = { 'L',  opt.L ;
             'M',  fea.phys.eb.eqn.vars{3,2} ;
             'P',  opt.q ;
             'v_ref', 'P*x*(3*L^2/4-x^2)/(12*E_eb*I_eb)' };


% Boundary conditions (boundary numbering 1 --- 3 --- 2)

% Dirichlet
fea.bdr.d = {{  0,  0, [] ;    % v (displacement)constraint
               [], [], [] }};  % dv/dx constraint

% Neumann (applied if corresponding Dirichlet value is not set, empty [])
fea.bdr.n = {{ [], [], opt.q ;   % y load
                0,  0,     0 }};  % momentum load


% Solve problem.
fea.sol.u = solvestat( fea, 'icub', 3, 'fid', opt.fid );


% Postprocessing.
x_ref = linspace(0, opt.L/2, 1.5*opt.nx);
if( opt.iplot )
  postplot( fea, 'surfexpr', 'v', 'linewidth', 2 )
  v_ref = evalexpr( 'v_ref', x_ref, fea );
  plot( x_ref, v_ref, 'color', 'r', 'linestyle', ':', 'linewidth', 2 )
  title( 'v(x)' )
  axis normal, grid on
end


% Error checking.
err_v = evalexpr( 'abs(v-v_ref)', x_ref, fea );
err = norm(err_v);


out.err  = err;
out.pass = out.err<opt.tol;
if ( nargout==0 )
  clear fea out
end
