function [ plotobj, dims, handles ] = diagram( obj, varargin )
%DIAGRAM    Creates an embedding of the causet and plots the result.
% 
% Arguments:
% obj                 Causet class object.
% 
% Optional arguments: (each key has to be followed by a value)
% 'Antichain'         Set of events that form a maximal antichain. Every
%                     embedding attempt will start with this antichain. If
%                     unset, multiple antichains will be tested.
%                     Default: (automatically determined)
% 'ShowProgress'      Boolean value that determines if a description and a 
%                     progress bar is displayed for the embedding search.
%                     Default: true
% 'Timeout'           Positive double value to set a timeout for each
%                     embedding attempt in seconds.
%                     Default: Inf (no timeout)
% 'Plotpause'         Positive double value to set a pause time after
%                     plotting the current embedding iteration with the
%                     same plotting options that are passed as further
%                     key-value pairs.
%                     Default: 0 (no plotting of intermediate steps)
% ( ... )             See @embeddedcauset.plot
% 
% Returns:            
% plotobj             The generated Embedded causet class object or [] if
%                     the embedding search failed.
% dims, handles       See @embeddedcauset.plot
    
    plotargsbegin = 1;
    ac = [];
    showprogress = true;
    plotpause = 0;
    timeout = Inf;
    for i = 1:2:length( varargin )
        key = lower( varargin{ i } );
        value = varargin{ i + 1 };
        if strcmp( key, 'antichain' )
            ac = value;
        elseif strcmp( key, 'showprogress' )
            showprogress = value;
        elseif strcmp( key, 'plotpause' )
            plotpause = value;
        elseif strcmp( key, 'timeout' )
            timeout = value;
        else
            break
        end
        plotargsbegin = plotargsbegin + 2;
    end
    resetantichain = isempty( ac );
    
    plotobj = causet( obj.C );
    plotobj.addevent( 'intervalfuture' );
    varargin = varargin( plotargsbegin : ( nargin - 1 ) );
    if ~resetantichain
        resetrange = ac( 1 );
    else
        resetrange = round( 0 : 0.5 : ( plotobj.card - 0.9 ) / 2 );
        resetrange( 2 : 2 : length( resetrange ) ) = ...
            -resetrange( 2 : 2 : length( resetrange ) );
        resetrange = resetrange + ceil( ( plotobj.card + 0.1 ) / 2 );
    end
    plotobjs = [];
    for m = 1 : 4
        ac_available = true( 1, plotobj.card );
        for e = resetrange
            if resetantichain
                if ~ac_available( e )
                    continue
                end
                ac = plotobj.centralantichain( e );
            end
            ac_available( ac ) = false;
            %% show progress:
            if showprogress
                cla;
                prog = ( sum( ~ac_available ) - 1 ) / plotobj.card;
                text( 0, 0, sprintf( [ 'Searching for a 2D Minkowski ', ...
                    'embedding \n(by method %d). Starting from an antichain \n', ...
                    'through event %d.\n\n', ...
                    'Exhausted configurations:\n' ], m, e ), ...
                    'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom' );
                if prog < 0.5
                    col = 2 * prog * [ 0.9, 0, 0 ] + [ 0, 0.9, 0.1 ];
                else
                    col = 2 * ( prog - 0.5 ) * [ 0, -0.9, 0 ] + [ 0.9, 0.9, 0.1 ];
                end
                line( [ 0, prog ], [ 0, 0 ], 'LineWidth', 10, 'Color', col );
                text( prog, 0, sprintf( ' %.0f%%', prog * 100 ), ...
                    'HorizontalAlignment', 'left' );
                axis equal;
                xlim( [ 0, 1.2 ] );
                axis off;
                pause( 0.001 );
            end
            %% try embedding:
            plotobjs = embeddedcauset.create( plotobj, ac, m, ...
                timeout, plotpause, varargin{:} );
            if ~isempty( plotobjs ) % embedding found
                break
            end
        end
        if ~isempty( plotobjs ) % embedding found
            break
        end
    end
    %% plot and return:
    cla;
    if isempty( plotobjs )
        % embedding failed, empty return:
        plotobj = [];
        dims = [];
        handles = struct();
    else
        % embedding successful, empty return:
        plotobj = plotobjs{ 1 };
        plotobj.removeevents( plotobj.card );
        [ dims, handles ] = plotobj.plot( 'AxisLimits', 'auto', varargin{:} );
        axis off;
    end
end

