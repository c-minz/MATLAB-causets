function n = countLinkCrossings( obj, list, dims, includeEndPoints )
%COUNTLINKCROSSINGS    Returns the number of link crossings between the 
%   events in list when observing from the two dimensions dims.
%   
% Arguments:
% obj                 Embeddedcauset class object.
% list                Logical selection vector or set of events.
% 
% Optional arguments:
% dims                Two coordinate dimension indices for which the 
%                     intersection number should be computed.
%                     Default: [ 1, 2 ]
% includeendpoints    Boolean flag to include the line endpoints.
%                     Default: true (line endpoints are included)
% 
% Results:
% n                   Number of crossed links in the given embedding
%                     between events of alist and blist.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 2, 4 );
    if nargin < 3
        dims = [ 1, 2 ];
    end
    if nargin < 4
        includeEndPoints = true;
    end
    list = obj.setof( list );
    list_len = length( list );
    n = 0;
    for i = 1 : list_len
        e_i = list( i );
        list_i = obj.futureof( e_i, 'set', 'uselinks', { 'partof', list } );
        if isempty( list_i )
            continue
        end
        for j = ( i + 1 ) : list_len
            e_j = list( j );
            if e_i == e_j
                continue
            end
            list_j = obj.futureof( e_j, 'set', 'uselinks', { 'partof', list } );
            if isempty( list_j )
                continue
            end
            for e_k = list_i
                if e_j == e_k
                    continue
                end
                for e_l = list_j
                    if e_k == e_l
                        continue
                    end
                    if hasIntersection( obj.coords( e_i, dims ), ...
                                        obj.coords( e_k, dims ), ...
                                        obj.coords( e_j, dims ), ...
                                        obj.coords( e_l, dims ), ...
                                        includeEndPoints )
                        n = n + 1;
                    end
                end
            end
        end
    end
end

%% See https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/

function o = OrientationOf( p1, p2, p3 )
    o = sign( ( p2( 1 ) - p1( 1 ) ) * ( p3( 2 ) - p2( 2 ) ) ...
            - ( p2( 2 ) - p1( 2 ) ) * ( p3( 1 ) - p2( 1 ) ) );
end

function bool = ColinearIsBetween( p_beg, p_mid, p_end )
    if ( p_mid( 1 ) <= max( p_beg( 1 ), p_end( 2 ) ) ) && ...
       ( p_mid( 1 ) >= min( p_beg( 1 ), p_end( 2 ) ) ) && ...
       ( p_mid( 2 ) <= max( p_beg( 2 ), p_end( 2 ) ) ) && ...
       ( p_mid( 2 ) >= min( p_beg( 2 ), p_end( 2 ) ) )
        bool = true;
    else
        bool = false;
    end
end

function bool = hasIntersection( p1, q1, p2, q2, includeEndPoints )
    o1 = OrientationOf( p1, q1, p2 );
    o2 = OrientationOf( p1, q1, q2 );
    o3 = OrientationOf( p2, q2, p1 );
    o4 = OrientationOf( p2, q2, q1 );
    if ( o1 ~= o2 ) && ( o3 ~= o4 )
        bool = true;
    elseif includeEndPoints
        if ( o1 == 0 ) && ColinearIsBetween( p1, p2, q1 )
            bool = true;
        elseif ( o2 == 0 ) && ColinearIsBetween( p1, q2, q1 )
            bool = true;
        elseif ( o3 == 0 ) && ColinearIsBetween( p2, p1, q2 )
            bool = true;
        elseif ( o4 == 0 ) && ColinearIsBetween( p2, q1, q2 )
            bool = true;
        else
            bool = false;
        end
    else
        bool = false;
    end
end
