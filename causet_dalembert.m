function dalembert = causet_dalembert( links, preftimes )
%CAUSET_DALEMBERT Calculates the matrix of the discrete d'Alembert 
% operator from the causet link matrix. 
% 
% Arguments: 
% LINKS is the causet links matrix
% 
% Optional arguments:
% PREFTIMES is the preferred future/past matrix.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    % if preferred times matrix not given, calculate it:
    if nargin < 2
        preftimes = causet_preftimes( links );
    end
    % apply number of diamonds as weighting to M:
    M = causet_diamond( links, preftimes );
    % get unit matrix:
    unit = eye( size( links, 1 ) );
    % calcualte discrete d'Alembert matrix:
    dalembert = unit - M;
end
