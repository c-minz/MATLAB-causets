function bool = isChain( obj, list )
%ISCHAIN    Returns true only if all the elements in the list are
%   pairwise causally related.
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
%                     related.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    if nargin < 2
        list = [];
    end
    
    C = obj.Caumat( list );
    C = ~( C' | C );
    bool = isequal( C, eye( length( list ) ) );
end

