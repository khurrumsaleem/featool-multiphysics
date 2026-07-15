%GEOM_COMBINE_OBJECTS Combine geometry objects.
%
%   [ GEOM, NEW_TAG, STAT ] = GEOM_COMBINE_OBJECTS( GEOM, TAG1, TAG2, OP, IS_WARN )
%   Combines geometry objects TAG1 and TAG2 by applying operator OP,
%   where OP is a string character indicating operation to perform
%   ('+' or '*' union/join, '-' subtract, '&' or '|' intersect).
%
%   Returns an updated and modified geometry struct GEOM, the NEW_TAG
%   of the last new geometry object, and status code STAT. STAT is
%   zero if the operation has been applied sucessfully, and a positive
%   integer to indicate error. The IS_WARN flag (default false)
%   enables throwing warnings if the geometry objects cannot be combined.
%
%   See also GOBJ_APPLY_OP

% Copyright 2013-2026 Precise Simulation, Ltd.