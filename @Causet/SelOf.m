function s = SelOf( obj, list )
%SELOF    Returns a logical (selection) vector for the events list.
% 
% Arguments:
% obj                 Causet class object.
% list                Logical selection vector or set of events.
% 
% Returns:
% s                   Logical (selection) vector.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 2, 2 );
    
    if islogical( list ) && ( length( list ) >= obj.Card )
        if length( list ) > obj.Card
            s = list( 1 : obj.Card );
        else
            s = list;
        end
    else
        s = false( 1, obj.Card );
        s( list ) = true;
    end
end

