%EVALEXPR Evaluate expression in specified points.
%
%   [ VEVAL ] = EVALEXPR( S_EXPR, XP, PROB, SOLNUM, EVAL_TYPE, TOL )
%   Evaluates the expression S_EXPR in the points XP, using FEM
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
%   XP is a row array of evaluation points (size n_sdim rows by
%   n_evaluation_points columns). For example using XP = PROB.grid.p
%   evaluates the expression in all grid points.
%
%   SOLNUM is an optional scalar integer indicating the solution/time
%   to use in the evaluation (PROB.sol.u(:,SOLNUM), defaults to the
%   last available solution "size(PROB.sol.u, 2)").
%
%   The optional EVAL_TYPE flag toggles evaluation method (default 1)
%
%   0 - Full FEM shape function evaluation for all points (slow, accurate).
%
%   1 - Like (0) but with fast vectorized evaluation of dependent variables
%       defined by Lagrange P0-P2 FEM shape functions (PROB.sfun).
%
%   2 - Evaluation via interpolation to grid points (tri/tet grids, fast but
%       less accurate). Invalid/NaN values contribute zero/0 to the output.
%
%   3 - Like (2) above but also allow invalid/NaN values in output.
%
%   TOL is a tolerance used by ismembertol/deduplicate to determine
%   which evaluation points in XP are aligned with grid points and can
%   be evaluated faster and more efficiently. Use EVALEXPRP instead of
%   EVALEXPR for directly evaluating an expression in *all* grid/mesh
%   points (PROB.grid.p) at the same time.
%
%   The resulting evaluated values are returned in a column vector
%   VEVAL with one value for each evaluation point. Points outside the
%   grid/geometry will by default return invalid/NaN (Not-a-Number)
%   values. The resulting values can then be saved/exported in various
%   formats using built-in functions such as SAVE, CSVWRITE, and XLSWRITE.
%
%       Input       Value/[Size]           Description
%       -----------------------------------------------------------------------------------
%       s_expr      string                 Expression to evaluate
%       xp          [n_sdim,n_xp]          Coordinates of evaluation points
%       prob        struct                 FEA model/problem definition struct
%       solnum      scalar int {n_sols}    Solution number/time to evaluate
%       eval_type   scalar int {1}         Evaluation type
%                                             0 - Standard/full evaluation
%                                             1 - Vectorized evaluation for dep. variables
%                                             2 - Linear interpolation via nodes (fast)
%                                             3 - Like 2 and allow invalid (NaN) values
%       tol         scalar  {1e-5}         Tolerance for evaluation/grid aligned points
%                                                                                         .
%       Output      Value/(Size)           Description
%       -----------------------------------------------------------------------------------
%       vEval       [n_xp,1]               Output/result vector of evaluated values
%
%
%   Examples:
%
%      1) Evaluate the dependent variable "u" in the point x=0.5.
%
%      fea = ex_poisson1('iplot', false);  % Use example script to generate FEA data struct.
%
%      u_0p5 = evalexpr('u', 0.5, fea)
%
%      2) Evaluate and plot the expression "1+sin(ux)" at the line x=-1:1, y=0.
%
%      fea = ex_poisson2('iplot', false);
%
%      p = [linspace(-1, 1, 100); zeros(1, 100)];
%      result = evalexpr('1+sin(ux)', p, fea);
%
%      plot(p(1,:), result)
%
%      3) Evaluate the mean of the temperature derivative in the mesh points at time t=100 s.
%
%      fea = ex_heattransfer5('iplot', false);
%      solnum = find(fea.sol.t == 100);
%
%      magTx = evalexpr('sqrt(Tx^2 + Ty^2)', fea.grid.p, fea, solnum);
%      mean(magTx)
%
%   See also EVALEXPRP

% Copyright 2013-2026 Precise Simulation, Ltd.