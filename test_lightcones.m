% Copyright 2021, C. Minz. BSD 3-Clause License.

a = 1.5; b = a / sqrt(3);
%% 2D light-cone animation (with time axis):
t_padd = 1.5;
figtitle = [ 'Causal set and light propagation along the faces of ', ...
             'a 1-simplex embedding' ];
vidname = 'causet_1simplex';
obj = EmbeddedCauset( 2, 'coords', [  0,  -a; 0,  a;  a,  0 ] );
%% 3D light-cone animation (with time axis):
% t_padd = 1.5;
% figtitle = [ 'Causal set and light propagation along the faces of ', ...
%              'a 2-simplex embedding (triangle)' ];
% vidname = 'causet_2simplex_triangle';
% obj = embeddedcauset( 3, 'coords', ...
%     [ -0.001, -a, -b; -0.001,  a, -b; -0.001,  0,  2 * b; ...
%        a,  0, -b;  a, -a / 2,  b / 2;  ...
%        a,  a / 2,  b / 2;  a + b + 0.001,  0,  0 ] );
% figtitle = [ 'Causal set and light propagation along the faces of ', ...
%              'a 2-simplex embedding (triangle, variant 1)' ];
% vidname = 'causet_2simplex_triangle1';
% obj = embeddedcauset( 3, 'coords', ...
%     [  0, -a, -b;  0,  a, -b; ...
%        a,  -a / 2,  b / 2;  a,  0, -b;  a, a / 2,  b / 2;  ...
%        2 * a,  0,  2 * b ] );
% figtitle = [ 'Causal set and light propagation along the faces of ', ...
%              'a 2-simplex embedding (triangle, variant 2)' ];
% vidname = 'causet_2simplex_triangle2';
% obj = embeddedcauset( 3, 'coords', ...
%     [  0,  0,  2 * b; ...
%        a,  -a / 2,  b / 2;  a,  0, -b;  a, a / 2,  b / 2;  ...
%        2 * a, -a, -b;  2 * a,  a, -b ] );
%% 3D light-cone animation (without time axis):
% t_padd = 1.0;
% figtitle = [ 'Causal set and light propagation along the faces of ', ...
%              'a 3-simplex embedding (tetrahedron)' ];
% vidname = 'causet_3simplex_tetrahedron';
% z0 = b;
% A1 = [  0, -a, -b, -b ];
% A2 = [  0,  a, -b, -b ];
% A3 = [  0,  0,  2 * b, -b ];
% A4 = [  0,  0,  0,  a * sqrt(8/3) - b ];
% t2 = [  a,  0,  0,  0 ];
% t3 = [  a + b,  0,  0,  0 ];
% t4 = [  a + b + a / sqrt(6),  0,  0,  0 ];
% obj = embeddedcauset( 4, 'coords', ...
%     [  A1; A2; A3; A4; ...
%        ( A1 + A2 ) / 2 + t2; ( A1 + A3 ) / 2 + t2; ...
%        ( A1 + A4 ) / 2 + t2; ( A2 + A3 ) / 2 + t2; ...
%        ( A2 + A4 ) / 2 + t2; ( A3 + A4 ) / 2 + t2; ...
%        ( A1 + A2 + A3 ) / 3 + t3; ...
%        ( A1 + A2 + A4 ) / 3 + t3; ...
%        ( A1 + A3 + A4 ) / 3 + t3; ( A2 + A3 + A4 ) / 3 + t3; ...
%        ( A1 + A2 + A3 + A4 ) / 4 + t4 ] );
% figtitle = [ 'Causal set and light propagation along the faces of ', ...
%              'a cube embedding (stellated octahedron)' ];
% vidname = 'causet_3simplex_cube';
% z0 = a * sqrt(1/6);
% A1 = [  0, -a, -b, -z0 ];
% A2 = [  0,  a, -b, -z0 ];
% A3 = [  0,  0,  2 * b, -z0 ];
% A4 = [  0,  0,  0,  a * sqrt(8/3)-z0 ];
% t2 = [  a,  0,  0,  0 ];
% t3 = [  a + b,  0,  0,  0 ];
% t4 = [  a + b + a / sqrt(6),  0,  0,  0 ];
% obj = embeddedcauset( 4, 'coords', ...
%     [  A1; A2; A3; A4; ...
%        ( A1 + A2 + A3 - A4 ) / 2; ( A1 + A2 - A3 + A4 ) / 2; ...
%        ( A1 - A2 + A3 + A4 ) / 2; (-A1 + A2 + A3 + A4 ) / 2; ...
%        ( A1 + A2 ) / 2 + t2; ( A1 + A3 ) / 2 + t2; ...
%        ( A1 + A4 ) / 2 + t2; ( A2 + A3 ) / 2 + t2; ...
%        ( A2 + A4 ) / 2 + t2; ( A3 + A4 ) / 2 + t2 ] );
obj.relate();
%% show figure window:
record_video = strcmp( 'true', 'false' );
fps = 60; % frames per second
tsf = 3; % time step factor
fh = gcf();
fh.Color = 'white';
fig_width = 1920;
fig_height = 1080;
fh.Position = [ 0, 0, fig_width, fig_height ];
if record_video
    vh = VideoWriter( vidname, 'MPEG-4' );
    vh.FrameRate = fps;
    vh.Quality = 85;
    vh.open();
end
%% parameters:
t_bounds = [ min( obj.Coords( :, 1 ) ) - t_padd, ...
             max( obj.Coords( :, 1 ) ) + t_padd ];
