function [ L, C ] = causet_edit_link( coordinates, spacetime )
%CAUSET_EDIT_LINK sets the links for a causet with event COORDINATES in a
% SPACETIME with spacetime dimensions and ranges specified by 
% COORDINATERANGES. 
% 
% Arguments:
% COORDINATES         positions of the elements.
% 
% Optional aguments:
% SPACETIME           specifies the type of spacetime.
%    'Minkowski'      flat spacetime with Euclidean coordinates for the
%                     spacelike dimensions.
% 
% Returns:
% L                   logical upper triangular (direct) links matrix.
% C                   logical upper triangular causal matrix.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    N = size( coordinates, 1 );
    d = size( coordinates, 2 );
    if nargin < 3
        spacetime = 'Minkowski';
    end
    if strcmp( spacetime, 'Minkowski' )
        % set Minkowski metric:
        metrictime = zeros( d );
        metrictime( 1, 1 ) = 1;
        metric = 2 * metrictime - eye( d );
        % compute links:
        C = false( N );
        L = false( N );
        for j = 2 : N
            Jcoord = coordinates( j, : );
            for i = 1 : ( j - 1 )
                dcoordinates = Jcoord - coordinates( i, : );
                causaldistanceIJ = dcoordinates * metric * transpose( dcoordinates );
                if causaldistanceIJ >= 0
                    C( i, j ) = true;
                    haslink = true;
                    for k = ( i + 1 ) : ( j - 1 )
                        dcoordinates = Jcoord - coordinates( k, : );
                        causaldistanceKJ = dcoordinates * metric * transpose( dcoordinates );
                        if causaldistanceKJ >= 0 
                            C( k, j ) = true;
                        end
                        if C( i, k ) && C( k, j )
                            haslink = false;
                            break;
                        end
                    end
                    if haslink
                        L( i, j ) = true;
                    end
                end
            end
        end
    end
end

