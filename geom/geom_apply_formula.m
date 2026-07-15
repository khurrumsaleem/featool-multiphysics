%GEOM_APPLY_FORMULA Apply formula to geometry.
%
%   [ SOUT, STAT ] = GEOM_APPLY_FORMULA( SIN, FORMULA, IS_WARN )
%   Applies a FORMULA string to geometry objects in the fea or
%   geometry struct SIN. Returns the modified fea/geometry struct in
%   SOUT, and zero status/return code STAT if all operations have been
%   applied sucessfully, or else a positive integer corresponding to
%   the number of failed geometry object combinations. The IS_WARN
%   flag (default false) enables throwing warnings if the geometry
%   objects cannot be combined.
%
%   The FORMULA is a string containing combinations of geometry object
%   tags (operands defined by words with characteres [A-Za-z0-9_]),
%   parentheses to define precedence, and geometry operators, +* =
%   Join, - = Subtract, and &| = Intersect. Without defining
%   precedence with parentheses operations perform from left to right.
%
%   Examples:
%
%       1) Join two touching blocks, CJ1 = B1 + B2.
%
%       geom.objects = {gobj_block(), gobj_block(1, 2, 0, 1, 0, 1, 'B2')};
%       geom = geom_apply_formula( geom, 'B1 + B2' );
%       plotgeom(geom)
%
%       2) Join and subtract rectangles with precedence, CJ1 = R3 + (R1 - R2) = R1 - R2 + R3.
%
%       geom.objects = {gobj_rectangle(), ...
%                       gobj_rectangle(1/3, 1, 1/3, 2/3, 'R2'), ...
%                       gobj_rectangle(2/3, 1, 1/3, 2/3, 'R3')};
%       geom = geom_apply_formula( geom, 'R3 + (R1 - R2)' );
%       plotgeom(geom)
%
%       3) Intersection between unit circle and rectangle, CI1 = C1 & R1.
%
%       geom.objects = {gobj_circle(), gobj_rectangle()};
%       geom = geom_apply_formula( geom, 'C1 & R1' );
%       plotgeom(geom)

% Copyright 2013-2026 Precise Simulation, Ltd.