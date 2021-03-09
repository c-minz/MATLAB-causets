function causet_plot( coord, L, dims, eventoption, linkcolor, linkwidth )
%CAUSET_PLOT plots the coordinates COORD of the causet and the links 

% Arguments:
% COORD               coordinate matrix with a row for each point.
% L                   logical upper triangular link matrix.
% 
% Optional Arguments:
% DIMS                vector with two entries for the dimensions to plot.
%                     Default: [ 2, 1 ] for time vs. x-coordinate
% EVENTOPTION         event plot options. Default: { 'ko', 'yx' }
% LINKCOLOR           link color. Default: cyan
% LINKWIDTH           line width of links. Default: 0.5
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    if nargin < 3
        dims = [ 2, 1 ]; % plot time vs. x-coordinate
    end
    if nargin < 4
        eventoption = { 'ko', 'yx' }; % plot black circles, yellow crosses
    elseif ischar( eventoption )
        eventoption = { eventoption, eventoption };
    end
    if nargin < 5
        linkcolor = 'blue'; % plot dots
    end
    if nargin < 6
        linkwidth = 0.5; % link width
    end
    N = size( L, 1 );
    if ( length( dims ) > 2 )
        plot3( coord( :, dims( 1 ) ), coord( :, dims( 2 ) ), ...
            coord( :, dims( 3 ) ), eventoption{ 1 } );
        hold on;
        for i = 1 : N
            for j = ( i + 1 ) : N
                if L( i, j ) % linked
                    line( [ coord( i, dims( 1 ) ), coord( j, dims( 1 ) ) ], ...
                          [ coord( i, dims( 2 ) ), coord( j, dims( 2 ) ) ], ...
                          [ coord( i, dims( 3 ) ), coord( j, dims( 3 ) ) ], ...
                          'Color', linkcolor, 'LineWidth', linkwidth );
                end
            end
        end
        plot3( coord( :, dims( 1 ) ), coord( :, dims( 2 ) ), ...
            coord( :, dims( 3 ) ), eventoption{ 2 } );
        hold off;
    else
        plot( coord( :, dims( 1 ) ), coord( :, dims( 2 ) ), ...
            eventoption{ 1 } );
        hold on;
        for i = 1 : N
            for j = ( i + 1 ) : N
                if L( i, j ) % linked
                    line( [ coord( i, dims( 1 ) ), coord( j, dims( 1 ) ) ], ...
                          [ coord( i, dims( 2 ) ), coord( j, dims( 2 ) ) ], ...
                          'Color', linkcolor, 'LineWidth', linkwidth );
                end
            end
        end
        plot( coord( :, dims( 1 ) ), coord( :, dims( 2 ) ), ...
            eventoption{ 2 } );
        hold off;
    end
end

