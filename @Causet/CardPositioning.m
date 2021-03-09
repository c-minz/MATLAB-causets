function varargout = CardPositioning( obj, e, ac )
%CARDPOSITIONING    For 1 + 1 Minkowski space embeddings, it returns six
%   coordinate pairs that are computed from the four cardinalities of the
%   past lightcone (C_p), the future lightcone (C_f), the left region
%   (C_l), and the right region (C_r). It assumes that the causet obj is an
%   Alexandrov interval and e is an element of the maximal antichain ac.
% 
% Arguments:
% obj                 Causet class object.
% e                   Event for which the position is estimated.
% ac                  Maximal antichain that includes e.
% 
% Returns:
% { u, v }            Column vectors of six lightcone coordiantes u and v.
% P                   Matrix of Cartesian coordinates for six points.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 3, 3 );
    varargout = cell( 1, nargout );
    
    %% set parameter:
    i = find( ac == e, 1 );
    if isempty( i )
        return
    end
    ac_len = length( ac );
    C_p = obj.PastOf( e, 'return', 'card' ); % past cardinality
    C_f = obj.FutureOf( e, 'return', 'card' ); % future cardinality
    C_lcone = obj.ConeOf( ac( 1 : ( i - 1 ) ), ...
        'origins', true, 'return', 'sel' );
    C_rcone = obj.ConeOf( ac( ( i + 1 ) : ac_len ), ...
        'origins', true, 'return', 'sel' );
    C_l = sum( C_lcone & ~C_rcone ); % size of the left region
    C_r = sum( ~C_lcone & C_rcone ); % size of the right region
    l = sqrt( obj.Card );
    C_pl = C_p + C_l;
    C_pr = C_p + C_r;
    C_fl = C_f + C_l;
    C_fr = C_f + C_r;
    %% compute coordinates:
    u = zeros( 6, 1 );
    v = zeros( 6, 1 );
    % using past and left region:
    u( 1 ) = C_pl / l - l / 2;
    if C_pl == 0
        if C_fr > 0
            v( 1 ) = l / 2 * ( C_r - C_f ) / C_fr;
        else
            v( 1 ) = 0;
        end
    else
        v( 1 ) = l / 2 * ( C_p - C_l ) / C_pl;
    end
    % using past and right region:
    v( 2 ) = C_pr / l - l / 2;
    if C_pr == 0
        if C_fl > 0
            u( 2 ) = l / 2 * ( C_f - C_l ) / C_fl;
        else
            u( 2 ) = 0;
        end
    else
        u( 2 ) = l / 2 * ( C_p - C_r ) / C_pr;
    end
    % using past and future region:
    dscrroot = sqrt( max( 0, ( C_p - C_f )^2 - 2 * l^2 * ( C_p + C_f ) + l^4 ) );
    if dscrroot > 0
        if C_l == C_r
            dscrroot = 0;
        elseif C_l < C_r
            dscrroot = -dscrroot;
        end
    end
    u( 3 ) = ( C_p - C_f + dscrroot ) / ( 2 * l );
    if abs( u( 3 ) ) == l / 2
        if C_fr > 0
            v( 3 ) = l / 2 * ( C_r - C_f ) / C_fr;
        else
            v( 3 ) = 0;
        end
    else
        v( 3 ) = C_p / ( l / 2 + u( 3 ) ) - l / 2;
    end
    % using future and left region:
    v( 4 ) = l / 2 - C_fl / l;
    if C_fl == 0
        if C_pr > 0
            u( 4 ) = l / 2 * ( C_p - C_r ) / C_pr;
        else
            u( 4 ) = 0;
        end
    else
        u( 4 ) = l / 2 * ( C_l - C_f ) / C_fl;
    end
    % using future and right region:
    u( 5 ) = l / 2 - C_fr / l;
    if C_fr == 0
        if C_pl > 0
            v( 5 ) = l / 2 * ( C_r - C_f ) / C_pl;
        else
            v( 5 ) = 0;
        end
    else
        v( 5 ) = l / 2 * ( C_r - C_f ) / C_fr;
    end
    % using left and right region:
    dscrroot = sqrt( max( 0, ( C_l - C_r )^2 - 2 * l^2 * ( C_l + C_r ) + l^4 ) );
    if dscrroot > 0
        if C_p == C_f
            dscrroot = 0;
        elseif C_p < C_f
            dscrroot = -dscrroot;
        end
    end
    u( 6 ) = ( C_l - C_r + dscrroot ) / ( 2 * l );
    if abs( u( 6 ) ) == l / 2
        if C_fr > 0
            v( 6 ) = l / 2 * ( C_r - C_f ) / C_fr;
        else
            v( 6 ) = 0;
        end
    else
        v( 6 ) = C_r / ( l / 2 - u( 6 ) ) - l / 2;
    end
    if nargout == 2
        varargout{ 1 } = u;
        varargout{ 2 } = v;
        return
    end
    varargout{ 1 } = [ u + v, u - v ] / sqrt( 2 );
end

