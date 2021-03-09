function bool = isCausal( obj, a, b )
%ISCAUSAL    Returns true only if A is a single event in the 
%   past of a single event B, otherwise it returns false.
% 
% Arguments:
% obj                 Causet class object.
% a                   Event index.
% b                   Event index.
% 
% Returns:
% bool                Single logical value
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 3, 3 );
    bool = ( length( a ) == 1 ) && ( length( b ) == 1 ) && ...
        obj.C( a, b );
end

