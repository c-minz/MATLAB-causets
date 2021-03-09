function bool = isRk1Irred1( obj, lists )
%ISRK1IRRED1    Checks if the set of events forms an rank 1 1-irreducible 
%   (chain of two events).
%
% Arguments:
% obj                 Causet class object.
% lists               Cell vector of two logical selection vector or list 
%                     of events, the first for the past layer, the second 
%                     for the future layer. OR lists is the set of all 
%                     events in the past and future infinity layers.
% 
% Returns:
% bool                True if there are two events arranged in a chain. 
%                     Otherwise it returns false.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    if iscell( lists )
        a = lists{ 1 };
        b = lists{ 2 };
    else
        a = obj.PastInfOf( lists );
        b = obj.FutureInfOf( lists );
    end
    anum = length( a );
    bnum = length( b );
    bool = ( length( lists ) == 2 ) ...
        && ( anum == 1 ) && ( bnum == 1 ) ...
        && ( obj.isCausal( a, b ) || obj.isCausal( b, a ) );
end

