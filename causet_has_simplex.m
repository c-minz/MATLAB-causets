function hassimplex = causet_has_simplex( C, L, preselected, ...
    simplex )
%CAUSET_HAS_SIMPLEX checks if an SIMPLEX (up to 3) appears at FIRSTEVENTS. 
% 
% Arguments:
% C                   logical upper triangular causal matrix.
% L                   logical upper triangular link matrix.
% PRESELECTED         [ 1, n ] cell array for the events to be in the
%                     simplex(es). The first cell is a vector of 0-face 
%                     events (vertices), the second cell is a vector 
%                     1-faces (edges), and so on. 
%                     Use { x } to get the largest simplex at event x. Then
%                     the events A1, A2, A3 are srictly increasing. 
% SIMPLEX             simplex number for the search.
% 
% Returns:
% true or false       depending on whether it has a specific simplex.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    hassimplex = ...
        ( simplex == causet_get_simplexes( C, L, preselected, simplex ) );
end

