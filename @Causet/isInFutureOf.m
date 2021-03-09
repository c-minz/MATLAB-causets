function list = isInFutureOf( obj, list, e )
%ISINFUTUREOF    Returns a logical vector for each event in list  
%   determining if it is in the future of e.
% 
% Arguments:
% obj                 Causet class object.
% list                Logical selection vector or list of events. 
% e                   Event which future is considered.
% 
% Returns:
% list                Logical selection or logical list that is true only 
%                     for the events of list that are in the future of e.
%                     If list is a list of events, the return has the same
%                     length.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 3, 3 );
    
    if islogical( list )
        list = obj.FutureOf( e, 'partof', list, 'return', 'sel' );
    else
        eventCount = length( list );
        list_logic = false( 1, eventCount );
        for i = 1 : eventCount
            list_logic( i ) = obj.isCausal( e, list( i ) );
        end
        list = list_logic;
    end
end

