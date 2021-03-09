function coordinates = causet_new_randomize( coordinates, coordinateranges, randomizeoffsets, spacetime )
%CAUSET_NEW_RANDOMIZE offsets the coordinates randomly.
% 
% Arguments:
% COORDINATES         positions of the points.
% COORDINATERANGES    row vetor with maximal possible position of an 
%                     element.
% 
% Optional arguments:
% RANDOMIZEOFFSETS    row vector with the maximal random offset per 
%                     dimension.
%    Default: ones( 1, d )
% SPACETIME           specifies the type of spacetime.
%    "Minkowski"      flat spacetime with Euclidean coordinates for the
%                     spacelike dimensions.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    d = size( coordinateranges, 1 );
    N = size( coordinates, 1 );
    if nargin < 3
        randomizeoffsets = ones( 1, d );
    end
    if nargin < 4
        spacetime = 'Minkowski';
    end
    % offset coordinates randomly:
    if strcmp( spacetime, 'Minkowski' )
        for i = 1 : N
            for idim = 1 : d
                x = coordinates( i, idim );
                x = x + randomizeoffsets( idim ) * rand( 1, 1 );
                if x < 0
                    x = x + coordinateranges( idim );
                elseif coordinates( i, idim ) > coordinateranges( idim ) 
                    x = x - coordinateranges( idim );
                end
                coordinates( i, idim ) = x;
            end
        end
        % sort by time:
        [ sortedtime, I ] = sort( coordinates( :, 1 ) );
        coordinates = coordinates( I, : );
    end
end

