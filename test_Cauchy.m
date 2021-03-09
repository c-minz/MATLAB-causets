% Copyright 2021, C. Minz. BSD 3-Clause License.

%% construct causet
% obj = sprinkledcauset( 1000, 2, ...
%     'Metric', { 'Schwarzschild', 0.1 }, ...
%     'Shape', { 'cylinder', { [ -3.0, 3.0 ], 3 } } );
% obj = sprinkledcauset( 20, 2, 'Shape', { 'cuboid', [zeros(1,7);2,2*ones(1,6)] } );
% obj = sprinkledcauset( 10, 2 );
% obj = causet( logical( [ 0 1 1 1 0; 0 0 0 1 0; 0 0 0 1 0; 0 0 0 0 0; 0 0 0 0 0 ] ) );
% 
% %% plot:
% clf;
% % subplot( 4, 1, 1 );
% subplot( 1, 2, 1 );
% % obj.plot( 'EventLabels', true );%, ...
% %     'FutureColor', [ 0 0 1 ], 'ConeAlpha', '1/r^3' );%, ...
% %     'FutureColor', 'black', 'ConeAlpha', 0.01 );
% hold on;
% % obj.plot( 'Dims', [ 2, 3 ], 'Set', obj.centralantichain(), ...
% %     'ConeEdge', 'green', 'ConeColor', 'cyan', 'ConeAlpha', 0.1 );
% hold off;
% view( 0, 90 );
% hold on;
% % subplot( 4, 1, 2:4 );
% subplot( 1, 2, 2 );
% obj.draw( 'EventLabels', true );
% hold off;

%% central antichain:
% aobj = sprinkledcauset( 200, 2, 'Shape', 'cube' );
% s = aobj.centralantichain();
% aobj.plot();
% hold on;
% aobj.plot( 'Set', s, 'ConeColor', 'cyan', 'ConeAlpha', 0.1, ...
%     'EventLabels', true );
% hold off;
% 
% selcount = obj.sels_count();
% j = 1;
% hold on;
% if j <= selcount
%     subplot( 1, 2, 2 );
%     obj.diagram( obj.pastinfof( tslice ), ...
%         'FutureColor', 'black', 'ConeAlpha', 0.2, 'EventLabels', true );
%     axis equal;
% end
% hold off;

%% 1 + 2 dimensional Cauchy slice:
% dims = [ 2, 1 ];
% % obj = sprinkledcauset( 200, 2, 'Shape', { 'cuboid', [ -1, -3; 1, 3 ] } );
% ac = obj.centralantichain();
% slice_pas = obj.Layers( ac, [ -1, 0 ] );
% ac = obj.pastinfof( slice_pas );
% slice_old = obj.Layers( ac, [ 0, 1 ] );
% slice_new = obj.Layers( obj.futureinfof( slice_old ), [ 0, 1 ] );
% slice_overlap = intersect( slice_old, slice_new );
% obj.plot( 'Dims', dims, 'LinkColor', 'none' );
% hold on;
% obj.plot( 'Dims', dims, 'Set', slice_new, 'EventColor', 'green' );
% obj.plot( 'Dims', dims, 'Set', slice_old, 'EventColor', 'red' );
% obj.plot( 'Dims', dims, 'Set', slice_overlap, ...
%     'EventColor', 'black' );
% % obj.plot( 'Dims', dims, 'Set', slice_pas );
% hold off;
% eventstyles = ones( 1, obj.card );
% eventstyles( slice_new ) = 2;
% eventstyles( slice_old ) = 3;
% eventstyles( slice_overlap ) = 4;
% linkselectors = cell( 1, 3 );
% linkselectors{ 1 } = true( 1, obj.card );
% linkselectors{ 2 } = obj.selof( slice_new );
% linkselectors{ 3 } = obj.selof( slice_old );
% isfirst = true;
% s1 = '';
% for e = setdiff( slice_new, slice_overlap )
%     if isfirst
%         s1 = sprintf( '%03d', e );
%         isfirst = false;
%     else
%         s1 = sprintf( '%s,%03d', s1, e );
%     end
% end
% isfirst = true;
% s2 = '';
% for e = setdiff( slice_old, slice_overlap )
%     if isfirst
%         s2 = sprintf( '%03d', e );
%         isfirst = false;
%     else
%         s2 = sprintf( '%s,%03d', s2, e );
%     end
% end
% causet_saveas_tikz( obj.coords, obj.L, ...
%     '../Graphics/figures/CauchySlicePropagationData.tex', ...
%     struct( 'unit', 0, 'IsSubPicture', true, 'EndCommands', ...
%     sprintf( '\\\\def\\\\eventListAdding{%s}\\n\\\\def\\\\eventListRemoving{%s}\\n', s1, s2 ) ), ...
%     eventstyles, linkselectors );

