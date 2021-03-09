function bool = isSpacelikeTo( obj, alist, blist )
%ISSPACELIKETO    Returns true only if each event pair { a, b }, where a 
%   in alist and b in blist, is spacelike separated.
% 
% Arguments:
% obj                 Causet class object.
% alist               Logical selection vector or list of events that 
%                     shall be spacelike to the events in blist.
% 
% Optional arguments:
% blist               Logical selection vector or list of events. 
%                     Default: empty vector
% 
% Returns:
% bool                True if all events are pairwise spacelike separated.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 2, 3 );
    
    if nargin < 2
        blist = [];
    end
    bool = sum( sum( obj.C( alist, blist ) ) ) ...
         + sum( sum( obj.C( blist, alist ) ) ) == 0;
end

