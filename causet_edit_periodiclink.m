function [ L, C ] = causet_edit_periodiclink( coordinates, coordinateranges, spacetime )
%CAUSET_EDIT_PERIODICLINK turns a causet with points given by COORDINATES 
% into a spacelike periodic causet.
% 
% Arguments:
% COORDINATES         positions of the elements.
% COORDINATERANGES    row vector for the maxima of the coordinates in each
%                     dimension.
% 
% Optional arguments:
% SPACETIME           specifies the type of spacetime.
%    "Minkowski"      flat spacetime with Euclidean coordinates for the
%                     spacelike dimensions.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    errorlevel = -0.001 * min( coordinateranges );
    d = length( coordinateranges );
    N = size( coordinates, 1 );
    if nargin < 3
        spacetime = 'Minkowski';
    end
    if strcmp( spacetime, 'Minkowski' )
        % set Minkowski metric:
        metrictime = zeros( d );
        metrictime( 1, 1 ) = 1;
        metric = 2 * metrictime - eye( d );
        % set all boundary offsets for periodic repeat:
        bndcount = 3^( d - 1 );
        bndoffsets = zeros( bndcount, d );
        for ibnd = 0 : ( bndcount - 1 )
            bndoffset = zeros( 1, d );
            bndpos = ibnd;
            for id = 2 : d
                bndoffset( id ) = ( mod( bndpos, 3 ) - 1 ) * coordinateranges( id );
                bndpos = floor( bndpos / 3 );
            end
            bndoffsets( ibnd + 1, : ) = bndoffset;
        end
        % compute links for each possible boundary offset (including the set itself):
        C = false( N );
        L = false( N );
        for j = 2 : N
            Jcoord = coordinates( j, : );
            for i = 1 : ( j - 1 )
                Icoord = coordinates( i, : );
                for jbnd = 1 : bndcount
                    Jshifted = Jcoord + bndoffsets( jbnd, : );
                    dcoordinates = Jshifted - Icoord;
                    causaldistanceIJ = dcoordinates * metric * transpose( dcoordinates );
                    if causaldistanceIJ >= errorlevel
                        C( i, j ) = true;
                        haslink = true;
                        for k = ( i + 1 ) : ( j - 1 )
                            for kbnd = 1 : bndcount
                                Kshifted = coordinates( k, : ) + bndoffsets( kbnd, : );
                                dcoordinates = Jshifted - Kshifted;
                                causaldistanceKJ = dcoordinates * metric * transpose( dcoordinates );
                                if causaldistanceKJ >= errorlevel
                                    C( k, j ) = true;
                                end
                                if C( i, k ) && C( k, j )
                                    haslink = false;
                                    break;
                                end
                            end
                            if ( haslink == false )
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
end

