function bool = isIrred2( obj, list )
%ISIRRED2    Checks if a set of events is a 2-irreducible (two spacelike
%   separated events).
%
% Arguments:
% obj                 Causet class object.
% list                Logical selection vector or list of events.
% 
% Returns:
% bool                True if there are two spacelike separated events.
%                     Otherwise it returns false.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    if islogical( list )
        list = find( list );
    end
    bool = ( length( list ) == 2 ) ... & has to be two events
        && obj.isSpacelikeTo( list( 1 ), list( 2 ) );
end