%% plotting the fence:
% plotd = [2 3 1];
% obj.plot( 'Sel', 2, 'Dims', plotd, 'EventColor', [0.8 0.8 0.8], 'LinkColor', 'none' );
% a = 17;
% minfn = [ 3 5 3 10 ];
% minfn_idx = 1;
% [ fcones, maxfn, removed ] = ...
%     obj.getfencecones( a, obj.sels_get( 2 ), 15, minfn );
% hold on;
% view( 0, 90 );
% fence1 = a;
% for k = 1 : 10
%     fence2 = fcones( minfn_idx, fence1 );
%     fence2 = cat( 2, fence2{ 1, : } );
%     s = obj.sels_add( [ fence1, fence2 ] );
%     obj.plot( 'Sel', s, 'Dims', plotd, ...
%         'Color', [ max( 0.8, 1.0 - 0.1 * k ), ...
%                    min( 0.8, 0.2 * k ), ...
%                    min( 0.8, 0.2 * k ) ], ...
%         'LinkWidth', max( 0.1, 2.6 - 0.3 * k ) );
%     obj.sels_remove( s );
%     fence1 = fence2;
% end
% [ irreds, maxfn2 ] = obj.find1rk3irred( a, fcones( minfn_idx, : ), 1 );
% if ~isempty( irreds )
%     k = 1;
%     if iscell( irreds )
%         kmax = length( irreds );
%         irred = irreds{ k };
%     else
%         kmax = 1;
%         irred = irreds;
%     end
%     while k <= kmax
%         s = obj.sels_add( irred );
%         irred_ps = obj.pastinfof( irred );
%         irred_fs = obj.futureinfof( irred );
%         obj.plot( 'Sel', s, 'Dims', plotd, ...
%             'EventMarker', 'o', 'EventSize', 9, 'EventColor', [ 0.9 0.7 0.1 ], ...
%             'LinkColor', 'black', 'LinkWidth', 1 );
%         obj.plot( 'Sel', s, 'Dims', plotd, 'LinkColor', 'none', ...
%             'EventMarker', 'o', 'EventSize', 4, 'EventColor', 'black' );
%         obj.sels_remove( s );
%         k = k + 1;
%         if k < kmax
%             irred = irreds{ k };
%         end
%     end
% end
% s = obj.sels_add( a );
% obj.plot( 'Sel', s, 'Dims', plotd, 'Color', [ 0.0 0.0 0.0 ] );
% obj.sels_remove( s );
% hold off;
% view( 0, 90 );
% return

%% count irreducibles:
% for i = 3 : obj.sels_count()
%     obj.sels_remove( 3 );
% end
% dimvector = NaN * ones( 1, obj.card );
% sel_all = obj.sels_get( 2 );
% sel = sel_all;
% set = find( sel );
% filledfence = false;
% while ~isempty( set )
%     a = set( 1 );
%     [ d, irred, closingfaces ] = obj.dimat( a, sel_all );
%     dimvector( irred ) = max( dimvector( irred ), d );
%     if d >= 2
%         filledfence = filledfence || ~isempty( closingfaces );
%     end
% %     if length( irred ) > 7
%         obj.sels_add( [ irred, cat( 2, closingfaces{:} ) ] );
% %     end
%     sel( irred ) = false;
%     set = find( sel );
% end
% dimcount = zeros( 1, 5 );
% for d = 0 : 4
%     dimcount( d + 1 ) = sum( dimvector == d );
% end
