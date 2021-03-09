% Copyright 2021, C. Minz. BSD 3-Clause License.

%% sprinkle causet:
% N = int32( 250 );
% d = 2;
% shape = 'bicone';
% c = sprinkledcauset( N, d, 'Shape', shape );

%% with Cauchy:
% c.sels_removeall();
% c.sels_addCauchy( -1, 2 );
% c.plot();
% hold on;
% c.plot( 'Sel', 1 );
% hold off;
% event_styles = ones( 1, c.card );
% event_styles( c.sels_getset( 1 ) ) = 2;
% causet_saveas_tikz( c.coords, c.L, ...
%     sprintf( '../Graphics/data/N%d%sCauchypast.tex', N, shape ), ...
%     -1, event_styles, { true( 1, N ), c.sels_get( 1 ) } );

%% with geodesic:
N = int32( 600 );
[ coord, cranges, volume, event_sel ] = ...
    causet_new_sprinkle( N, 2, 'Bicone', [ 1/sqrt(2), 6, 1 ] );
C = causet_edit_relate( coord );
L = causet_get_links( C );
geodesics = causet_find_linkgeodesics( C, L, 1, N );
% create event and link selectors:
event_styles = ones( 1, N );
kmax = size( event_sel, 2 ) - 1;
for k = 1 : kmax
    event_styles( event_sel( :, k ) & ~event_sel( :, k + 1 ) ) = k;
end
event_styles( event_sel( :, kmax + 1 ) ) = kmax + 1;
pathevent_sel = false( 1, N );
pathevent_sel( geodesics{ 1 } ) = true;
causet_saveas_tikz( coord, L, '../Graphics/data/N600bicone.tex', ...
    -1, event_styles, { true( 1, N ), pathevent_sel } );
