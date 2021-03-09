function [ coordinates, coordinateranges ] = causet_new_hcplaminate( elementdistance, units, evenshiftfactor, spacetime )
%CAUSET_NEW_HCPLAMINATE generates causet coordinates as layers of 
% spacelike hexagonal closed-sphere packing with ELEMENTDISTANCE between 
% the spheres and UNITS per SPACETIME dimension.
% 
% Arguments:
% ELEMENTDISTANCE     real number, which gives the size of a unit cell.
% UNITS               row vector with the number of units in each 
%                     dimension.
% 
% Optional aguments:
% EVENSHIFTFACTOR     0 if the even time-layers are not shifted in all 
%                     spacelike dimensions, 0.5 (Default) if they are 
%                     shifted by half the respective space layer distances.
% SPACETIME           specifies the type of spacetime.
%    'Minkowski'      flat spacetime with Euclidean coordinates for the
%                     spacelike dimensions.
% 
% Returns:
% COORDINATES         positions of the points.
% COORDINATERANGES    maximal possible position of an element.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    d = length( units );
    if nargin < 3
        evenshiftfactor = 0.5;
    end
    if nargin < 4
        spacetime = 'Minkowski';
    end
    % calculate hcp layer and number of elements:
    error = 0.001;
    [ spacecoordinates, spacecoordinateranges, spacelayerdistances ] = ...
        causet_new_hexclosepack( elementdistance, units( 2 : d ), spacetime );
    Nspace = size( spacecoordinates, 1 );
    coordinates = zeros( Nspace * units( 1 ), d );
    coordinateranges = zeros( 1, d );
    if strcmp( spacetime, 'Minkowski' )
        coordinateranges( 2 : d ) = spacecoordinateranges;
        dbar = 4 - 4 / sqrt( d - 1 );
        layerdistance = ( 1 + error ) * elementdistance * ...
            ( dbar * evenshiftfactor^2 - dbar * evenshiftfactor + 1 );
        coordinateranges( 1 ) = layerdistance * units( 1 );
        % set shifts for odd and even layers:
        shift = zeros( 2, d - 1 );
        shift( 2, : ) = evenshiftfactor * spacelayerdistances;
        % repeat space layer:
        for i = 0 : ( units( 1 ) - 1 )
            indexrange = ( i * Nspace + 1 ) : ( ( i + 1 ) * Nspace );
            coordinates( indexrange, 1 ) = ...
                layerdistance * ( i + 1 ) * ones( Nspace, 1 );
            coordinates( indexrange, 2 : d ) = ...
                spacecoordinates + shift( mod( i, 2 ) + 1, : );
        end
    end
end
