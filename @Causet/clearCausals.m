function clearCausals( obj )
%CLEARCAUSALS    Clears the causal structure.
% 
% Arguments:
% obj                 Causet class object as target.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 1, 1 );
    clearvars obj.C obj.L
    obj.C = false( obj.Card ); % allocate memory
    obj.L = []; % reset links
end

