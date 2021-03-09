function removeEvents( obj, list )
%REMOVEEVENTS    Removes an event from the causet.
% 
% Arguments:
% obj                 Causet class object.
% 
% Optional arguments:
% list                Logical selection vector or set of events; or 
%                     'pastinf' (Default) or 'futureinf' to remove all
%                     events in the past / future infinity.
% OR
% list                Logical selection vector or a set of events.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 1, 2 );
    
    if ( nargin == 1 ) || strcmpi( list, 'pastinf' )
        list = obj.PastInf();
    elseif strcmpi( list, 'futureinf' )
        list = obj.FutureInf();
    end
    sel = ~obj.SelOf( list );
    obj.C = logical( obj.C( sel, sel ) );
    obj.Card = size( obj.C, 1 );
    obj.L = []; % reset links
end