steps = ceil( fps * tsf * ( t_bounds( 2 ) - t_bounds( 1 ) ) );
times = linspace( t_bounds( 1 ), t_bounds( 2 ), steps );
angles = linspace( 0, 360, steps );
showpcone = obj.Dim < 4;
if showpcone
    pconeopt = { 'EdgeColor', 'none' };
    conetext = '$*$ past and future cones';
else
    pconeopt = false;
    conetext = '$*$ future cones';
end
showfcone = true; fconeopt = { 'EdgeColor', 'none' };
titleoptions = { 'Interpreter', 'latex', 'FontSize', 15 };
labeloptions = { 'Interpreter', 'latex', 'FontSize', 13 };
timefade = 3.0;
showSpace = obj.Dim > 3;
for i = 1 : steps
    clf;
    t = times( i );
    %% main plot:
    if obj.Dim > 3
        subplot( 2, 6, [ 1:5, 7:11 ] );
        obj.plot( 'Dims', [ 2, 3, 4 ], ...
            'AxisLimits', [ -2, -2, -2.5; 2, 2, 2.5 ], ...
            'Time', t, 'TimeFade', timefade, ...
            'Events', { 'MarkerFaceColor', 'k' }, ...
            'PastCones', pconeopt, 'FutureCones', fconeopt );
        title( { figtitle, ...
            'Future $x$-$y$-$z$ view' }, titleoptions{:} );
        zlabel( 'space, $z$', labeloptions{:} );
        ylabel( 'space, $y$', labeloptions{:} );
    elseif obj.Dim > 2
        subplot( 2, 6, [ 1:5, 7:11 ] );
        obj.plot( 'Dims', [ 2, 3, 1 ], ...
            'AxisLimits', [ -2, -2, t_bounds( 1 ); 2, 2, t_bounds( 2 ) ], ...
            'Time', t, 'TimeFade', timefade, ...
            'Events', { 'MarkerFaceColor', 'k' }, ...
            'PastCones', pconeopt, 'FutureCones', fconeopt );
        title( { figtitle, ...
            '$x$-$y$-$t$ view' }, titleoptions{:} );
        zlabel( 'time, $t$', labeloptions{:} );
        ylabel( 'space, $y$', labeloptions{:} );
    else
        obj.plot( 'Dims', [ 2, 1 ], ...
            'AxisLimits', [ -2, t_bounds( 1 ); 2, t_bounds( 2 ) ], ...
            'Time', t, ...
            'Events', { 'MarkerFaceColor', 'k' }, ...
            'PastCones', pconeopt, 'FutureCones', fconeopt );
        title( { figtitle, ...
            '$x$-$t$ view' }, titleoptions{:} );
        ylabel( 'time, $t$', labeloptions{:} );
    end
    xlabel( 'space, $x$', labeloptions{:} );
    grid on
    if obj.Dim > 2
        view( angles( i ), 0 );
        axis vis3d
        %% future side plot:
        axes( 'Units', 'pixels', 'Position', [ fig_width, 0, 0, 0 ] + ...
            [ -0.45, 0.57, 0.36, 0.36 ] * fig_height );
        obj.plot( 'Dims', [ 2, 3 ], 'AxisLimits', [ -2, -2; 2, 2 ], ...
            'Events', { 'MarkerFaceColor', 'k' }, ...
            'Time', t, 'TimeFade', timefade, ...
            'PastCones', showpcone, 'FutureCones', showfcone );
        grid on
        xlabel( 'space, $x$', labeloptions{:} );
        ylabel( 'space, $y$', labeloptions{:} );
        title( 'Future $x$-$y$ view', titleoptions{:} );
        %% past side plot:
        axes( 'Units', 'pixels', 'Position', [ fig_width, 0, 0, 0 ] + ...
            [ -0.45, 0.07, 0.36, 0.36 ] * fig_height );
        obj.plot( 'Dims', [ 2, 3 ], 'AxisLimits', [ -2, -2; 2, 2 ], ...
            'Events', { 'MarkerFaceColor', 'k' }, ...
            'Time', t, 'TimeFade', -timefade, ...
            'PastCones', showpcone, 'FutureCones', showfcone );
        grid on
        xlabel( 'space, $x$', labeloptions{:} );
        ylabel( 'space, $y$', labeloptions{:} );
        title( 'Past $x$-$y$ view', titleoptions{:} );
    end
    %% parameters:
    paramstr = { 'View parameters:', conetext, ...
        sprintf( '$*$ time $t = %0.2f$', t ) };
    if obj.Dim > 2
        paramstr{ 4 } = ...
            sprintf( '$*$ angle $\\varphi = %0.2f{}^\\circ$', angles( i ) );
    end
    annotation( 'textbox', [ 0.05 0.05 0.3 0.1 ], 'String', paramstr, ...
        'FitBoxToText', 'on', 'LineStyle', 'none', ...
        'VerticalAlignment', 'bottom', titleoptions{:} );
    %% diagram:
    axes( 'Units', 'normalized', 'Position', [ 0.02, 0.02, 0.15, 0.5 ] );
    [ h, plotobj ] = obj.draw( 'Links', { 'LineWidth', 1 }, ...
        'Events', { 'MarkerSize', 5 } );
    xlim( [ -2.5,  2.5 ] );
    ylim( [  min( plotobj.Coords( :, 1 ) ) - 0.5, ...
             max( plotobj.Coords( :, 1 ) ) + 0.5 ] );
    title( { 'Causal set', 'Hasse diagram' }, titleoptions{:} );
    pause( 0.05 );
    if record_video
        writeVideo( vh, getframe( fh ) );
    end
end
if record_video
    vh.close();
end
