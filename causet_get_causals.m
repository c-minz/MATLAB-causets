function C = causet_get_causals( L )
%CAUSET_GET_CAUSALS Calculates the matrix of causal relations from the 
% causet link matrix. 
% 
% Arguments: 
% L                   upper triangular (logical) links matrix.
% 
% Returns:
% C                   upper triangular (logical) causals matrix.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    % use matrix power to add all links and links of links ...
    n = size( L, 1 );
    L = double( L );
    C = L;
    for i = 2 : ( n - 1 )
        C = C * L + L;
    end
    % convert to logic matrix for any number of links:
    C = ( C > 0 );
end
