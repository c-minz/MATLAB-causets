function link( obj )
%LINK    Uses the causal matrix to set the link matrix.
% 
% Arguments:
% obj                 Causet class object.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    L = false( obj.Card );
    for i = 1 : obj.Card
        %  Selector for the i-th future light cone:
        causalsel = obj.C( i, : );
        %  Vector of the causal connection count TO each event in the 
        %  future light cone FROM any other event in the cone:
        connections = sum( obj.C( causalsel, : ), 1 );
        %  If such a number is greater than 1, then the respective event 
        %  is not linked because there is a longer path to it. Linked are
        %  only those events that do not have any connection by other
        %  events in the future light cone:
        L( i, : ) = causalsel & ( connections == 0 );
    end
    obj.L = L;
end
