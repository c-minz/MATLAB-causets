function e_crds = embedEvent( obj, e, ac, direction, method )
%EMBEDEVENT    Attempts to assign coordinates to the event e that is part
%   of the given maximal antichain. 
% 
% Arguments:
% obj                 Embeddedcauset class object.
% e                   Index of the event to find its embedding region.
% 
% Optional arguments:
% ac                  Maximal antichain that includes e.
% direction           Triangulation direction in case there are more than
%                     one solution. Use either +1 (future) or -1 (past).
%                     Default: 1
% method              Index of the method to be used. Default: 1
%                1    "homogeneous embedding" using the cardpositioning 
%                     method for all layers.
%                2    "almost homogeneous embedding" using the 
%                     cardpositioning method for all but the first layer.
%                3    "clustering embedding" using the triangulation 
%                     method.
%                4    "clustering embedding" using the origin as fix point.
% 
% Returns:
% e_crds              Determined embedding coordinates of the event e. 
%                     It is empty if the embedding failed (usually because
%                     there is no available embedding region).
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 2, 5 );
    if nargin < 3
        ac = obj.CentralAntichain( e );
    end
    if nargin < 4
        direction = 1;
    end
    if nargin < 5
        method = 1;
    end
    
    e_crds = [];
    if obj.Dim == 2
        ac_len = length( ac );
        %% get embedding region:
        i = find( ac == e, 1 );
        if isempty( i )
            return
        end
        % left:
        if i == 1
            left = false( 1, obj.Card );
        elseif ( i > 1 )
            left = obj.ConeOf( ac( 1 : ( i - 1 ) ), ...
                'origins', true, 'return', 'sel' ) & ...
                ~obj.ConeOf( ac( i ), 'origins', true, 'return', 'sel' );
        end
        % right:
        if i == ac_len
            right = false( 1, obj.Card );
        else
            right = obj.ConeOf( ac( ( i + 1 ) : ac_len ), ...
                'origins', true, 'return', 'sel' ) & ...
                ~obj.ConeOf( ac( i ), 'origins', true, 'return', 'sel' );
        end
        R = obj.EmbeddingRegion( ac( i ), [ left; right ] );
        if isempty( R )
            return
        end
        padding = 0.25;
        u_range = R( :, 1 ) + [ padding; -padding ];
        v_range = R( :, 2 ) + [ padding; -padding ];
        if u_range( 1 ) > u_range( 2 )
            u_range = sum( u_range ) / 2 * ones( 1, 2 );
        end
        if v_range( 1 ) > v_range( 2 )
            v_range = sum( v_range ) / 2 * ones( 1, 2 );
        end
        %% find the position:
        u = [];
        v = [];
        if method == 3
            %% trianglate:
            e_crds = real( obj.triangulate( e, ac, direction ) );
            if ~isempty( e_crds )
                u = ( e_crds( 1 ) + e_crds( 2 ) ) / sqrt( 2 );
                v = ( e_crds( 1 ) - e_crds( 2 ) ) / sqrt( 2 );
            end
        else
            %% use cardinalities of past, future, left and right:
            [ u, v ] = obj.CardPositioning( e, ac );
            dist = zeros( 6, 1 );
            for i_sol = 1 : 6
                if u( i_sol ) < u_range( 1 )
                    dist( i_sol ) = u_range( 1 ) - u( i_sol );
                elseif u( i_sol ) > u_range( 2 )
                    dist( i_sol ) = u( i_sol ) - u_range( 2 );
                end
                if v( i_sol ) < v_range( 1 )
                    dist( i_sol ) = max( dist( i_sol ), ...
                        v_range( 1 ) - v( i_sol ) );
                elseif v( i_sol ) > v_range( 2 )
                    dist( i_sol ) = max( dist( i_sol ), ...
                        v( i_sol ) - v_range( 2 ) );
                end
            end
            dist_min = dist == min( dist );
            u = mean( u( dist_min ) );
            v = mean( v( dist_min ) );
        end
        if ~isempty( u ) && ~isempty( v )
            if u < u_range( 1 )
                u = u_range( 1 );
            elseif u > u_range( 2 )
                u = u_range( 2 );
            end
            if v < v_range( 1 )
                v = v_range( 1 );
            elseif v > v_range( 2 )
                v = v_range( 2 );
            end
            e_crds = [ u + v, u - v ] / sqrt( 2 );
            obj.Coords( e, : ) = e_crds;
        end
    end
end
