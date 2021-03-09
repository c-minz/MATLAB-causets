% Copyright 2021, C. Minz. BSD 3-Clause License.

function txt = test_curved_update( ~, event_obj )
    global C coord sel_inside sel_outside;
    pos = get( event_obj, 'Position' );
    event = find( coord( :, 1 ) == pos( 2 ) );
    hold on;
    xbnd = xlim;
    ybnd = ylim;
    rectangle( 'Position', [ xbnd( 1 ), ybnd( 1 ), ...
        xbnd( 2 ) - xbnd( 1 ), ybnd( 2 ) - ybnd( 1 ) ], ...
        'FaceColor', 'white' );
    xlim( xbnd );
    ylim( ybnd );
    plot( coord( sel_inside, 2 ), coord( sel_inside, 1 ), 'co' );
    plot( coord( sel_outside, 2 ), coord( sel_outside, 1 ), 'go' );
    %causet_plot( coord( C( event, : ), : ), L( C( event, : ), C( event, : ) ) );
    plot( coord( C( event, : ), 2 ), coord( C( event, : ), 1 ), 'kx' );
    hold off;
    txt = { [ 'Event: ', num2str( event ) ] };
end

