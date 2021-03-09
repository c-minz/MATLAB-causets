% Copyright 2021, C. Minz. BSD 3-Clause License.

N = 7;
P = perms( 1:N );
keys = int64( ones( 1, factorial( N ) ) );
values = cell( factorial( N ), 1 );
groupcount = 0;
for i = 1 : size( P, 1 )
    coord = causet_new_permuted( P( i, : ) );
    C = causet_edit_relate( coord, metric( 2 ) );
    L = causet_get_links( C );
    Csum1 = transpose( sum( C, 1 ) );
    Csum2 = transpose( sum( C, 2 ) );
    Lsum2 = transpose( sum( L, 2 ) );
    key = int64(  length( find( Csum1 == 5 ) ) * 1e17 ...
                + length( find( Csum1 == 4 ) ) * 1e16 ...
                + length( find( Csum1 == 3 ) ) * 1e15 ...
                + length( find( Csum1 == 2 ) ) * 1e14 ...
                + length( find( Csum1 == 1 ) ) * 1e13 ...
                + length( find( Csum1 == 0 ) ) * 1e12 ...
                + length( find( Csum2 == 5 ) ) * 1e11 ...
                + length( find( Csum2 == 4 ) ) * 1e10 ...
                + length( find( Csum2 == 3 ) ) * 1e9 ...
                + length( find( Csum2 == 2 ) ) * 1e8 ...
                + length( find( Csum2 == 1 ) ) * 1e7 ...
                + length( find( Csum2 == 0 ) ) * 1e6 ...
                + length( find( Lsum2 == 5 ) ) * 1e5 ...
                + length( find( Lsum2 == 4 ) ) * 1e4 ...
                + length( find( Lsum2 == 3 ) ) * 1e3 ...
                + length( find( Lsum2 == 2 ) ) * 1e2 ...
                + length( find( Lsum2 == 1 ) ) * 1e1 ...
                + length( find( Lsum2 == 0 ) ) * 1e0 );
    key_index = find( keys == key );
    if isempty( key_index )
        groupcount = groupcount + 1;
        values{ groupcount } = i;
        keys( groupcount ) = key;
    else
        values{ key_index } = [ values{ key_index }, i ];
    end
end
len = 0;
for i = 1 : groupcount
    len = max( len, length( values{ i } ) );
end
for i = 1 : groupcount
    k = 0;
    clf;
    for j = values{ i }
        k = k + 1;
        coord = causet_new_permuted( P( j, : ) );
        C = causet_edit_relate( coord, metric( 2 ) );
        L = causet_get_links( C );
        subplot( 1, len, k );
        causet_plot( coord, L, [ 2, 1 ], 'ko', 'blue', 2 );
        title( j );
        xlim( [ -N - 0.5, N + 0.5 ] ); xticks( [] );
        ylim( [ -1.5, 2 * N - 0.5 ] ); yticks( [] );
    end
    pause
end
% causets = zeros( 1, groupcount );
% for i = 1 : groupcount
%     causets( i ) = values{ i }( 1 );
% end
