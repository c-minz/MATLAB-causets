function c = SubCauset( obj, list )
%SETOF    Returns a new class instance for the sub-causet determined by
%   the events list.
% 
% Arguments:
% obj                 Causet class object.
% list                Logical selection vector or set of events.
% 
% Returns:
% c                   Causet class object.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 2, 2 );
    c = causet( obj.Caumat( list ) );
end

