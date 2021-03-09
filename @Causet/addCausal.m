function addCausal( obj, a, b, trans )
%ADDCAUSAL    Adds a causal relation such that a precedes b.
% 
% Arguments:
% obj                 Causet class object.
% a                   Event for which the future is changing.
% b                   Event for which the past is changing.
% 
% Optional argument:
% trans               True if the transitive property of the partial order
%                     will be used, so that the future of b becomes also
%                     part of the future of a.
%                     Default: false
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 3, 4 );
    if ( nargin > 3 ) && trans
        temp = obj.C( a, : ) | obj.C( b, : );
        temp( a, b ) = true;
        obj.C( a, : ) = temp;
    else
        obj.C( a, b ) = true;
    end
    obj.L = []; % reset links
end

