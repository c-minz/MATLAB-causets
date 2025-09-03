% Test script for the (yet incomplete) implementation of an embedding 
% process - the conversion of a Causet object into an EmbeddedCauset
% object.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

obj = embeddedcauset( 2 );
N = 7;
srcobj = causet( logical( [ 0 1 1 1 1 1 1; 0 0 0 0 0 1 0; 0 0 0 0 0 1 0; 0 0 0 0 0 1 1; 0 0 0 0 0 1 1; zeros( 2, N ) ] ) );
obj.copycausals( srcobj );
obj.coords = nan( N, 2 );
obj.coords( 1, : ) = [ -4, 0 ];
obj.coords( 2, : ) = [ 0.5, 0.7 ];
obj.coords( 3, : ) = [ 0, -0.8 ];
obj.coords( 4, : ) = [ 0.8, 2.8 ];
obj.coords( 5, : ) = [ 0.3, 3.7 ];
obj.coords( 6, : ) = [ 3.5, 0.9 ];
obj.coords( 7, : ) = [ 2.5, 4.0 ];
R0 = [ -40, 0; 40, 0 ];
ac = [ 3, 2, 4, 5 ];
for i = 1 : 4
    neighbours = cell( 1, 2 );
    if i > 1
        neighbours{ 1 } = ac( i - 1 );
    end
    if i < length( ac )
        neighbours{ 2 } = ac( i + 1 );
    end
    R = obj.embedregion( ac( i ), neighbours, R0 );
    if ~isempty( R )
        P = polyshape( fliplr( R( [ 1, 2, 4, 3 ], : ) ) );
        plot( P, 'LineStyle', ':' );
        hold on;
    end
end
R = obj.embedregion( 1, cell( 1, 2 ), R0 );
if ~isempty( R )
    P = polyshape( fliplr( R( [ 1, 2, 4, 3 ], : ) ) );
    plot( P, 'LineStyle', ':' );
    hold on;
end
R = obj.embedregion( 6, { [], 7 }, R0 );
if ~isempty( R )
    P = polyshape( fliplr( R( [ 1, 2, 4, 3 ], : ) ) );
    plot( P, 'LineStyle', ':' );
    hold on;
end
R = obj.embedregion( 7, { 6, [] }, R0 );
if ~isempty( R )
    P = polyshape( fliplr( R( [ 1, 2, 4, 3 ], : ) ) );
    plot( P, 'LineStyle', ':' );
    hold on;
end
R = obj.embedregion( 2, { [], 4 }, R0 );
if ~isempty( R )
    P = polyshape( fliplr( R( [ 1, 2, 4, 3 ], : ) ) );
    plot( P, 'LineStyle', ':' );
    hold on;
end
obj.plot( 'EventColor', 'k', 'EventSize', 8, 'LinkWidth', 2 );
hold off;
xlim( [ -6, 6 ] );
ylim( [ -6, 6 ] );
axis equal;
