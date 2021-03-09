function m = Caumat( obj, list )
%CAUMAT    Returns a logical causal matrix determined by the events list.
% 
% Arguments:
% obj                 Causet class object.
% 
% Optional arguments:
% list                Logical selection vector or set of events.
% 
% Returns:
% m                   Logical matrix.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 1, 2 );
    if nargin > 1
        m = obj.C( list, list );
    else
        m = obj.C;
    end
end

