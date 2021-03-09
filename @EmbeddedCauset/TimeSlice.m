function s = TimeSlice( obj, t, k, varargin )
%TIMESLICE    Returns a k-layer Cauchy slice starting at coordinate time 
%   t. The slice is taken towards the future (if k > 0) and towards the 
%   past (if k < 0).
% 
% Arguments:
% obj                 Embeddedcauset class object.
% t                   Coordinate time from where the slice starts.
% 
% Optional arguments:
% k                   Number of added layers. k > 0 for layers towards 
%                     future, k < 0 for layers towards past. With 
%                     k = +/-Inf, all layers towards future/past infinity 
%                     are added, respectively.
%                     Default: 0 (antichain)
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
    
    N = obj.Card;
    if nargin < 3
        k = 0;
    end
    opmode = struct( varargin{:} );
    %% find antichain for coordinate time t:
    s = false( 1, N );
    events_search = true( 1, N );
    events_search_count = N;
    timediff = abs( obj.Coords( :, 1 ) - t );
    timediff( ~events_search ) = Inf;
    while events_search_count > 0
        [ m, e ] = min( timediff );
        if isinf( m )
            break
        end
        s( e ) = true;
        econe = obj.ConeOf( e, 'return', 'sel' );
        econe( e ) = true;
        events_search = events_search & ~econe;
        timediff( econe ) = Inf;
        events_search_count = sum( events_search );
    end
    %% add layers:
    if k > 0
        s = k >= obj.LayerNumbers( obj.FutureOf( s, 'origins', true ), k );
    elseif k < 0
        s = k <= obj.LayerNumbers( obj.PastOf( s, 'origins', true ), k );
    end
    if isfield( opmode, 'partof' )
        s = s & obj.SelOf( opmode.partof );
    end
    %% return operation:
    if isfield( opmode, 'return' ) && strcmp( opmode.return, 'sel' )
        % return logical selection vector
    elseif isfield( opmode, 'return' ) && strcmp( opmode.return, 'card' )
        % return set cardinality
        s = sum( s );
    else % return index vector
        s = find( s );
    end
end
