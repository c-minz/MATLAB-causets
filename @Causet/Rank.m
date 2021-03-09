function r = Rank( obj, b, a )
%RANK    Returns the rank of event b succeeding event a.
% 
% Arguments:
% obj                 Embeddedcauset class object.
% b                   Event index of the last event in the interval.
% a                   Event index of the first event in the interval.
% 
% Returns:
% r                   Rank of event b succeeding event a, or Inf if b does
%                     not succeed a.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 3, 3 );
    
    if ~obj.isCausalEq( a, b )
        r = Inf;
    elseif a == b
        r = 0;
    elseif obj.L( a, b )
        r = 1;
    else
        a_linked = obj.L( a, : ) & obj.C( :, b )';
        b_linked = obj.C( a, : ) & obj.L( :, b )';
        if sum( a_linked & b_linked ) > 0
            r = 2;
            return
        end
        r = Inf;
        for a2 = find( a_linked )
            for b2 = find( obj.C( a2, : ) & b_linked )
                r = min( r, obj.Rank( b2, a2 ) + 2 );
                if r == 3
                    break
                end
            end
            if r == 3
                break
            end
        end
    end
end

