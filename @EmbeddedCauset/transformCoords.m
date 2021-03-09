function transformCoords( obj, coordsys )
%TRANSFORMCOORDS    Changes the coordinate system.
% 
% Arguments:
% obj                 Embeddedcauset class object.
% 
% Optional arguments:
% coordsys            The new coordinatesystem to which all coordinates are
%                     transformed. Supported are 'Cartesian' and
%                     'spherical' (cylindrical in spacetime).
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    coords = obj.Coords;
    d = size( coords, 2 );
    if strcmp( obj.CoordSys, 'Cartesian' ) ...
        && strcmp( coordsys, 'spherical' )
        %% transform from Cartesian to spherical:
        sdim = d - 1;
        idxmax = d - 2;
        idxran = 1 : idxmax;
        x_empty = zeros( 1, sdim );
        for i = 1 : obj.Card
            x = coords( i, 2 : d ); % all space coords
            r = sqrt( sum( x.^2 ) );
            phi = x_empty; % all angle coords
            for j = idxran
                denom = sqrt( sum( x( (j+1):sdim ).^2 ) );
                if ( denom ~= 0 )
                    phi( j ) = acot( x( j ) / denom );
                elseif ( x( j ) < 0 )
                    phi( j ) = pi();
                else
                    phi( j ) = 0;
                end
            end
            j = j + 1;
            denom = x( sdim );
            if ( denom ~= 0 )
                phi( j ) = 2 * acot( ( x( j ) ...
                                     + sqrt( sum( x( j:sdim ).^2 ) ) ) ...
                                   / denom );
            elseif ( x( j ) < 0 )
                phi( j ) = pi();
            else
                phi( j ) = 0;
            end
            coords( i, 2 : d ) = [ r, phi ];
        end
    elseif strcmp( obj.CoordSys, 'spherical' ) ...
        && strcmp( coordsys, 'Cartesian' )
        %% transform from spherical to Cartesian:
        sdim = d - 1;
        idxmax = d - 2;
        idxran = 1 : idxmax;
        x_empty = zeros( 1, sdim );
        for i = 1 : obj.Card
            r = coords( i, 2 );
            phi = coords( i, 3 : d ); % all angle coords
            x = x_empty; % all space coords
            sin_prod = 1;
            for j = idxran
                x( j ) = r * sin_prod * cos( phi( j ) );
                sin_prod = sin_prod * sin( phi( j ) );
            end
            j = j + 1;
            x( j ) = r * sin_prod;
            coords( i, 2 : d ) = x;
        end
    end
    obj.CoordSys = coordsys;
    obj.Coords = coords;
end
