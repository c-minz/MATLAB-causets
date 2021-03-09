function R = EmbeddingRegion( obj, e, issl )
%EMBEDDINGREGION    Returns the embedding region. For 1 + 1 Minkowski
%   spacetime the return is a 2x2 matrix for the ranges of the light-cone
%   coordinates. 
% 
% Arguments:
% obj                 Embeddedcauset class object.
% e                   Index of the event to find its embedding region.
% 
% Optional arguments:
% issl                Matrix of logical selection vectors (one per row) for 
%                     neighbouring events. The row number of the matrix 
%                     has to equal the spacetime dimension.
%                     For 1 + 1 dimensional Minkowski spacetime, the first
%                     selection vector gives all events that are spacelike 
%                     and to the left of e. And the second vector indicates
%                     the events to the right.
%                     Default: no spacelike separated events
% 
% Returns:
% R                   Embedding region if any exists, otherwise an empty
%                     matrix.
%                     In 1 + 1 Minkowski spacetime, a matrix for minimum
%                     (first row) and maximum (second row) of the
%                     light-cone coordinates u (first column) and v (second
%                     column) is returned. Notice that the matrix has a 
%                     +/-Inf value if a range is not limited in a
%                     direction.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 2, 3 );
    %% set defaults:
    if nargin < 3
        issl = false( obj.Dim, obj.Card );
    end
    if ~strcmp( obj.Metric, 'Minkowski' )
        warning( 'The function supports only Minkowski spacetime.' );
        return
    end
    if ~strcmp( obj.CoordSys, 'Cartesian' )
        warning( 'The function supports only Cartesian coordinates.' );
        return
    end
    %% compute coordinates of the hull:
    if obj.Dim == 2
        u = [ -Inf; Inf ];
        v = [ -Inf; Inf ];
        isemptyregion = false;
        for a = find( ~isnan( obj.Coords( :, 1 )' ) )
            a_u = ( obj.Coords( a, 1 ) + obj.Coords( a, 2 ) ) / sqrt( 2 );
            a_v = ( obj.Coords( a, 1 ) - obj.Coords( a, 2 ) ) / sqrt( 2 );
            if obj.isCausal( a, e ) || issl( 1, a )
                u( 1 ) = max( u( 1 ), a_u );
            else
                u( 2 ) = min( u( 2 ), a_u );
            end
            if obj.isCausal( a, e ) || issl( 2, a )
                v( 1 ) = max( v( 1 ), a_v );
            else
                v( 2 ) = min( v( 2 ), a_v );
            end
            isemptyregion = ( u( 1 ) >= u( 2 ) ) || ( v( 1 ) >= v( 2 ) );
            if isemptyregion
                break
            end
        end
        if isemptyregion
            R = [];
        else
            R = [ u, v ];
        end
    else
        warning( 'The function supports only one space dimension.' );
    end
end
