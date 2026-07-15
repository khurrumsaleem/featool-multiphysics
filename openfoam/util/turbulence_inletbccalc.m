%TURBULENCE_INLETBCCALC Compute turbulence quantities for inlet boundaries.
%
%   [ RES ] = TURBULENCE_INLETBCCALC( FEA, PHYS, INTENSITY, LSCALE )
%   Compute turbulence (k, epsilon/omega) quantities for inlet boundaries.
%
%   FEA is a valid simulation model/problem struct, and PHYS is a
%   physics mode struct, or an integer number indicating the physics
%   mode to use (in fea.phys).
%
%   INTENSITY specifies the turbulent intensity per inlet boundary
%   (defaults to 0.1 = 10%), and LSCALE the fraction of the inlet
%   boundary length to compute the turbulence length scale LTURB
%   (defaults to 0.08).
%
%   Returns a result array struct RES with fields BOUNDARY (inlet
%   boundary number), LENGTH (boundary length/area), UMEAN (mean
%   velocity). And KEO with turbulent kinetic energy k (1), and
%   (specific) turbulent dissipation rate epsilon (2), and omega (3)
%   where:
%
%       k = 3/2 * (u_mean * intensity)^2
%       epsilon = c_miu^( 3/4) * k^(3/2) / l_turb  % c_miu = 0.09
%       omega = c_miu^(-1/4) * k^(1/2) / l_turb

% Copyright 2013-2026 Precise Simulation, Ltd.