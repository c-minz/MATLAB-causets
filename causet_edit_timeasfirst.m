function coordinates = causet_edit_timeasfirst( coordinates )
%CAUSET_EDIT_TIMEASFIRST cyclic permutates the array such that the last
% column is moved to the first.
% 
% Arguments:
% COORDINATES         positions of the elements.
% 
% Returns:
% COORDINATES         positions of the elements with time coordinate in 
%                     first entry.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    d = size( coordinates, 2 );
    timecoordinates = coordinates( :, d );
    coordinates( :, 2 : d ) = coordinates( :, 1 : ( d - 1 ) );
    coordinates( :, 1 ) = timecoordinates;
end

