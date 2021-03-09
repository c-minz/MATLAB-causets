function objs = create( srcobj, ac, method, timeout, plotpause, varargin )
%CREATE    Assign coordinates to the events such that the causal structure
%   is represented when converting a Causet object to an EmbeddedCauset
%   object.
% 
% Arguments:
% srcobj              Causet class object to be embedded.
% 
% Optional arguments:
% ac                  Set of events that form a maximal antichain.
%                     Default: [] (so that srcobj.centralantichain() 
%                                  is used)
% method              Index of the method to be used. 
%                     Default: 1
%        1 or 'auto'  "homogeneous embedding" using the cardpositioning 
%                     method for all layers.
%                2    "almost homogeneous embedding" using the 
%                     cardpositioning method for all but the first layer.
%                3    "clustering embedding" using the triangulation 
%                     method.
%                4    "clustering embedding" using the origin as fix point.
% timeout             Timeout in seconds for each embedding of an 
%                     antichain piece. 
%                     Default: Inf (no timeout)
% plotpause           Sets a pause time in ms for pausing after a plot in 
%                     every iteration to show the progress of the 
%                     embedding. 
%                     Default: 0 (no plotting)
% options             Further arguments for the plot function.
% 
% Returns:
% objs                Cell array of (spacelike separated) embedded causet 
%                     objects. If the embedding for an object failed, an
%                     empty set for this element is returned.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    if ( nargin < 2 ) || isempty( ac )
        ac = srcobj.CentralAntichain();
    end
    if ( nargin < 3 ) || isempty( method ) || strcmp( method, 'auto' )
        method = 1;
    end
    if nargin < 4
        timeout = Inf;
    end
    if nargin < 5
        plotpause = 0;
    end
    
    %% estimate dimension:
    d = 2; % other dimensions are not implemented
    %% find the spacelike separated pieces:
    ac = srcobj.PastInfOf( ac, 'return', 'set' );
    piece_poss = srcobj.AntichainPerms( ac );
    piece_count = length( piece_poss );
    objs = cell( 1, piece_count ); % pre-allocate
    objs_count = 0;
    %% run through spaelike separated pieces:
    for piece_idx = 1 : piece_count
        continue_nextpiece = false;
        timing = tic();
        %% create embedded causet object for current piece:
        piece_ac = piece_poss{ piece_idx }( 1, : );
        set = srcobj.ConeOf( piece_ac, 'origins', true );
        obj = EmbeddedCauset( d, 'causet', srcobj.SubCauset( set ) );
        [ present, ~ ] = find( set' == piece_ac );
        present = sort( present )';
        %% find permutations for each layer starting at present:
        [ scomplexes, layer_indices ] = obj.Perms( present );
        scomplexes = scomplexes{ 1 };
        layers_past_count = length( scomplexes{ 1 } );
        layers_future_count = length( scomplexes{ 3 } );
        scomplex_idx = cell( 1, 3 );
        scomplex_idx{ 1 } = zeros( 1, layers_past_count );
        scomplex_idx{ 2 } = 0;
        scomplex_idx{ 3 } = zeros( 1, layers_future_count );
        layer_indices = layer_indices{ 1 };
        %% place layers:
        k_range_temp = min( layers_past_count, layers_future_count );
        if layers_past_count <= layers_future_count
            k_range = round( [ 0 : 0.5 : k_range_temp, ...
                ( k_range_temp + 1 ) : layers_future_count ] );
        else
            k_range = round( [ 0 : 0.5 : k_range_temp, ...
                -( ( k_range_temp + 1 ) : layers_past_count ) ] );
        end
        k_range_temp = 2 * ( 1 : k_range_temp );
        k_range( k_range_temp ) = -k_range( k_range_temp );
        k_range_len = length( k_range );
        ki = 1;
        rewind_max = 10;
        rewind = 0;
        l = sqrt( obj.Card );
        while ki <= k_range_len
            if toc( timing ) > timeout % timeout
                continue_nextpiece = true;
                break
            end
            %% select simplicial complex (permutation):
            k = k_range( ki );
            k_abs = max( 1, abs( k ) );
            k_sign = sign( k ) + 2;
            scomplex = scomplexes{ k_sign }{ k_abs };
            if isempty( scomplex )
                continue_nextpiece = true;
                break
            end
            p = scomplex_idx{ k_sign }( k_abs ) + 1;
            if p <= size( scomplex, 1 )
                scomplex_idx{ k_sign }( k_abs ) = p;
            else % Exhausted all possibilities for the ki-th layer.
                if k == 0
                    prev_ac = [];
                else
                    prev_k = k_range( ki - 1 );
                    prev_scomplex = ...
                        scomplexes{ sign( prev_k ) + 2 }{ max( 1, abs( prev_k ) ) };
                    prev_ac = prev_scomplex( 1, : );
                end
                % rewind to previous layer:
                ki = ki - 1;
                rewind = rewind + 1;
                if ( ki == 0 ) || ( rewind >= rewind_max )
                    % ERROR: Embedding failed.
                    continue_nextpiece = true;
                    break
                end
                % reset spacial coordinates (to NaN):
                p = p - 1;
                k = k_range( ki );
                if p > 0
                    reset = prev_ac( fix( layer_indices( prev_ac ) ) == k );
                    obj.Coords( reset, : ) = nan;
                    scomplex_idx{ k_sign }( k_abs ) = 0;
                end
                continue
            end
            rewind = 0;
            ac = scomplex( p, : );
            ac_len = length( ac );
            %% Does the antichain match to previously embedded events?
            if k < 0
                prev_ac = obj.PastInfOf( ~isnan( obj.Coords( :, 1 ) )' );
            elseif k > 0
                prev_ac = obj.PastInfOf( ~isnan( obj.Coords( :, 1 ) )' );
            end
            if k ~= 0
                ismatching = true;
                [ ac_emb, ~ ] = find( ac' == intersect( prev_ac, ac ) );
                ac_emb_len = length( ac_emb );
                for i = 1 : ( ac_emb_len - 1 )
                    if obj.Coords( i, 2 ) > obj.Coords( i + 1, 2 )
                        ismatching = false;
                        break
                    end
                end
                if ~ismatching
                    continue % goto next permutation
                end
            end
            %% embed layer:
            isfailed = false;
            if ( method > 1 ) && ( k == 0 )
                pos = zeros( ac_len, 1 );
                for i = 2 : ac_len
                    A = obj.ConeOf( ac( [ i - 1, i ] ), ...
                        'lop', 'xor', 'return', 'card' );
                    pos( i ) = pos( i - 1 ) + ...
                        sqrt( 2 ) * real( l - sqrt( l^2 - 2 * A ) ) / 2;
                end
                ac_sub = ac( fix( layer_indices( ac ) ) == k );
                [ ac_sub_idx, ~ ] = find( ac_sub == ac' );
                obj.Coords( ac_sub, : ) = ...
                    [ 0, pos( ac_sub_idx ) - pos( ac_len ) / 2 ];
            else
                k_sign = sign( k );
                if k == 0
                    k_sign = 1;
                end
                for e = ac
                    if ( fix( layer_indices( e ) ) == k ) && ...
                       isnan( obj.Coords( e, 1 ) ) && ...
                       isempty( obj.embedEvent( e, ac, k_sign, method ) )
                        isfailed = true;
                        break
                    end
                    if k == 0
                        k_sign = -k_sign;
                    end
                end
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
            if isfailed
                obj.Coords( ac( fix( layer_indices( ac ) ) == k ), : ) = nan;
                continue % goto next permutation
            end
            %% goto next layer:
            ki = ki + 1;
        end
        if continue_nextpiece
            continue
        end
        %% set shape:
        cranges = zeros( 2, d );
        for k = 1 : d
            cranges( :, k ) = ...
                [ min( obj.Coords( :, k ) ); max( obj.Coords( :, k ) ) ];
        end
        obj.initShape( d, 'cuboid', cranges );
        objs_count = objs_count + 1;
        objs{ objs_count } = obj;
    end
    %% remove pre-allocation:
    objs = objs( 1, 1 : objs_count );
end
