function obj = createDiagram( srcobj, ac, plotpause, varargin )
%CREATEDIAGRAM    Creates a 2D pseudo-embedding of a Causet object. This 
%   gives an EmbeddedCauset object to draw a causet (Hasse) diagram.
% 
% Arguments:
% srcobj              Causet class object.
% 
% Optional arguments:
% present             Set of events that form a maximal antichain. 
%                     Default: (automatically determined)
% plotpause           Sets a pause time in ms for pausing after a plot in 
%                     every iteration to show the progress of the 
%                     embedding. 
%                     Default: 0 (no plotting)
% options             Further arguments for the plot function.
% 
% Returns:            
% obj                 The generated Embedded causet class object.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    if ( nargin < 2 ) || isempty( ac )
        ac = srcobj.CentralAntichain();
    end
    if ( nargin < 3 ) || isempty( plotpause )
        plotpause = 0;
    end
    
    %% initialize 2D embedded causet object:
    obj = embeddedcauset( 2, 'causet', srcobj );
    obj.addEvent( 'intervalfuture' );
    obj.Coords( obj.Card, : ) = NaN;
    [ all_perms, layer_indices ] = obj.Perms( ac, true );
    all_perms = all_perms{ 1 };
    layer_indices = layer_indices{ 1 };
    layer_indices( layer_indices == max( layer_indices ) ) = NaN;
    layers_past_count = length( all_perms{ 1 } );
    layers_future_count = ceil( max( layer_indices ) );
    layers_pf_count = min( layers_past_count, layers_future_count );
    if layers_past_count <= layers_future_count
        k_range = round( [ 0 : 0.5 : layers_pf_count, ...
            ( layers_pf_count + 1 ) : layers_future_count ] );
    else
        k_range = round( [ 0 : 0.5 : layers_pf_count, ...
            -( ( layers_pf_count + 1 ) : layers_past_count ) ] );
    end
    k_range_idx = 2 * ( 1 : layers_pf_count );
    k_range( k_range_idx ) = -k_range( k_range_idx );
    k_range_len = length( k_range );
    perm_idx = cell( 1, 3 );
    perm_idx{ 1 } = zeros( 1, layers_past_count );
    perm_idx{ 2 } = 0;
    perm_idx{ 3 } = zeros( 1, layers_future_count );
    %% find embedding with least link crossings up to permmax permutations:
    ki = 1;
    k = 0;
    k_abs = 1;
    k_sign = 2;
    permprod = 1;
    permprod_max = 500;
    linkX_idx = cell( 1, 1 );
    linkXmin = Inf;
    ki_max = 1;
    while ki <= k_range_len
        ac_perms = all_perms{ k_sign }{ k_abs };
        p = perm_idx{ k_sign }( k_abs ) + 1;
        permcount = size( ac_perms, 1 );
        if p <= permcount
            perm_idx{ k_sign }( k_abs ) = p;
        else % Exhausted all possibilities for the ki-th layer.
            perm_idx{ k_sign }( k_abs ) = 0;
            ki = ki - 1;
            if ki == 0
                break
            else
                continue
            end
        end
        placePerm( ac_perms( p, : ), k );
        linkX_idx{ ki } = p;
        if ki > ki_max
            ki_max = ki;
            permprod = permprod * permcount;
        end
        if ( permprod < permprod_max ) && ( ki < k_range_len )
            ki = ki + 1;
            k = k_range( ki );
            k_abs = max( 1, abs( k ) );
            k_sign = sign( k ) + 2;
            continue
        end
        if plotpause > 0
            %% plot progress:
            temp = [ obj.ShapeRanges; obj.Coords ];
            obj.ShapeRanges = [ min( temp, [], 1 ); ...
                                max( temp, [], 1 ) ];
            cla;
            obj.plot( varargin{:} );
            pause( plotpause );
        end
        linkX = obj.countLinkCrossings( ~isnan( obj.Coords( :, 1 ) )' );
        if linkX < linkXmin
            linkXmin = linkX;
            linkXmin_idx = linkX_idx;
            if linkX == 0 % it cannot get better
                break
            end
        end
    end
    %% use embedding with least link crossings for (up to) 3 layers:
    for ki = 1 : ki_max
        k = k_range( ki );
        k_abs = max( 1, abs( k ) );
        k_sign = sign( k ) + 2;
        ac_perms = all_perms{ k_sign }{ k_abs };
        placePerm( ac_perms( linkXmin_idx{ ki }, : ), k );
    end
    %% embed all other layers, minimizing the number of link crossings:
    for ki = ( ki_max + 1 ) : k_range_len
        k = k_range( ki );
        k_abs = max( 1, abs( k ) );
        k_sign = sign( k ) + 2;
        ac_perms = all_perms{ k_sign }{ k_abs };
        permcount = size( ac_perms, 1 );
        if k < 0
            temp = obj.PastInfOf( ~isnan( obj.Coords( :, 1 ) )' );
            set = [ temp, obj.Layers( temp, 1 ) ];
        else
            temp = obj.FutureInfOf( ~isnan( obj.Coords( :, 1 ) )' );
            set = [ temp, obj.Layers( temp, -1 ) ];
        end
        linkX = NaN( 1, permcount );
        for p = 1 : permcount
            placePerm( ac_perms( p, : ), k );
            linkX( p ) = obj.countLinkCrossings( set );
        end
        p = find( linkX == min( linkX ), 1 );
        placePerm( ac_perms( p, : ), k );
        if plotpause > 0
            %% plot progress:
            temp = [ obj.ShapeRanges; obj.Coords ];
            obj.ShapeRanges = [ min( temp, [], 1 ); ...
                                max( temp, [], 1 ) ];
            cla;
            obj.plot( varargin{:} );
            pause( plotpause );
        end
    end
    return
    
    %% place an antichain at the time coordinate given by the layer:
    function placePerm( ac, layernum )
        ac_len = length( ac );
        pos = ( 0 : ( ac_len - 1 ) )';
        ac_sub = ac( fix( layer_indices( ac ) ) == layernum );
        ac_sub_len = length( ac_sub );
        [ ac_sub_idx, ~ ] = find( ac_sub == ac' );
        obj.Coords( ac_sub, : ) = 0.1 * sin( 2 * pos( ac_sub_idx ) ) + ...
            [ layernum * ones( ac_sub_len, 1 ) / 2 + 0.05 * sin( layernum ), ...
            pos( ac_sub_idx ) - pos( ac_len ) / 2 ];
    end
end
