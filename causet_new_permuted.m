function coord = causet_new_permuted( permutation )
%CAUSET_NEW_PERMUTED creates a 1+1 dimensional causet from an permutation
% vector of integers. The permutation defines the lightlike v-coordinate,
% while the u-coordinate increases from 1 to the length of the permutation
% vector.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    N = length( permutation );
    coord = zeros( N, 2 );
    for i = 1 : N
        u = permutation( i );
        coord( i, : ) = [ 2 * N - i - u, i - u ];
    end
end

