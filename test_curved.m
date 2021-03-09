% Copyright 2021, C. Minz. BSD 3-Clause License.

global C coord sel_inside sel_outside;
N = 500;
d = 2;
rS = 0.5;
metric = 'EddingtonFinkelstein';
[ coord, cranges ] = causet_new_sprinkle( N, d, 'cylinder', 0, ...
    'global', { [ 0, 4.5 ], 1.5 } );
sel_inside = abs( coord( :, 2 ) ) < rS;
sel_outside = ~sel_inside;
% coord = coord( coord( :, 2 ) >= 0, : );
N = size( coord, 1 );
C = causet_edit_relate( coord, metric, rS );
L = causet_get_links( C );
h_fig = figure;
causet_plot( coord, L );
% hold on;
% plot( coord( sel_inside, 2 ), coord( sel_inside, 1 ), 'co' );
% plot( coord( sel_outside, 2 ), coord( sel_outside, 1 ), 'go' );
% hold off;
datacursormode on;
h_datacur = datacursormode( h_fig );
set( h_datacur, 'UpdateFcn', @test_curved_update );
% causet_plot( coord, L, [ 2, 1 ], { 'ko', 'yx' }, 'c' );
% geod = causet_find_linkgeodesics( C, L, 6, N - 536 );
% hold on;
% if ~isempty( geod )
%     g = geod{1};
%     causet_plot( coord( g, : ), L( g, g ), [ 2, 1 ], { 'ko', 'yx' }, 'k', 3 );
% end
%xlim( [ 0, 4 ] );
