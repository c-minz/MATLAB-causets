function infevents = causet_find_inflayers( C, L, layers )
%CAUSET_FIND_INFLAYERS returns the indices of the k-th layer future/past 
% infinity by applying a find over the result of CAUSET_SELECT_INFLAYERS.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    infevents = find( ~isnan( causet_select_inflayers( C, L, layers ) ) );
end

