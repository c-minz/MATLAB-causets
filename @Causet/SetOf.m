function s = SetOf( obj, list )
%SETOF    Returns a event (index) vector for the events list.
% 
% Arguments:
% obj                 Causet class object.
% list                Logical selection vector or set of events.
% 
% Returns:
% s                   Vector of events (indices).
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 2, 2 );
    
    if islogical( list )
        if length( list ) > obj.Card
            s = find( list( 1 : obj.Card ) );
        else
            s = find( list );
        end
    else
        s = list;
    end
end

