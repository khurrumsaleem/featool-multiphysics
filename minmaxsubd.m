%MINMAXSUBD Calculate minima and maxima of an expression in subdomains.
%
%   [ MIN_VAL, MAX_VAL, MIN_COORD, MAX_COORD ] = MINMAXSUBD( S_EXPR, PROB, IND_S, IND_C, I_CUB, SOLNUM )
%   Evaluates the mimimum and maximum value of expression S_EXPR in
%   subdomains, using FEM interpolation of data given in the FEA
%   model/problem struct PROB.
%
%   The string expression S_EXPR must be valid MATLAB syntax, and may
%   include combinations of dependent variables (defined in PROB.dvar)
%   and derivatives, space dimensions (PROB.sdim), and all common
%   built-in constants and mathematical functions available, such as
%   pi, eps, sqrt, sin, cos, log, exp, abs etc (for example
%   "sin(2*pi*x + ux^2)" where "ux" is the x-derivative of the
%   dependent variable "u").
%
%   The optional vector IND_S are indices to subdomains to include in
%   the evaluation (default all, "unique(PROB.grid.s)"), or
%   alternatively IND_C can be provided with indices to specific
%   grid/mesh cells to perform evaluation in (default all, "1:size(PROB.grid.c, 2)").
%
%   SOLNUM is an optional scalar integer indicating the solution/time
%   to use in the evaluation (PROB.sol.u(:,SOLNUM), defaults to the
%   last available solution "size(PROB.sol.u, 2)").
%
%   Returns the computed minima and maxima in MIN_VAL and MAX_VAL, and
%   the corresponding coordinates where the minima/maxima occurs in
%   MIN_COORD and MAX_COORD, respectively.
%
%       Input       Value/[Size]           Description
%       -----------------------------------------------------------------------------------
%       s_expr      string                 Expression to evaluate
%       prob        struct                 FEA model/problem definition struct
%       ind_s       [1,n_subd]             Subdomain numbers (default all)
%       ind_c       [1,n_cells]            Cell indices (default all)
%       i_cub       scalar int             Evaluation point rule/quadrature order (default 2)
%       solnum      scalar int {n_sols}    Solution number/time to evaluate
%                                                                                         .
%       Output      Value/[Size]           Description
%       -----------------------------------------------------------------------------------
%       min_val     scalar                 Minimum value of expression
%       max_val     scalar                 Maximum value of expression
%       min_coord   scalar                 Coordinates where minima occurs
%       max_coord   scalar                 Coordinates where maxima occurs
%
%
%   Example:
%
%      1) Evaluate minima and maxima for the Poisson equation on a unit circle.
%
%      fea = ex_poisson2('iplot', false);  % Use example script to generate FEA data struct.
%
%      [u_min, u_max, p_min, p_max] = minmaxsubd('u', fea)
%
%   See also MINMAXBDR, INTBDR, INTSUBD

% Copyright 2013-2026 Precise Simulation, Ltd.