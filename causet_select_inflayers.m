function inflayers = causet_select_inflayers( C, L, layers )
%CAUSET_SELECT_INFLAYERS returns a N-vector holding the layer numbers of 
% the future/past infinity up to LAYERS for each element in the causet. 
% Unidentified elements are returned as NaN.
% Use Inf and -Inf to address 0 layer future/past infinity and values 
% LAYERS > 0 for future, LAYERS < 0 for past.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    N = size( C, 1 );
    inflayers = NaN * zeros( 1, N ); % pre-allocate memory
    if layers >= 0 % find future infinity layers:
        direction = 1;
        inflayers( sum( C, 2 ) == 0 ) = 0;
    else % find past infinity layers:
        direction = -1;
        layers = -layers;
        inflayers( sum( C, 1 ) == 0 ) = 0;
    end
    if isinf( layers )
        layers = 0; % +/-Inf represents +/-0
    end
    for i = 1 : N
        if isnan( inflayers( i ) ) % not yet identified
            % number of links of the i-th element:
            if direction > 0
                linkcount = sum( L( i, : ) );
            else
                linkcount = sum( L( :, i ) );
            end
            % find an empty layer of the i-th element:
            inflayer = NaN; % holds step of inf
            for el = 1 : ( layers + 1 )
                if isempty( causet_find_layer( C, i, direction * el ) )
                    % el layer is empty:
                    inflayer = el - 1;
                    % check all further layers to be empty as well:
                    for el2 = inflayer + ( 2 : linkcount )
                        if ~isempty( causet_find_layer( C, i, direction * el2 ) )
                            % false alarm, reset:
                            inflayer = NaN;
                            break
                        end
                    end
                    if ~isnan( inflayer )
                        break
                    end
                end
            end
            if ~isnan( inflayer )
                inflayers( i ) = inflayer;
            end
        end
    end
end

