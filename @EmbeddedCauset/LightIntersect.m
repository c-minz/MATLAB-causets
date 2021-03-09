function varargout = LightIntersect( a, b, metric, coordsys )
%LIGHTINTERSECT    Returns the intersection of the light rays originating
%   from events a and b (given in the coordinate system coordsys).
% 
% Arguments:
% a                   Coordinate vector of event a.
% b                   Coordinate vector of event b.
% 
% Optional arguments:
% metric              Name of the spacetime metric.
%                     Default: 'Minkowski'
% coordsys            Name of the coordinate system.
%                     Default: 'Cartesian'
% 
% Returns:
% I                   Matrix of event coordinates of the intersection. Each
%                     event is one row of coordinates in the matrix.
%                     For example, the light-cones of two events in 1 + 1 
%                     Minkowski spacetime have two intersection events.
% [ b, l, r, t ]      For 1 + 1 Minkowski spacetime, one can choose a
%                     multi-value return. The first event coordinates give
%                     the past point, the second the left, the third the 
%                     right, and the fourth the future event of the 
%                     intersection.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 2, 4 );
    varargout = cell( 1, nargout );
    if length( a ) ~= length( b )
        return
    end
    if nargin < 3
        metric = 'Minkowski';
    end
    if nargin < 4
        coordsys = 'Cartesian';
    end
    if strcmp( metric, 'Minkowski' ) && strcmp( coordsys, 'Cartesian' )
        if length( a ) == 2
            I = 0.5 * [ a( 1 ) + b( 1 ) + a( 2 ) - b( 2 ), ...
                        a( 1 ) - b( 1 ) + a( 2 ) + b( 2 ); ...
                        a( 1 ) + b( 1 ) - a( 2 ) + b( 2 ), ...
                       -a( 1 ) + b( 1 ) + a( 2 ) + b( 2 ) ];
            I( isnan( I ) ) = 0;
            if nargout < 2
                varargout{ 1 } = I;
            else
                varargout = cell( 1, 4 );
                if ( a( 1 ) - b( 1 ) )^2 - ( a( 2 ) - b( 2 ) )^2 >= 0
                    % intersections are left and right
                    if I( 1, 2 ) < I( 2, 2 )
                        varargout{ 2 } = I( 1, : );
                        varargout{ 3 } = I( 2, : );
                    else
                        varargout{ 2 } = I( 2, : );
                        varargout{ 3 } = I( 1, : );
                    end
                    if a( 1 ) < b( 1 )
                        varargout{ 1 } = a;
                        varargout{ 4 } = b;
                    else
                        varargout{ 1 } = b;
                        varargout{ 4 } = a;
                    end
                else
                    % intersections are past and future
                    if I( 1, 1 ) < I( 2, 1 )
                        varargout{ 1 } = I( 1, : );
                        varargout{ 4 } = I( 2, : );
                    else
                        varargout{ 1 } = I( 2, : );
                        varargout{ 4 } = I( 1, : );
                    end
                    if a( 2 ) < b( 2 )
                        varargout{ 2 } = a;
                        varargout{ 3 } = b;
                    else
                        varargout{ 2 } = b;
                        varargout{ 3 } = a;
                    end
                end
            end
        end
    end
end
