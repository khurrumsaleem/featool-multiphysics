%SF_QUAD_Q2 Biquadratic conforming shape function for quadrilaterals (Q2).
%
%   [ VBASE, NLDOF, XLDOF, SFUN ] = SF_QUAD_Q2( I_EVAL, N_SDIM, N_VERT, I_DOF, XI, AINVJAC, VBASE )
%   Evaluates conforming biquadratic Q2 shape functions on quadrilaterals
%   with values defined in the nodes, edges, and cell center. XI is
%   [-1..1]^2 reference coordinates.
%
%       Input       Value/[Size]           Description
%       -----------------------------------------------------------------------------------
%       i_eval      scalar:  1             Evaluate function values
%                           >1             Evaluate values of derivatives
%       n_sdim      scalar:  2             Number of space dimensions
%       n_vert      scalar:  4             Number of vertices per cell
%       i_dof       scalar: 1-n_ldof       Local basis function to evaluate
%       xi          [n_sdim]               Local coordinates of evaluation point
%       aInvJac     [n,n_sdim*n_sdim]      Inverse of transformation Jacobian
%       vBase       [n]                    Preallocated output vector
%                                                                                         .
%       Output      Value/[Size]           Description
%       -----------------------------------------------------------------------------------
%       vBase       [n]                    Evaluated function values
%       nLDof       [4]                    Number of local degrees of freedom on
%                                          vertices, edges, faces, and cell interiors
%       xLDof       [n_sdim,n_ldof]        Local coordinates of local dofs
%       sfun        string                 Function name of called shape function
%
%   See also SFLAG2

% Copyright 2013-2025 Precise Simulation, Ltd.

























