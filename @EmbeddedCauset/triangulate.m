function e_crds = triangulate( obj, e, ac, direction )
%TRIANGULATE    Triangulates the coordinate position of event e that has to
%   be element of the antichain ac. The parameter timedir (+/-1) specifies
%   whether the future or past solution is returned.
% 
% Arguments:
% obj                 Embeddedcauset class object.
% e                   Event to triangulate.
% ac                  Maximal antichain that includes e.
% 
% Optional arguments:
% direction           Triangulation direction in case there are more than
%                     one solution. Use either +1 (future) or -1 (past).
%                     Default: 1
% 
% Returns:
% e_crds              Triangulated coordinates of the event e.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 3, 4 );
    if nargin < 4
        direction = 1;
    end
    
    e_crds = [];
    prev_embedded = find( ~isnan( obj.Coords( :, 1 ) ) );
    ac_len = length( ac );
    if obj.Dim == 2
        i = find( ac == e );
        if isempty( i )
            if isempty( prev_embedded )
                e_crds = zeros( 1, obj.Dim );
            end
            return
        end
        if i == 1
            lft = [];
        else
            lft = [ ac( i - 1 ), obj.ConeOf( [ e, ac( i - 1 ) ], ...
                'links', true, 'lop', 'and' ) ];
        end
        if i > 2
            lft = causet.setor( [ lft, ac( i - 2 ) ], ...
                obj.ConeOf( [ e, ac( i - 2 ) ], ...
                'links', true, 'lop', 'and' ) );
        end
        if i == ac_len
            rgh = [];
        else
            rgh = [ ac( i + 1 ), obj.ConeOf( [ e, ac( i + 1 ) ], ...
                'links', true, 'lop', 'and' ) ];
        end
        if i < ac_len - 1
            rgh = Causet.setor( [ rgh, ac( i + 2 ) ], ...
                obj.ConeOf( [ e, ac( i + 2 ) ], ...
                'links', true, 'lop', 'and' ) );
        end
        lft = causet.setand( lft, prev_embedded );
        rgh = causet.setand( rgh, prev_embedded );
        len = length( lft ) + length( rgh );
        if len == 0
            if isempty( prev_embedded )
                e_crds = zeros( 1, obj.Dim );
            end
            return
        end
        if len == 1
            e1 = [ lft, rgh ];
            A = obj.ConeOf( [ e, e1 ], 'lop', 'xor', 'return', 'card' );
            l = sqrt( obj.Card );
            a = ( l - sqrt( l^2 - 2 * A ) ) / 2 / sqrt( 2 );
            if obj.isCausal( e, e1 )
                u = -a;
                v = -a;
            elseif obj.isCausal( e1, e )
                u = a;
                v = a;
            elseif isempty( lft )
                u = -a;
                v = a;
            else
                u = a;
                v = -a;
            end
            e_u = u + ( obj.Coords( e1, 1 ) + obj.Coords( e1, 2 ) ) / sqrt( 2 );
            e_v = v + ( obj.Coords( e1, 1 ) - obj.Coords( e1, 2 ) ) / sqrt( 2 );
            e_crds = [ e_u + e_v, e_u - e_v ] / sqrt( 2 );
            return
        end
        e_crds = zeros( 1, obj.Dim );
        lft_len = length( lft );
        rgh_len = length( rgh );
        for i = 1 : ( lft_len - 1 )
            for j = ( i + 1 ) : lft_len
                e_crds = e_crds + triangulate2D( obj, e, ...
                    lft( [ i, j ] ), [ direction, 1 ] );
            end
        end
        for i = 1 : lft_len
            for j = 1 : rgh_len
                e_crds = e_crds + triangulate2D( obj, e, ...
                    [ lft( i ), rgh( j ) ], [ direction, 0 ] );
            end
        end
        for i = 1 : ( rgh_len - 1 )
            for j = ( i + 1 ) : rgh_len
                e_crds = e_crds + triangulate2D( obj, e, ...
                    rgh( [ i, j ] ), [ direction, -1 ] );
            end
        end
        e_crds = e_crds / ( lft_len * ( lft_len - 1 ) / 2 ... 
                              + lft_len * rgh_len ...
                              + rgh_len * ( rgh_len - 1 ) / 2 );
    end
end

