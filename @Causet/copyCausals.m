function copyCausals( obj, srcobj, subset )
%COPYCAUSALS    Copies the causal structure from a source object.
% 
% Arguments:
% obj                 Causet class object as target.
% srcobj              Causet class object as source.
% 
% Optional arguments:
% subset              Events for a subcauset. Default: all
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 2, 3 );
    clearvars obj.C obj.L
    if nargin < 3
        obj.C = srcobj.C;
        obj.Card = srcobj.Card;
    else
        obj.C = srcobj.Caumat( subset );
        obj.card = length( obj.C );
    end
    obj.L = []; % reset links
end

