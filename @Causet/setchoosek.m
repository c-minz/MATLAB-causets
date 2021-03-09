function set = setchoosek( set, k )
%SETCHOOSEK    Choose k elements from set and return each combination as a
%   row in the return matrix.
%
% Arguments:
% set                 Row vector of the elements in the set.
% k                   Number of elements to be returned from the set.
%
% Returns:
% set                 A matrix with k columns and ( n choose k ) rows where
%                     n is the number of elements in the set. 
%                     An empty row vector is returned if k <= 0. Set is
%                     returned if k >= n.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    n = length( set );
    if ( k <= 0 ) || ( n == 0 )
        set = zeros( 1, 0 );
    elseif k < n
        set = nchoosek( set, k );
    end
end