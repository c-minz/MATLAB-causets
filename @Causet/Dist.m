function n = Dist( obj, a, b, ac )
%DIST    Minimum cardinality of the intersection of the antichain ac with
%   any causal interval between one event in the causal past intersection
%   of events a and b and one event in their causal future intersection.
%   
% Arguments:
% obj                 Causet class object.
% a                   First event.
% b                   Second event.
% ac                  Set of events that form a maximal antichain.
% 
% Returns:
% n                   Considers all element pairs ( p, f ) such that p is
%                     in the causal past intersection of events a and b and
%                     f is in their causal future intersection. This
%                     function considers the intersection of the causal
%                     interval from p to f with the antichain ac and retuns
%                     the cardinality minimum of all such intersections.
%                     It returns NaN if a is succeded by b or their past 
%                     and future cone intersections are empty.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 4, 4 );
    
    %% check if events are identical or causally related:
    if obj.isCausalEq( a, b )
        n = NaN; % obj.interval( a, b, 'card' ) - 1;
        return
    end
    %% find intersections of the cones to the past and to the future:
    pcint = obj.PastOf( [ a, b ], 'lop', 'and' );
    fcint = obj.FutureOf( [ a, b ], 'lop', 'and' );
    %% for each event in the intersections:
    %  Count the number of events their cones share with the antichain.
    %  Get the minimum of these numbers. 
    n = NaN;
    for p = pcint
        n = min( n, obj.FutureOf( p, 'partof', ac, 'return', 'card' ) - 1 );
    end
    for f = fcint
        n = min( n, obj.PastOf( f, 'partof', ac, 'return', 'card' ) - 1 );
    end
end
