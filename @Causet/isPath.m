function bool = isPath( obj, list )
%ISPATH    Returns true only if the elements in the list are a chain and
%   consecutive elements are linked.
% 
% Arguments:
% obj                 Causet class object.
% 
% Optional arguments:
% list                Logical selection vector or list of events. 
%                     Default: empty vector
% 
% Returns:
% bool                True only if all events are pairwise causally 
%                     related and consecutive events are linked.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    if nargin < 2
        list = [];
    end
    
    L = obj.Linkmat( list );
    a = ones( 1, length( list ) - 1 );
    bool = isequal( sum( L, 1 ), [ 0, a ] ) && ...
        isequal( sum( L, 2 ), [ a'; 0 ] );
end

