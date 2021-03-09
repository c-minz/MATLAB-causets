function [ coordinates, coordinateranges ] = causet_new_diamonds( unitsize, units, spacetime )
%CAUSET_NEW_DIAMONDS generates causet coordinates arranged in a regular
% diamond pattern with unit cell length UNITSIZE and all coordinates 
% within the COORDINATERANGES of the SPACETIME.
% 
% Arguments:
% UNITSIZE            real number, which gives the size of a unit cell.
% UNITS               row vector with the number of units in each 
%                     dimension.
% 
% Optional aguments:
% SPACETIME           specifies the type of spacetime.
%    'Minkowski'      flat spacetime with Euclidean coordinates for the
%                     spacelike dimensions.
% 
% Returns:
% COORDINATES         positions of the elements.
% COORDINATERANGES    maximal possible position of an element.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    d = length( units );
    if nargin < 3
        spacetime = 'Minkowski';
    end
    % calculate number of elements and get coordinates:
    N = prod( units );
    error = 0.001;
    coordinates = zeros( N, d );
    if strcmp( spacetime, 'Minkowski' )
        tunitsize = ( sqrt( d - 1 ) + error ) * unitsize;
        coordinateranges = units * unitsize;
        coordinateranges( 1 ) = units( 1 ) * tunitsize;
        % set single point for zero-dimensional:
        setcount = 1;
        coordinates( 1, : ) = zeros( 1, d );
        % create odd time layer:
        for idim = 2 : d
            shift = zeros( 1, d );
            for j = 1 : ( units( idim ) - 1 )
                shift( idim ) = shift( idim ) + unitsize;
                % copy set of previous points to shifted set:
                for k = 1 : setcount
                    coordinates( setcount * j + k, : ) = coordinates( k, : ) + shift;
                end
            end
            setcount = setcount * units( idim );
        end
        if units( 1 ) > 1
            oddsetcount = setcount;
            % create even time layer:
            shift = unitsize / 2 * ones( 1, d );
            shift( 1 ) = shift( 1 ) * tunitsize / unitsize;
            for k = 1 : oddsetcount
                newcoord = coordinates( k, : ) + shift;
                if sum( newcoord >= coordinateranges ) == 0
                    % only add if not outside the ranges:
                    setcount = setcount + 1;
                    coordinates( setcount, : ) = newcoord;
                end
            end
            % repeat odd + even time layers:
            shift = zeros( 1, d );
            for j = 1 : ( floor( units( 1 ) / 2 ) - 1 )
                shift( 1 ) = shift( 1 ) + tunitsize;
                % copy set of previous points to shifted set:
                for k = 1 : setcount
                    coordinates( setcount * j + k, : ) = coordinates( k, : ) + shift;
                end
            end
            setcount = setcount * floor( units( 1 ) / 2 );
            % add one more odd time layer if necessary:
            if mod( units( 1 ), 2 ) > 0
                shift( 1 ) = shift( 1 ) + tunitsize;
                % copy set of previous points to shifted set:
                for k = 1 : oddsetcount
                    coordinates( setcount + k, : ) = coordinates( k, : ) + shift;
                end
                setcount = setcount + oddsetcount;
            end
        end
        % remove buffer:
        coordinates = coordinates( 1 : setcount, : );
    end
end
