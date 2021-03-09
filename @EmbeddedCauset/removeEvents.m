function removeEvents( obj, varargin )
%REMOVEEVENTS    Removes an event from the causet.
% 
% Arguments:
% obj                 Embedded causet class object.
% 
% Optional arguments:
% position            Use 'futureinf' or 'pastinf' (Default) to 
%                     remove the events in the future or past infinity, 
%                     respectively. 
% OR
% list                Logical selection vector or a set of events.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 1, 3 );
    if ( nargin == 1 ) || strcmp( varargin{ 1 }, 'pastinf' )
        list = obj.PastInf();
    elseif strcmp( varargin{ 1 }, 'futureinf' )
        list = obj.FutureInf();
    else
        list = varargin{ 1 };
    end
    sel = obj.SelOf( list );
    obj.Coords = obj.Coords( ~sel, : );
    removeEvents@Causet( obj, sel );
end

