%INTBDR Integrate expression on boundaries.
%
%   [ VAL ] = INTBDR( S_EXPR, PROB, IND_B, I_CUB, SOLNUM, IND_S )
%   Integrates the expression S_EXPR on boundaries, using FEM
%   interpolation of data given in the FEA model/problem struct PROB.
%
%   The string expression S_EXPR must be valid MATLAB syntax, and may
%   include combinations of dependent variables (defined in PROB.dvar)
%   and derivatives, space dimensions (PROB.sdim), and all common
%   built-in constants and mathematical functions available, such as
%   pi, eps, sqrt, sin, cos, log, exp, abs etc (for example
%   "sin(2*pi*x + ux^2)" where "ux" is the x-derivative of the
%   dependent variable "u").
%
%   The optional vector IND_B are indices to boundaries to include in
%   the evaluation (default all "unique(PROB.grid.b(3,:))").
%
%   SOLNUM is an optional scalar integer indicating the solution/time
%   to use in the evaluation (PROB.sol.u(:,SOLNUM), defaults to the
%   last available solution "size(PROB.sol.u, 2)").
%
%   IND_S optionally specifies which subdomains to use as reference for
%   internal/interior boundaries (normals point outward from these subdomains).
%
%   Returns the integration result VAL.
%
%       Input       Value/[Size]           Description
%       -----------------------------------------------------------------------------------
%       s_expr      string                 Expression to integrate
%       prob        struct                 FEA model/problem definition struct
%       ind_b       [1,n_bdr]              Boundary numbers (default all)
%       i_cub       scalar int             Evaluation point rule/quadrature order (default 2)
%       solnum      scalar int {n_sols}    Solution number/time to evaluate
%       ind_s       integer array          Integration subdomains for internal boundaries
%                                                                                         .
%       Output      Value/[Size]           Description
%       -----------------------------------------------------------------------------------
%       val         scalar                 Result of integration
%
%
%   Examples:
%
%      1) Integrate "1" (= circumference) around a unit circle.
%
%      fea = ex_poisson2('iplot', false);  % Use example script to generate FEA data struct.
%
%      circ = intbdr('1', fea)
%
%      2) Integrate "sqrt(ux^2 + uy^2)" for the Poisson equation on boundary 2 of a unit circle.
%
%      fea = ex_poisson2('iplot', false);
%
%      mag_u_b2 = intsubd('sqrt(ux^2 + uy^2)', fea, 2)
%
%   See also INTSUBD, MINMAXBDR, MINMAXSUBD

% Copyright 2013-2026 Precise Simulation, Ltd.