function e_crds = triangulate2D( obj, e, embedded, direction )
    if obj.Coords( embedded( 1 ), 2 ) < obj.Coords( embedded( 2 ), 2 )
        e1 = embedded( 1 );
        e2 = embedded( 2 );
    else
        e1 = embedded( 2 );
        e2 = embedded( 1 );
    end
    %% set parameters:
    l = sqrt( obj.Card );
    A1 = obj.ConeOf( [ e, e1 ], 'lop', 'xor', 'return', 'card' );
    A2 = obj.ConeOf( [ e, e2 ], 'lop', 'xor', 'return', 'card' );
    delta = obj.Coords( e2, : ) - obj.Coords( e1, : );
    u = abs( delta( 1 ) + delta( 2 ) ) / sqrt( 2 );
    v = abs( delta( 1 ) - delta( 2 ) ) / sqrt( 2 );
    % signs for the u coordinates:
    su1 = 1;
    su2 = 1;
    sv1 = 1;
    sv2 = 1;
    if obj.isCausal( e, e1 ) || ...
       ( obj.isSpacelikeTo( e, e1 ) && direction( 2 ) < 0 )
        su1 = -1;
    end
    if obj.isCausal( e2, e ) || ...
       ( obj.isSpacelikeTo( e, e2 ) && direction( 2 ) > 0 )
        su2 = -1;
    end
    if obj.isCausal( e1, e ) || ...
       ( obj.isSpacelikeTo( e, e1 ) && direction( 2 ) < 0 )
        sv1 = -1;
    end
    if obj.isCausal( e, e2 ) || ...
       ( obj.isSpacelikeTo( e, e2 ) && direction( 2 ) > 0 )
        sv2 = -1;
    end
    %% solve the system:
    %     A1 == u1 * ( l - v1 ) + v1 * ( l - u1 )
    %        == l * ( u1 + v1 ) - 2 * u1 * v1
    %     A2 == u2 * ( l - v2 ) + u2 * ( l - v2 )
    %        == l * ( u2 + v2 ) - 2 * u2 * v2
    %     u == su1 * u1 + su2 * u2
    %     v == sv1 * v1 + sv1 * v2
    % discriminant:
    dscr = ( - 2 * A1 * su1 * sv1 ...
             + 2 * A2 * su2 * sv2 ...
             + l^2 * ( su2 * sv1 - su1 * sv2) ...
             - 4 * u * v ...
             + 2 * l * ( ( sv1 + sv2 ) * u + ( su1 - su2 ) * v) )^2 ...
         - 8 * su2 * ( l * ( sv1 + sv2 ) - 2 * v ) ...
             * ( - A1 * l * su1 * sv1 ...
                 + A2 * sv2 * ( - l * su1 + 2 * u ) ...
                 + l * ( l * sv1 * u + l * su1 * v - 2 * u * v ) );
    if dscr <= 0
        delta = ( obj.Coords( e2, : ) - obj.Coords( e1, : ) ) / 2;
        if direction( 2 ) < 0
            e_crds = obj.Coords( e1, : ) - delta;
        elseif direction( 2 ) > 0
            e_crds = obj.Coords( e2, : ) + delta;
        else
            e_crds = obj.Coords( e1, : ) + delta;
        end
        return
    end
    % solution for u1:
    u1_nom = 2 * A1 * su1 * sv1 ...
           - l^2 * ( su2 * sv1 - su1 * sv2 ) ...
           - 2 * A2 * su2 * sv2 ...
           + 2 * l * ( sv1 + sv2 ) * u ...
           - 2 * l * ( su1 - sv2 ) * v ...
           - 4 * u * v;
    u1_denom = 4 * l * su1 * ( sv1 + sv2 ) - 8 * su1 * v;
    if ( direction( 1 ) < 0 ) && ...
       obj.isSpacelikeTo( e, e1 ) && obj.isSpacelikeTo( e, e2 )
        u1 = ( u1_nom - sqrt( dscr ) ) / u1_denom;
    else
        u1 = ( u1_nom + sqrt( dscr ) ) / u1_denom;
    end
    v1 = ( A1 - l * u1 ) / ( l - 2 * u1 );
    if obj.isCausal( e, e1 ) || ...
       ( obj.isSpacelikeTo( e, e1 ) && direction( 2 ) == -1 )
        u1 = -u1;
    end
    if obj.iscausal( e, e1 ) || ...
       ( obj.isSpacelikeTo( e, e1 ) && direction( 2 ) >= 0 )
        v1 = -v1;
    end
    %% convert to Cartesian coordinates:
    e_u = u1 + ( obj.Coords( e1, 1 ) + obj.Coords( e1, 2 ) ) / sqrt( 2 );
    e_v = v1 + ( obj.Coords( e1, 1 ) - obj.Coords( e1, 2 ) ) / sqrt( 2 );
    e_crds = [ e_u + e_v, e_u - e_v ] / sqrt( 2 );
end

