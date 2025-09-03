function bool = isRk1Irred( obj, k, lists )
%ISRK1IRRED    Checks if two sets of events are a rank 1 k-irreducible.
%
% Arguments:
% k                   Order of the irreducible. (Between 0 and 4)
% lists               Cell vector of two logical selection vector or list 
%                     of events, the first for the past layer, the second 
%                     for the future layer. OR lists is the set of all 
%                     events in the past and future infinity layers.
% 
% Returns:
% bool                True if the list describes a rank 1 k-irreducible.
%                     It is true if k = 0 and false if k < 0 or k > 4. For
%                     k > 4 a not supported warning is displayed.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    switch k
        case 0; bool = true;
        case 1; bool = obj.isRk1Irred1( lists );
        case 2; bool = obj.isRk1Irred2( lists );
        case 3; bool = obj.isRk1Irred3( lists );
        case 4; bool = obj.isRk1Irred4( lists );
        otherwise
            warning( [ 'This implementation does not support ', ...
                       'rank 1 %d-irreducibles.' ], k );
            bool = false;
    end
end

