% Copyright 2021, C. Minz. BSD 3-Clause License.

function runjobs_timing( N, d )
    tstart = tic;
    g = metric( d );
    fprintf( 'Timing causet with N = %d, d = %d.\n', N, d );

    maxpurity = min( 2000, ceil( 60 * 5^( d - 2 ) ) );
    coord = causet_new_sprinkle( N, d, 'Bicone', [ 0.7, 5 ] );
    fprintf( 'Generate: %0.2fs\n', toc( tstart ) );

    tstart = tic;
    C = causet_edit_relate( coord, g );
    L = causet_get_links( C );
    fprintf( 'Link: %0.2fs\n', toc( tstart ) );

    tstart = tic;
    chains = causet_get_chains( C, 4 );
    fprintf( 'Count chains: %0.2fs\n', toc( tstart ) );

    tstart = tic;
    causet_get_statistics( C, L, ...
        [ maxpurity, min( 2000, 4 * maxpurity ), 200, 200, 2, 8 ], ...
        '-set', 1 : N, [ 6, 1 ], coord, g );
    fprintf( 'Causet statistics: %0.2fs\n', toc( tstart ) );

    tstart = tic;
    geo = causet_find_linkgeodesics( C, L, 1, N );
    fprintf( 'Find link geodesic: %0.2fs\n', toc( tstart ) );
    tstart = tic;
    causet_get_statistics( C, L, ...
        [ maxpurity, min( 2000, 4 * maxpurity ), 200, 200, 2, 8 ], ...
        '-chain', geo{ 1 }, [], coord, g );
    fprintf( 'Statistics of link geodesic: %0.2fs\n', toc( tstart ) );

    tstart = tic;
    geo = causet_find_volumegeodesics( C, L, 1, N );
    fprintf( 'Find volume geodesic: %0.2fs\n', toc( tstart ) );
    tstart = tic;
    causet_get_statistics( C, L, ...
        [ maxpurity, min( 2000, 4 * maxpurity ), 200, 200, 2, 8 ], ...
        '-chain', geo{ 1 }, [], coord, g );
    fprintf( 'Statistics of volume geodesic: %0.2fs\n', toc( tstart ) );
end
