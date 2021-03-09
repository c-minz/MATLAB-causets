% Copyright 2021, C. Minz. BSD 3-Clause License.

%% Cauchy slice propagation:
c_dblue = [ 0.1 0.2 0.6 ];
c_lblue = [ 0.5 0.8 1.0 ];
c_red = [ 0.9 0.2 0.1 ];
c_green = [ 0.2 0.8 0.2 ];
c_orange = [ 0.8 0.6 0.1 ];
c_lgrey = [ 0.7 0.8 0.9 ];
c_llgrey = [ 0.9 0.9 1.0 ];
dims = [ 2 1 ]; % [ 2 3 1 ];%
% obj = sprinkledcauset( 500, 2, 'Shape', { 'cuboid', [ -1.2, -2, -2; 1.2, 2, 2 ] } );

v = VideoWriter( 'video_quality100.avi', 'Motion JPEG AVI' );
v.FrameRate = 1;
v.Quality = 100;
v.open();
slice = obj.Layers( obj.pastinf(), [ 0, 1 ], 'set' );%obj.centralantichain();
while true
    slice_expanded = obj.Layers( obj.futureinfof( slice ), [ -1, 1 ], 'set' );
    slice_new = obj.Layers( obj.futureinfof( slice_expanded ), [ -1, 0 ], 'set' );
    slice_removing = setdiff( slice_expanded, slice_new );
    slice_added = setdiff( slice_expanded, slice );
    slice_diamonds = find( obj.pastof( slice_added, 'sel' ) ...
                         & obj.futureof( slice_removing, 'sel' ) );
    if isempty( slice_added )
        break
    end
    cla;
    [ dims, H ] = obj.plot( 'Dims', dims, 'EventColor', c_lgrey, 'LinkColor', c_llgrey );%, 'EventLabels', true );
    h_l = H.events( 1 );
    axis equal;
    hold on;
    [ dims, H ] = obj.plot( 'Dims', dims, 'Set', slice_expanded, ...
        'EventColor', c_dblue, 'LinkColor', c_lblue, 'LinkWidth', 1.5 );
    h_b = H.events( 1 );
    obj.plot( 'Dims', dims, 'Set', [ slice_removing, slice_diamonds ], ...
        'EventColor', c_dblue, 'EventMarkerColor''LinkColor', c_orange, 'LinkWidth', 2 );
    [ dims, H ] = obj.plot( 'Dims', dims, 'Set', [ slice_diamonds, slice_added ], ...
        'EventColor', c_dblue, 'LinkColor', c_orange, 'LinkWidth', 2 );
    if ~isempty( slice_added )
        h_o = H.links( 1 );
    end
    [ dims, H ] = obj.plot( 'Dims', dims, 'Set', slice_removing, 'EventColor', c_red );
    if ~isempty( slice_added )
        h_r = H.events( 1 );
    end
    [ dims, H ] = obj.plot( 'Dims', dims, 'Set', slice_added, 'EventColor', c_green );
    if ~isempty( slice_added )
        h_g = H.events( 1 );
    end
    hold off;
    if isempty( slice_added )
        legend( [ h_l, h_b ], ...
            { 'Causet events', ...
              '\newline\newlineCauchy slice (remaining):\newlineEvents that remain in the Cauchy \newlineslice to the next iteration.' }, ...
            'Location', 'northeastoutside', 'FontSize', 13 );
    else
        legend( [ h_l, h_b, h_r, h_g, h_o ], ...
            { 'Causet events', ...
              '\newline\newlineCauchy slice (remaining):\newlineEvents that remain in the Cauchy \newlineslice to the next iteration.', ...
              '\newline\newlineCauchy slice (excluding):\newlineEvents that are excluded in the \newlineCauchy slice of the next iteration.', ...
              '\newline\newlineCauchy slice (including):\newlineEvents that will be included in the \newlineCauchy slice of the next iteration.', ...
              '\newline\newlineDiamonds towards new events\newline\newline.' }, ...
            'Location', 'northeastoutside', 'FontSize', 13 );
    end
    legend( 'boxoff' );
    drawnow;
    writeVideo( v, getframe( gcf ) );
    if isempty( slice_added )
        break
    end
    slice = slice_new;
end
v.close();
