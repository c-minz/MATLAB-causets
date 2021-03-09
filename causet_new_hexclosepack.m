function [ coordinates, coordinateranges, layerdistances ] = causet_new_hexclosepack( elementdistance, units, spacetime )
%CAUSET_NEW_HEXCLOSEPACK generates causet coordinates arranged in a regular
% hexagonal closed-sphere packing with ELEMENTDISTANCE between the spheres
% and UNITS per SPACETIME dimension.
% 
% Arguments:
% ELEMENTDISTANCE     real number, which gives the size of a unit cell.
% UNITS               row vector with the number of units in each 
%                     dimension.
% 
% Optional aguments:
% SPACETIME           specifies the type of spacetime.
%    'Minkowski'      flat spacetime with Euclidean coordinates for the
%                     spacelike dimensions.
% 
% Returns:
% COORDINATES         positions of the points.
% COORDINATERANGES    maximal possible position of an element.
% LAYERDISTANCES      shift values for layers.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    d = length( units );
    if nargin < 3
        spacetime = 'Minkowski';
    end
    % calculate number of elements and get layer offsets per dimension:
    error = 0.001;
    N = prod( units );
    coordinates = zeros( N, d );
    if strcmp( spacetime, 'Minkowski' )
        if d >= 4
            layerdistances = elementdistance / sqrt( 2 ) * zeros( 1, d );
        else
            layerdistances = [ 1, sqrt( 3 ) / 2, sqrt( 2 / 3 ) ] * elementdistance;
            layerdistances = layerdistances( 1 : d );
            evenlayeroffsets = [ 1, 0.5, sqrt( 1 / 3 ) ] * elementdistance;
            evenlayeroffsets = evenlayeroffsets( 1 : d );
            evenlayeroffsets( d ) = evenlayeroffsets( d ) + error;
        end
        layerdistances( d ) = layerdistances( d ) + error;
        coordinateranges = units .* layerdistances;
        % set single point for zero-dimensional:
        setcount = 1;
        coordinates( 1, : ) = zeros( 1, d );
        if d < 4
            for idim = 1 : d
                oddsetcount = setcount;
                % add even layer:
                shift = zeros( 1, d );
                if idim > 1
                    shift( idim - 1 ) = evenlayeroffsets( idim );
                end
                shift( idim ) = layerdistances( idim );
                for k = 1 : oddsetcount
                    newcoord = coordinates( k, : ) + shift;
                    if sum( newcoord >= coordinateranges ) == 0
                        % only add if not outside the ranges:
                        setcount = setcount + 1;
                        coordinates( setcount, : ) = newcoord;
                    end
                end
                % repeat odd + even layers:
                shift = zeros( 1, d );
                for j = 1 : ( floor( units( idim ) / 2 ) - 1 )
                    shift( idim ) = shift( idim ) + 2 * layerdistances( idim );
                    for k = 1 : setcount
                        coordinates( setcount * j + k, : ) = coordinates( k, : ) + shift;
                    end
                end
                setcount = setcount * floor( units( idim ) / 2 );
                % add one more odd time layer if unit number is odd:
                if mod( units( idim ), 2 ) > 0
                    shift( idim ) = shift( idim ) + 2 * layerdistances( idim );
                    % copy set of previous points to shifted set:
                    for k = 1 : oddsetcount
                        coordinates( setcount + k, : ) = coordinates( k, : ) + shift;
                    end
                    setcount = setcount + oddsetcount;
                end
            end
        elseif d == 4
            % create unit cell:
            unitcellshifts = [ 0, 1, 1, 0; 1, 0, 1, 0; 1, 1, 0, 0; ...
                1, 0, 0, 1; 0, 1, 0, 1; 0, 0, 1, 1; 1, 1, 1, 1 ];
            for i = 1 : size( unitcellshifts, 1 )
                shift = unitcellshifts( 1, : ) .* layerdistances;
                newcoord = coordinates( 1, : ) + shift;
                if sum( newcoord >= coordinateranges ) == 0
                    % only add if not outside the ranges:
                    setcount = setcount + 1;
                    coordinates( setcount, : ) = newcoord;
                end
            end
            for idim = 1 : d
                prevsetcount = setcount;
                % repeat unit cell:
                shift = zeros( 1, d );
                for j = 1 : ( floor( units( idim ) / 2 ) - 1 )
                    shift( idim ) = shift( idim ) + 2 * layerdistances( idim );
                    for k = 1 : prevsetcount
                        coordinates( prevsetcount * j + k, : ) = coordinates( k, : ) + shift;
                    end
                end
                setcount = setcount * floor( units( idim ) / 2 );
                % add one more unit cell if units number is odd:
                if mod( units( idim ), 2 ) > 0
                    shift( idim ) = shift( idim ) + 2 * layerdistances( idim );
                    % copy set of previous points to shifted set:
                    for k = 1 : prevsetcount
                        newcoord = coordinates( k, : ) + shift;
                        if sum( newcoord >= coordinateranges ) == 0
                            % only add if not outside the ranges:
                            setcount = setcount + 1;
                            coordinates( setcount, : ) = newcoord;
                        end
                    end
                end
            end
        else
            fprintf( 'CAUSET_NEW_HCPLAMINATE error: HCP laminate lattice for %d spacetime dimensions is not implemented!\n', d );
        end
        % remove buffer:
        coordinates = coordinates( 1 : setcount, : );
    end
end
