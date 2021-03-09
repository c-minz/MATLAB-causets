function coordinates = causet_edit_timeaslast( coordinates )
%CAUSET_EDIT_TIMEASLAST cyclic permutates the array such that the first
% column is moved to the last.
% 
% Arguments:
% COORDINATES         positions of the elements.
% 
% Returns:
% COORDINATES         positions of the elements with time coordinate in 
%                     last entry.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    d = size( coordinates, 2 );
    timecoordinates = coordinates( :, 1 );
    coordinates( :, 1 : ( d - 1 ) ) = coordinates( :, 2 : d );
    coordinates( :, d ) = timecoordinates;
end

