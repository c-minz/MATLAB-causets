function set = setchoosepair( setA, setB )
%SETCHOOSEPAIR    Choose elements pairs from setA and setB and return each 
%   combination as a row in a matrix.
%
% Arguments:
% setA                Row vector of the events set A.
% setB                Row vector of the events set B.
%
% Returns:
% set                 A matrix with k columns and ( n choose k ) rows where
%                     n is the number of elements in the set. 
%                     An empty row vector is returned if k <= 0. Set is
%                     returned if k >= n.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    setAlen = length( setA );
    setBlen = length( setB );
    if setAlen == 0
        set = setB';
    elseif setBlen == 0
        set = setA';
    elseif setAlen > setBlen
        set = zeros( setAlen * setBlen, 2 );
        for i = 1 : setBlen
            r = ( ( i - 1 ) * setAlen + 1 ) : ( i * setAlen );
            set( r, 1 ) = setA';
            set( r, 2 ) = setB( i );
        end
    else
        set = zeros( setAlen * setBlen, 2 );
        for i = 1 : setAlen
            r = ( ( i - 1 ) * setBlen + 1 ) : ( i * setBlen );
            set( r, 1 ) = setA( i );
            set( r, 2 ) = setB';
        end
    end
end