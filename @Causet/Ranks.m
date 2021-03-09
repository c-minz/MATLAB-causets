function s = Ranks( obj, list, k, varargin )
%RANKS    Returns the events in the ranks k(1) to k(end) of the events 
%   list. 
% 
% Arguments:
% obj                 Causet class object.
% list                Logical selection vector or set of events.
% k                   Integer for the rank number or two integers for the 
%                     minimum and maximum of a range of ranks. 
%                     For (non)negative numbers, the ranks are counted
%                     starting with 0 at the future (past) infinity of the 
%                     events in list. If a range is specified that goes
%                     over 0 (from a negative to a positive integer), the
%                     results of two ranges are combined - one up to zero 
%                     and one starting from zero. 
% 
% Optional arguments: (key-value pairs)
% 'partof'            Vector of events or logical (selection) vector of
%                     events. The result will be a subset of this set.
%                     Default: entire object
% 'return'            Char array for return value. Accepted values:
%                       'set'   vector of event (indices)
%                       'sel'   logical vector (selection)
%                       'card'  cardinality of the set
%                     Default: 'set'
% 
% Returns:
% s                   Logical selection vector, set of events, or
%                     cardinality of events.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    opmode = struct( varargin{:} );
    if islogical( list )
        list = find( list );
    end
    if length( k ) == 1
        k_min = k;
        k_max = k;
        k_directions = sign( k );
    else
        k_min = k( 1 );
        k_max = k( 2 );
        if ( k_min < 0 ) && ( k_max < 0 )
            k_directions = -1;
        elseif ( k_min >= 0 ) && ( k_max >= 0 )
            k_directions = 1;
        else
            k_directions = [ -1, 1 ];
            k_min = [ k_min, 0 ];
            k_max = [ 0, k_max ];
        end
    end
    s = false( 1, obj.Card );
    for ki = 1 : length( k_directions )
        if k_directions( ki ) >= 0 % future (or present) layer:
            for b = obj.FutureOf( list, 'origins', true )
                n = 0;
                for a = obj.PastOf( b, 'partof', list )
                    n = max( n, obj.Rank( b, a ) );
                end
                if ( n >= k_min( ki ) ) && ( n <= k_max( ki ) )
                    s( b ) = true;
                end
            end
        else % past layer:
            for a = obj.PastOf( list, 'origins', true )
                n = 0;
                for b = obj.FutureOf( a, 'partof', list )
                    n = min( n, -obj.Rank( b, a ) );
                end
                if ( n >= k_min( ki ) ) && ( n <= k_max( ki ) )
                    s( a ) = true;
                end
            end
        end
    end
    if isfield( opmode, 'partof' )
        s = s & obj.SelOf( opmode.partof );
    end
    if isfield( opmode, 'return' ) && strcmp( opmode.return, 'sel' )
        % return logical selection vector
    elseif isfield( opmode, 'return' ) && strcmp( opmode.return, 'card' )
        % return set cardinality
        s = sum( s );
    else % return index vector
        s = find( s );
    end
end

