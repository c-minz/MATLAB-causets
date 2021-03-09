function list = isInPastOf( obj, list, e )
%ISINPASTOF    Returns a logical vector for each event in list determining 
%   if it is in the past of e.
% 
% Arguments:
% obj                 Causet class object.
% list                Logical selection vector or list of events. 
% e                   Event which past is considered.
% 
% Returns:
% list                Logical selection or logical list that is true only 
%                     for the events of list that are in the past of e.
%                     If list is a list of events, the return has the same
%                     length.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 3, 3 );
    
    if islogical( list )
        list = obj.PastOf( e, 'partof', list, 'return', 'sel' );
    else
        eventCount = length( list );
        list_logic = false( 1, eventCount );
        for i = 1 : eventCount
            list_logic( i ) = obj.isCausal( list( i ), e );
        end
        list = list_logic;
    end
end