function newdiagram( plotobj, present )
    %obj = embeddedcauset( d, 'causet', srcobj.subcauset( set ) );
    l = sqrt( plotobj.card );
    [ all_perms, layer_indices ] = plotobj.perms( present, true );
    layers_past_count = length( all_perms{ 1 } );
    layers_future_count = length( all_perms{ 3 } );
    perm_idx = cell( 1, 3 );
    perm_idx{ 1 } = zeros( 1, layers_past_count );
    perm_idx{ 2 } = 0;
    perm_idx{ 3 } = zeros( 1, layers_future_count );
    %% find embedding with least link crossings for (up to) 3 layers:
    if ( layers_past_count == 0 ) && ( layers_future_count == 0 )
        perms_counts = [ size( all_perms{ 2 }{ 1 }, 1 ), 1, 1 ];
        k_prerange = 0;
    elseif layers_past_count == 0
        perms_counts = [ size( all_perms{ 2 }{ 1 }, 1 ), ...
                         size( all_perms{ 3 }{ 1 }, 1 ) ];
        if layers_future_count > 1
            perms_counts = [ perms_counts, size( all_perms{ 3 }{ 2 }, 1 ) ];
            k_prerange = 0 : 2;
        else
            perms_counts = [ perms_counts, 1 ];
            k_prerange = 0 : 1;
        end
    elseif layers_future_count == 0
        perms_counts = [ size( all_perms{ 1 }{ 1 }, 1 ), ...
                         size( all_perms{ 2 }{ 1 }, 1 ) ];
        if layers_future_count > 1
            perms_counts = [ size( all_perms{ 1 }{ 2 }, 1 ), perms_counts ];
            k_prerange = -2 : 0;
        else
            perms_counts = [ perms_counts, 1 ];
            k_prerange = -1 : 0;
        end
    else
        perms_counts = [ size( all_perms{ 1 }{ 1 }, 1 ), ...
                         size( all_perms{ 2 }{ 1 }, 1 ), ...
                         size( all_perms{ 3 }{ 1 }, 1 ) ];
        k_prerange = -1 : 1;
    end
    linkXcounts = NaN( perms_counts );
    k_prerange_len = length( k_prerange );
    ki = 1;
    linkX_idx = cell( 1, k_prerange_len );
    while ki <= k_prerange_len
        k = k_prerange( ki );
        k_abs = max( 1, abs( k ) );
        k_sign = sign( k ) + 2;
        ac_perms = all_perms{ k_sign }{ k_abs };
        p = perm_idx{ k_sign }( k_abs ) + 1;
        linkX_idx{ ki } = p;
        if p <= perms_counts( ki )
            perm_idx{ k_sign }( k_abs ) = p;
        else % Exhausted all possibilities for the ki-th layer.
            ki = ki - 1;
            if ki == 0
                break
            else
                continue
            end
        end
        placeperm( ac_perms( p, : ), k );
        if ki < ki_max
            ki = ki + 1;
            continue
        end
        linkX = plotobj.countlinkcrossings( ~isnan( obj.coords( :, 1 ) )' );
        linkXcounts( linkX_idx{:} ) = linkX;
        if linkX == 0 % it cannot get better
            break
        end
    end
    %% use embedding with least link crossings for (up to) 3 layers:
    p = find( linkXcounts == min( min( min( linkXcounts ) ) ), 1 );
    p = floor( [ ...
        mod( p, perms_counts( 2 ) * perms_counts( 3 ) ) / perms_counts( 1 ), ...
        mod( p, perms_counts( 3 ) ) / perms_counts( 2 ), ...
        p / perms_counts( 3 ) ] );
    for ki = 1 : k_prerange_len
        k = k_prerange( ki );
        k_abs = max( 1, abs( k ) );
        k_sign = sign( k ) + 2;
        ac_perms = all_perms{ k_sign }{ k_abs };
        placeperm( ac_perms( p( ki ), : ), k );
    end
    %% embed all other layers, minimizing the number of link crossings:
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
    for k = k_range
        if ~isempty( find( k == k_prerange, 1 ) )
            continue
        end
        k_abs = max( 1, abs( k ) );
        k_sign = sign( k ) + 2;
        ac_perms = all_perms{ k_sign }{ k_abs };
        p_max = size( ac_perms, 1 );
        if k < 0
            temp = obj.pastinfof( ~isnan( obj.coords( :, 1 ) )', 'set' );
            set = [ temp, obj.layer( temp, 1 ) ];
        else
            temp = obj.futureinfof( ~isnan( obj.coords( :, 1 ) )', 'set' );
            set = [ temp, obj.layer( temp, -1 ) ];
        end
        linkX = NaN( 1, p_max );
        for p = 1 : p_max
            placeperm( ac_perms( p, : ), k );
            linkX( p ) = obj.countlinkcrossings( set );
        end
        p = find( linkX == min( linkX ), 1 );
        placeperm( ac_perms( p, : ), k );
    end
    return
    
    %% place an antichain at the time coordinate given by the layer:
    function placeperm( ac, layernum )
        ac_len = length( ac );
        pos = zeros( ac_len, 1 );
        for ii = 2 : ac_len
            A = plotobj.coneof( ac( [ ii - 1, ii ] ), 'xor', 'card' );
            pos( ii ) = pos( ii - 1 ) + ...
                sqrt( 2 ) * real( l - sqrt( l^2 - 2 * A ) ) / 2;
        end
        ac_sub = ac( fix( layer_indices( ac ) ) == layernum );
        ac_sub_len = length( ac_sub );
        [ ac_sub_idx, ~ ] = find( ac_sub == ac' );
        plotobj.coords( ac_sub, : ) = ...
            [ layernum * ones( ac_sub_len, 1 ) / 2, ...
            pos( ac_sub_idx ) - pos( ac_len ) / 2 ];
    end
end
