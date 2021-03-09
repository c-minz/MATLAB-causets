function [ handles, dims ] = plot( obj, varargin )
%PLOT    Plots the embedded causet in the current axes.
% 
% Arguments:
% obj                 Embeddedcauset class object.
% 
% Optional arguments: (each key has to be followed by a value)
% 'Dims'              Coordinate dimension indices (2 or 3). 
%                     Default: [ 2, 1 ]
% 'Time'              Time coordinate for a time slice. If the plot has a 
%                     time axis, a vector of up to two double values can be 
%                     specified for a past and a future slice. 
%                     Default: [] (no time slice)
% 'TimeFade'          Double parameter for the time fade [*]. Use a 
%                     negative value for the past or a positive value for
%                     the future.
%                     Default: 0 (dynamic mode off)
% 'AxisStyle'         Axis style, use 'none' to ignore.
%                     Default: 'equal'
% 'AxisLimits'        Axis x, y (and z) limits [xmin ymin; xmax ymax] or 
%                     [xmin ymin zmin; xmax ymax zmax]. Use 'auto' to set
%                     them to min and max of all plotted coordinates, or
%                     'shape' to set them to obj.shaperanges.
%                     Default: 'shape'
% 'Sel'               Index of the selection to be plotted or logical 
%                     selection vector of events. 
%                     Default: all
% 'Set'               Set of events to be plotted. 
%                     Default: all
% 'Lables'            Plot properties for event labels.
%     false, 'none'     do not plot event labels (Default)
%     true              plot event labels with default settings:
%                         'VerticalAlignment'      'top'
%                         'HorizontalAlignment'    'right'
%     cell array        plot event labels with these key-value pairs for 
%                       the text properties (overwriting the default 
%                       values)
% 'Events'            Plot properties for events.
%     true              plot events with default settings (Default):
%                         'Marker'                 'o'
%                         'MarkerSize'             8 or [*]
%                         'LineWidth'              1
%                         'LineStyle'              'none'
%                         'MarkerEdgeColor'        'blue'
%                         'MarkerFaceColor'        'blue'
%     false, 'none'     do not plot events
%     cell array        plot events with these key-value pairs for 
%                       the line properties (overwriting the default 
%                       values)
% 'Links'            Plot properties for links.
%     true              plot links with default settings (Default):
%                         'Color'                  [0.2 0.5 0.8]
%                         'LineWidth'              2 or [*]
%                         'LineStyle'              '-'
%                         'Marker'                 'o'
%                         'MarkerSize'             2
%                         'MarkerEdgeColor'        [0.2 0.5 0.8]
%                         'MarkerFaceColor'        [0.2 0.5 0.8]
%     false, 'none'     do not plot links
%     cell array        plot links with these key-value pairs for 
%                       the line properties (overwriting the default 
%                       values)
% 'PastCones'         Plot properties for past lightcones.
%     false, 'none'     do not plot past cones (Default)
%     true              plot past cones with default settings:
%                         'FaceColor'              [0.95 0.70 0.15]
%                         'EdgeColor'              [0.95 0.70 0.15]
%                         'FaceAlpha'              [*]
%                         'EdgeAlpha'              [*]
%     cell array        plot past cones with these key-value pairs 
%                       for the polygon properties (overwriting 
%                       the default values)
% 'FutureCones'       Plot properties for future lightcones.
%     false, 'none'     do not plot future cones (Default)
%     true              plot future cones with default settings:
%                         'FaceColor'              [0.95 0.70 0.15]
%                         'EdgeColor'              [0.95 0.70 0.15]
%                         'FaceAlpha'              [*]
%                         'EdgeAlpha'              [*]
%     cell array        plot future cones with these key-value pairs 
%                       for the polygon properties (overwriting 
%                       the default values)
% 'Regions'           Cell array with an cell array of points that define 
%                     the hulls of regions in the first cell, followed by 
%                     key-value pairs of polygon properties overwriting 
%                     the default settings:
%                         'FaceColor'              'cyan'
%                         'EdgeColor'              'cyan'
%                         'FaceAlpha'              0.2
%                         'EdgeAlpha'              0.2
% 'ConePoints'        Number of polygon edges that are used to draw circles
%                     and spheres for cones.
%                     Default: 64
% 
% [*] Dynamic properties: (each key has to be followed by a value)
%     The following parameters can be used in functional expressions for 
%     some properties maked with an [*] symbol above:
%       dst  =        time coordinate - 'Time' (double)
%       tfd  =        'TimeDepth' (non-zero double)
%       pth  =        path parameter ranging in [0 1] (for links only)
% 'PastFace'          Char array for the past cone face alpha function.
%                     Default: 
%                       '0.3*exp(-abs(dst))*heaviside(-abs(dst)+exp(1))'
% 'PastEdge'          Char array for the past cone edge alpha function.
%                     Default: 
%                       '0.8*exp(-abs(dst))*heaviside(-abs(dst)+exp(1))'
% 'FutureFace'        Char array for the future cone face alpha function.
%                     Default: 
%                       '0.3*exp(-abs(dst))*heaviside(-abs(dst)+exp(1))'
% 'FutureEdge'        Char array for the future cone edge alpha function.
%                     Default: 
%                       '0.8*exp(-abs(dst))*heaviside(-abs(dst)+exp(1))'
% 'EventSize'         Char array for the event marker size function.
%                     Default: 
%                     'heaviside(-abs(tfd)*dst+0.001).*(abs(tfd)*dst+8)'
% 'LinkWidth'         Char array for the link line width function.
%                     Default: 
%                     'heaviside(-abs(tfd)*dst+0.001).*(1/8*abs(tfd)*dst+1)'
% 
% Returns:
% handles             Structure of handles to graphic objects: 
%   labels              Text objects of the event labels.
%   events              Chart line objects of the events.
%   links               Line objects of the links.
%   regions             Cell array of chart line objects of the regions.
%   pastcones           Cell array of chart line objects of the past 
%                       lightcones.
%   futurecones         Cell array of chart line objects of the future 
%                       lightcones.
% dims                The vector of the two or three spacetime dimensions
%                     that are plotted.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    N = obj.Card;
    %% set default values:
    handles = struct();
    dims = [ 2, 1 ];
    axisstyle = 'equal';
    axislimits = 'shape';
    sel = true( 1, N );
    formats.labels = { 'VerticalAlignment', 'top', ...
        'HorizontalAlignment', 'right' };
    formats.events = { 'Marker', 'o', 'MarkerEdgeColor', 'blue', ...
        'MarkerFaceColor', 'blue', 'LineWidth', 1, 'LineStyle', 'none' };
    formats.links = { 'Color', [0.2 0.5 0.8], 'LineStyle', '-', ...
        'Marker', 'o', 'MarkerSize', 2, ...
        'MarkerEdgeColor', [0.2 0.5 0.8], ...
        'MarkerFaceColor', [0.2 0.5 0.8] };
    formats.regions = { 'FaceColor', 'cyan', ...
        'FaceAlpha', 0.2, 'EdgeColor', 'cyan', 'EdgeAlpha', 0.2 };
    formats.pastcones = { 'FaceColor', [0.95 0.70 0.15], ...
        'EdgeColor', [0.95 0.70 0.15] };
    formats.futurecones = { 'FaceColor', [0.95 0.70 0.15], ...
        'EdgeColor', [0.95 0.70 0.15] };
    draw.labels = false;
    draw.events = true;
    draw.links = true;
    draw.regions = false;
    draw.pastcones = false;
    draw.futurecones = false;
    dynamic.eventsize = 'heaviside(tfd*dst+0.001).*(-tfd*dst+8)';
    dynamic.linkwidth = 'heaviside(tfd*dst+0.001).*(-3/8*tfd*dst+3)';
    dynamic.pastface = '0.3*exp(-abs(dst))*heaviside(-abs(dst)+exp(1))';
    dynamic.pastedge = '0.8*exp(-abs(dst))*heaviside(-abs(dst)+exp(1))';
    dynamic.pastedge_isdefault = true;
    dynamic.futureface = '0.3*exp(-abs(dst))*heaviside(-abs(dst)+exp(1))';
    dynamic.futureedge = '0.8*exp(-abs(dst))*heaviside(-abs(dst)+exp(1))';
    dynamic.futureedge_isdefault = true;
    static.eventsize = 8;
    static.linkwidth = 2;
    time = [];
    tfd = 0; %#ok<*NASGU>
    regions = {};
    conepoints = 64;
    %% read key-value pairs:
    for i = 1:2:length( varargin )
        key = lower( varargin{ i } );
        value = varargin{ i + 1 };
        if strcmp( key, 'dims' )
            dims = value;
        elseif strcmp( key, 'time' )
            time = value;
        elseif strcmp( key, 'timefade' )
            tfd = value;
        elseif strcmp( key, 'axisstyle' )
            axisstyle = value;
        elseif strcmp( key, 'axislimits' )
            axislimits = value;
        elseif strcmp( key, 'sel' )
            if islogical( value )
                sel = value;
            else
                sel = obj.getSels( value );
            end
        elseif strcmp( key, 'set' )
            sel = obj.SelOf( value );
        elseif strcmp( key, 'labels' ) || strcmp( key, 'events' ) ...
                || strcmp( key, 'links' ) || strcmp( key, 'pastcones' ) ...
                || strcmp( key, 'futurecones' )
            if islogical( value )
                draw.(key) = value;
            elseif strcmp( value, 'none' )
                draw.(key) = false;
            else
                draw.(key) = true;
                formats.(key) = [ formats.(key), value ];
            end
        elseif strcmp( key, 'eventsize' )
            dynamic.eventsize = value;
        elseif strcmp( key, 'linkwidth' )
            dynamic.linkwidth = value;
        elseif strcmp( key, 'pastface' )
            dynamic.pastface = value;
        elseif strcmp( key, 'pastedge' )
            dynamic.pastedge = value;
            dynamic.pastedge_isdefault = false;
        elseif strcmp( key, 'futureface' )
            dynamic.futureface = value;
        elseif strcmp( key, 'futureedge' )
            dynamic.futureedge = value;
            dynamic.futureedge_isdefault = false;
        elseif strcmp( key, 'regions' )
            if iscell( value ) ...
                    && ~isempty( value ) && iscell( value{ 1 } )
                draw.regions = true;
                regions = value{ 1 };
                formats.(key) = [ formats.(key), ...
                    value( 2 : length( value ) ) ];
            end
        elseif strcmp( key, 'conepoints' )
            conepoints = value;
        end
    end
    %% further plot paramters:
    coords = obj.Coords( :, dims );
    if isempty( axislimits ) || strcmp( axislimits, 'shape' )
        axislimits = [ obj.ShapeRanges( 1, dims ); ...
                       obj.ShapeRanges( 2, dims ) ];
    elseif strcmp( axislimits, 'auto' )
        axislimits = [ min( coords( sel, : ), [], 1 ); ...
                       max( coords( sel, : ), [], 1 ) ];
    end
    timeaxis = find( dims == 1, 1 );
    hasnotimeaxis = isempty( timeaxis );
    isdynamic = hasnotimeaxis && ~isempty( time );
    if isempty( time )
        slices = axislimits( :, timeaxis )';
    else
        slices = [ time( 1 ), time( length( time ) ) ];
    end
    if ~isempty( time )
        time = time( 1 );
        dsts = obj.Coords( :, 1 ) - time;
    end
    ploteventcount = sum( sel );
    washolding = ishold();
    isholding = washolding;
    is3D = length( dims ) == 3;
    %% plot 2D regions:
    if ~is3D && draw.regions
        regions_len = length( regions );
        handles.regions = cell( 1, regions_len );
        for iR = 1 : regions_len
            R = regions{ iR };
            R = R( :, dims );
            handles.regions{ iR } = plot( polyshape( R ), ...
                format.regions{:} );
            if ~isholding
                hold on;
                isholding = true;
            end
        end
    end
    %% plot past cones:
    if draw.pastcones
        if is3D && dynamic.pastedge_isdefault
            dynamic.pastedge = dynamic.pastface;
        end
        handles.pastcones = cell( 1, ploteventcount );
        c = 0;
        slice = slices( 1 );
        for i = find( sel )
            c = c + 1;
            dst = obj.Coords( i, 1 ) - slice;
            if is3D
                [ X, Y, Z ] = cone3( -1, coords( i, 1 ), ...
                    coords( i, 2 ), coords( i, 3 ), dst );
                hascone = ~isempty( X );
            else
                pgon = cone2( -1, coords( i, 1 ), ...
                    coords( i, 2 ), dst );
                hascone = ~isempty( pgon );
            end
            if hascone
                alpha_face = min( 1, max( 0, eval( dynamic.pastface ) ) );
                alpha_edge = min( 1, max( 0, eval( dynamic.pastedge ) ) );
                if ( alpha_edge > 0 ) || ( alpha_face > 0 )
                    if is3D
                        handles.pastcones{ c } = surf( X, Y, Z, ...
                            'FaceAlpha', alpha_face, ...
                            'EdgeAlpha', alpha_edge, ...
                            formats.pastcones{:} );
                    else
                        handles.pastcones{ c } = plot( pgon, ...
                            'FaceAlpha', alpha_face, ...
                            'EdgeAlpha', alpha_edge, ...
                            formats.pastcones{:} );
                    end
                    if ~isholding
                        hold on;
                        isholding = true;
                    end
                end
            end
        end
    end
    %% plot future cones:
    if draw.futurecones
        if is3D && dynamic.futureedge_isdefault
            dynamic.futureedge = dynamic.futureface;
        end
        handles.futurecones = cell( 1, ploteventcount );
        c = 0;
        slice = slices( 2 );
        for i = find( sel )
            c = c + 1;
            dst = obj.Coords( i, 1 ) - slice;
            if is3D
                [ X, Y, Z ] = cone3( 1, coords( i, 1 ), ...
                    coords( i, 2 ), coords( i, 3 ), -dst );
                hascone = ~isempty( X );
            else
                pgon = cone2( 1, coords( i, 1 ), ...
                    coords( i, 2 ), -dst );
                hascone = ~isempty( pgon );
            end
            if hascone
                alpha_face = min( 1, max( 0, eval( dynamic.futureface ) ) );
                alpha_edge = min( 1, max( 0, eval( dynamic.futureedge ) ) );
                if ( alpha_edge > 0 ) || ( alpha_face > 0 )
                    if is3D
                        handles.futurecones{ c } = surf( X, Y, Z, ...
                            'FaceAlpha', alpha_face, ...
                            'EdgeAlpha', alpha_edge, ...
                            formats.futurecones{:} );
                    else
                        handles.futurecones{ c } = plot( pgon, ...
                            'FaceAlpha', alpha_face, ...
                            'EdgeAlpha', alpha_edge, ...
                            formats.futurecones{:} );
                    end
                    if ~isholding
                        hold on;
                        isholding = true;
                    end
                end
            end
        end
    end
    %% plot links, events, labels:
    if ~isdynamic %% static
        if draw.links
            lnks = sum( obj.LinkCount( sel, sel ) );
            handles.links = cell( 1, lnks );
            l = 0;
            for i = find( sel )
                for j = ( i + 1 ) : N
                    if ~( sel( j ) && ( obj.isLink( i, j ) ...
                                     || obj.isLink( j, i ) ) )
                        continue
                    end
                    l = l + 1;
                    if is3D
                        handles.links{ l } = line( ...
                            [ coords( i, 1 ), coords( j, 1 ) ], ...
                            [ coords( i, 2 ), coords( j, 2 ) ], ...
                            [ coords( i, 3 ), coords( j, 3 ) ], ...
                            'LineWidth', static.linkwidth, ...
                            'MarkerIndices', [], formats.links{:} );
                    else
                        handles.links{ l } = line( ...
                            [ coords( i, 1 ), coords( j, 1 ) ], ...
                            [ coords( i, 2 ), coords( j, 2 ) ], ...
                            'LineWidth', static.linkwidth, ...
                            'MarkerIndices', [], formats.links{:} );
                    end
                    if ~isholding
                        hold on;
                        isholding = true;
                    end
                end
            end
        end
        if is3D
            if draw.events
                handles.events = plot3( coords( sel, 1 ), ...
                    coords( sel, 2 ), coords( sel, 3 ), ...
                    'MarkerSize', static.eventsize, ...
                    formats.events{:} );
                if ~isholding
                    hold on;
                end
            end
            if draw.labels
                handles.labels = text( ...
                    coords( sel, 1 ), coords( sel, 2 ), ...
                    coords( sel, 3 ), string( find( sel ) ), ...
                    formats.labels{:} );
            end
        else
            if draw.events
                handles.events = plot( coords( sel, 1 ), ...
                    coords( sel, 2 ), ...
                    'MarkerSize', static.eventsize, ...
                    formats.events{:} );
                if ~isholding
                    hold on;
                end
            end
            if draw.labels
                handles.labels = text( ...
                    coords( sel, 1 ), coords( sel, 2 ), ...
                    string( find( sel ) ), formats.labels{:} );
            end
        end
    else %% dynamic
        if draw.links
            lnks = sum( obj.LinkCount( sel, sel ) );
            handles.links = cell( 1, lnks );
            l = 0;
        end
        if draw.events
            handles.events = cell( 1, ploteventcount );
            e = 0;
        end
        if draw.labels
            handles.labels = cell( 1, ploteventcount );
        end
        dst = dsts;
        esizes = eval( dynamic.eventsize );
        for i = find( sel )
            e = e + 1;
            if draw.links
                for j = ( i + 1 ) : N
                    if ~( sel( j ) && ( obj.isLink( i, j ) ...
                                     || obj.isLink( j, i ) ) )
                        continue
                    end
                    l = l + 1;
                    if ( esizes( i ) > 0 ) && ...
                       ( esizes( j ) > 0 ) % both events visible
                        if abs( dsts( i ) ) > abs( dsts( j ) )
                            i_out = i;
                            i_in = j;
                        else
                            i_out = j;
                            i_in = i;
                        end
                        pth = 1; % default
                        m = [];
                    elseif ( ( esizes( i ) > 0 ) || ( esizes( j ) > 0 ) ) ...
                            && sign( dsts( i ) ) ~= sign( dsts( j ) )
                        if tfd * dsts( i ) > 0
                            i_out = i;
                            i_in = j;
                        else
                            i_out = j;
                            i_in = i;
                        end
                        pth = abs( dsts( i_out ) / ...
                            ( dsts( i ) - dsts( j ) ) );
                        m = 2;
                    else
                        continue
                    end
                    dst = dsts( i_out );
                    linktarget = ( 1 - pth ) * coords( i_out, : ) ...
                        + pth * coords( i_in, : );
                    lwidth = max( 0, eval( dynamic.linkwidth ) );
                    if lwidth > 0
                        if is3D
                            handles.links{ l } = line( ...
                                [ coords( i_out, 1 ), linktarget( 1 ) ], ...
                                [ coords( i_out, 2 ), linktarget( 2 ) ], ...
                                [ coords( i_out, 3 ), linktarget( 3 ) ], ...
                                'LineWidth', lwidth, ...
                                'MarkerIndices', m, formats.links{:} );
                        else
                            handles.links{ l } = line( ...
                                [ coords( i_out, 1 ), linktarget( 1 ) ], ...
                                [ coords( i_out, 2 ), linktarget( 2 ) ], ...
                                'LineWidth', lwidth, ...
                                'MarkerIndices', m, formats.links{:} );
                        end
                    end
                    if ~isholding
                        hold on;
                        isholding = true;
                    end
                end
            end
            if esizes( i ) <= 0
                continue
            end
            if is3D
                if draw.events
                    handles.events{ e } = plot3( coords( i, 1 ), ...
                        coords( i, 2 ), coords( i, 3 ), ...
                        'MarkerSize', esizes( i ), ...
                        formats.events{:} );
                    if ~isholding
                        hold on;
                        isholding = true;
                    end
                end
                if draw.labels
                    handles.labels{ e } = text( ...
                        coords( i, 1 ), coords( i, 2 ), ...
                        coords( i, 3 ), string( i ), ...
                        formats.labels{:} );
                end
            else
                if draw.events
                    handles.events{ e } = plot( coords( i, 1 ), ...
                        coords( i, 2 ), ...
                        'MarkerSize', esizes( i ), ...
                        formats.events{:} );
                    if ~isholding
                        hold on;
                        isholding = true;
                    end
                end
                if draw.labels
                    handles.labels{ e } = text( ...
                        coords( i, 1 ), coords( i, 2 ), ...
                        string( i ), formats.labels{:} );
                end
            end
        end
    end
    if ~washolding
        hold off;
    end
    %% set x, y, z axes limits:
    if ~strcmp( axisstyle, 'none' )
        axis( axisstyle );
    end
    if axislimits( 1, 1 ) < axislimits( 2, 1 )
        xlim( axislimits( :, 1 ) );
    end
    if axislimits( 1, 2 ) < axislimits( 2, 2 )
        ylim( axislimits( :, 2 ) );
    end
    if ( length( dims ) == 3 ) && ( axislimits( 1, 3 ) < axislimits( 2, 3 ) )
        zlim( axislimits( :, 3 ) );
    end
    return
    
    %% past and future light-cones:
    function pgon = cone2( pf, x, y, r )
        pgon = [];
        if r > 0
            if hasnotimeaxis % draw lightcone as circle
                pgon = nsidedpoly( conepoints, 'Center', [ x, y ], ...
                    'Radius', r );
            else % draw lightcone as triangle
                r = pf * ( slice - [ x, y ] );
                r = r( timeaxis );
                if r > 0
                    if timeaxis == 1
                        % time is along x-axis:
                        P = [ x, y; slice, y - r; slice, y + r ];
                    elseif timeaxis == 2
                        % time is along y-axis:
                        P = [ x, y; x - r, slice; x + r, slice ];
                    else
                        return
                    end
                else
                    return
                end
                warnstate = warning;
                warning( 'off' );
                try
                    pgon = polyshape( P );
                catch
                    pgon = [];
                end
                warning( warnstate );
            end
        end
    end

    function [ X, Y, Z ] = cone3( pf, x, y, z, r )
        X = [];
        Y = [];
        Z = [];
        if r > 0
            if hasnotimeaxis % draw lightcone as sphere
                [ X, Y, Z ] = sphere( conepoints );
                X = r * X + x;
                Y = r * Y + y;
                Z = r * Z + z;
            else % draw lightcone as cone
                r = pf * ( slice - [ x, y, z ] );
                r = r( timeaxis );
                if r > 0
                    if timeaxis == 1
                        % time is along x-axis:
                        [ Y, Z, X ] = cylinder( [ 0 r ], conepoints );
                        X = pf * r * X + x;
                        Y = Y + y;
                        Z = Z + z;
                    elseif timeaxis == 2
                        % time is along y-axis:
                        [ Z, X, Y ] = cylinder( [ 0 r ], conepoints );
                        X = X + x;
                        Y = pf * r * Y + y;
                        Z = Z + z;
                    elseif timeaxis == 3
                        % time is along z-axis:
                        [ X, Y, Z ] = cylinder( [ 0 r ], conepoints );
                        X = X + x;
                        Y = Y + y;
                        Z = pf * r * Z + z;
                    else
                        return
                    end
                else
                    return
                end
            end
        end
    end
end
