%EVALEXPRP Evaluate expression in grid/mesh points.
%
%   [ VEVAL ] = EVALEXPRP( S_EXPR, PROB, SOLNUM, IND ) Evaluates the
%   expression EXPR in the grid/mesh points (PROB.grid.p), using FEM
%   interpolation of data given in the FEA model/problem struct PROB.
%
%   SOLNUM is an optional scalar integer indicating the solution/time
%   to use in the evaluation (PROB.sol.u(:,SOLNUM), defaults to the
%   last available solution "size(PROB.sol.u, 2)").
%
%   IND is also an optional index vector indicating grid points to
%   evaluate (defaults to all 1:n_p).
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
%       prob        struct                 FEA model/problem definition struct
%       solnum      scalar int {n_sols}    Solution number/time to evaluate
%       ind         vector int {1:n_p}     Index to grid points for which to evaluate
%                                                                                         .
%       Output      Value/(Size)           Description
%       -----------------------------------------------------------------------------------
%       vEval       [n_ind,1]              Output/result vector of evaluated values
%
%
%   Example:
%
%      1) Evaluate the mean of the temperature derivative in the mesh points at time t=100 s.
%
%      fea = ex_heattransfer5('iplot', false);  % Use example script to generate FEA data struct.
%      solnum = find(fea.sol.t == 100);
%
%      magTx = evalexprp('sqrt(Tx^2 + Ty^2)', fea, solnum);
%      mean(magTx)
%
%   See also EVALEXPR

% Copyright 2013-2026 Precise Simulation, Ltd.