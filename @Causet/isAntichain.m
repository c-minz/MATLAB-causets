function bool = isAntichain( obj, list )
%ISANTICHAIN    Returns true only if all the elements in the list are
%   pairwise spacelike separated.
% 
% Arguments:
% obj                 Causet class object.
% 
% Optional arguments:
% list                Logical selection vector or list of events. 
%                     Default: empty vector
% 
% Returns:
% bool                True only if all events are pairwise spacelike 
%                     separated.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    if nargin < 2
        list = [];
    end
    
    bool = sum( sum( obj.Caumat( list ) ) ) == 0;
end

