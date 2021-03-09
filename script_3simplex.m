% Copyright 2021, C. Minz. BSD 3-Clause License.

a = 2;
%% define 0-faces:
A1 = [ 0, 0, 0 ];
A2 = [ 1, 0, 0 ] * a;
A3 = [ 1/2, sqrt(3)/2, 0 ] * a;
A4 = [ 1/2, 1/(2*sqrt(3)), sqrt(2/3) ] * a;
At = 0;
%% compute higher faces:
B1 = ( A1 + A2 ) / 2;
B2 = ( A1 + A3 ) / 2;
B3 = ( A1 + A4 ) / 2;
B4 = ( A2 + A3 ) / 2;
B5 = ( A2 + A4 ) / 2;
B6 = ( A3 + A4 ) / 2;
Bt = a / 2;
C1 = ( A1 + A2 + A3 ) / 3;
C2 = ( A1 + A2 + A4 ) / 3;
C3 = ( A1 + A3 + A4 ) / 3;
C4 = ( A2 + A3 + A4 ) / 3;
Ct = sqrt(2/3) * a - 0.000002;
%% 3 simplex:
coord = zeros( 14, 4 );
coord(  1:1: 4, 1 ) = At;
coord(  1:1: 4, 2:1:4 ) = [ A1; A2; A3; A4 ];
coord(  5:1:10, 1 ) = Bt;
coord(  5:1:10, 2:1:4 ) = [ B1; B2; B3; B4; B5; B6 ];
coord( 11:1:14, 1 ) = Ct;
coord( 11:1:14, 2:1:4 ) = [ C1; C2; C3; C4 ];
%% causet:
C = causet_edit_relate( coord, metric( 4 ) );
L = causet_get_links( C );
causet_plot( coord, L, [ 2, 3, 1 ] );
