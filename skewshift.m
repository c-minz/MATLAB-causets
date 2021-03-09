function Y = skewshift( Y )
%SKEWSHIFT shifts each row of the (square) matrix Y such that the matrix 
% becomes upper triangular and the overflow is added in the last column.
% Here is an example using the magic(4) matrix:
%  [  16     2     3    13;                      [  16     2     3    13;
%      5    11    10     8;      is turned into      0     5    11    18;
%      9     7     6    12;                          0     0     9    25;
%      4    14    15     1 ]                         0     0     0    34 ]
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    r = size( Y, 1 );
    c = size( Y, 2 );
    if c < r
        n = r;
    else
        n = c;
    end
    newY = zeros( r, n );
    for i = 1 : r
        rowovfl = min( c + i - 1, n );
        rowend = rowovfl - i + 1;
        if rowend > 0
            newY( i, i : rowovfl ) = Y( i, 1 : rowend );
        end
        newY( i, rowovfl ) = newY( i, rowovfl ) + ...
            sum( Y( i, max( rowend + 1, 1 ) : c ) );
    end
    Y = newY;
end
