function diamond = causet_diamond( links, preftimes )
%CAUSET_DIAMOND Calculates the matrix of the diamonds from 
% the causet link matrix. 
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
    preftimes = weighting( preftimes ) .* preftimes;
    % calcualte elements inside the diamonds:
    pll = ( preftimes * transpose( links ) ) .* links;
    % get their weighting:
    pll_weighting = weighting( pll );
    % calculate the weighted inside of the diamonds:
    diamond = 2 .* pll_weighting .* pll;
    % substract the weighted boundary of the diamonds:
    diamond = diamond - preftimes;
end
