function s = Interval( obj, a, b, varargin )
%INTERVAL    Returns the events in the Alexandrov set (causal interval) 
%   from event a to event b. 
% 
% Arguments:
% obj                 Embeddedcauset class object.
% a                   Event index of the first event in the interval.
% b                   Event index of the last event in the interval.
% 
% Optional arguments: (key-value pairs)
% 'partof'            Vector of events or logical (selection) vector of
%                     events. The result will be a subset of this set.
%                     Default: entire object
% 'links'             Boolean switch to use linked events only.
%                     Default: false (use all causally related events)
% 'origins'           Boolean switch to include cone origins (events itself
%                     in the sets).
%                     Default: true
% 'lop'               Char array for logical operation mode to combine
%                     sets. Accepted values: 
%                       'or'    union of sets
%                       'and'   intersection of sets
%                       'xor'   symmetric difference of sets
%                     Default: 'or'
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
    if a == b
        if isfield( opmode, 'return' ) && strcmp( opmode.return, 'sel' )
            % return logical selection vector
            s = false( 1, obj.Card );
            if ~isfield( opmode, 'origins' ) || opmode.origins
                s( a ) = true;
            end
        elseif isfield( opmode, 'return' ) && strcmp( opmode.return, 'card' )
            % return set cardinality
            s = double( ~isfield( opmode, 'origins' ) || opmode.origins );
        else % return index vector
            if ~isfield( opmode, 'origins' ) || opmode.origins
                s = a;
            else
                s = zeros( 1, 0 );
            end
        end
    elseif ~obj.isCausal( a, b )
        if isfield( opmode, 'return' ) && strcmp( opmode.return, 'sel' )
            % return logical selection vector
            s = false( 1, obj.Card );
        elseif isfield( opmode, 'return' ) && strcmp( opmode.return, 'card' )
            % return set cardinality
            s = 0;
        else % return index vector
            s = zeros( 1, 0 );
        end
    else % all elements causally between a and b:
        if isfield( opmode, 'links' ) && opmode.links % use links
            mat = obj.L;
        else % use causality (default)
            mat = obj.C;
        end
        s = mat( a, : ) & mat( :, b )';
        s( [ a, b ] ) = ~isfield( opmode, 'origins' ) || opmode.origins;
        if isfield( opmode, 'return' ) && strcmp( opmode.return, 'sel' )
            % return logical selection vector
        elseif isfield( opmode, 'return' ) && strcmp( opmode.return, 'card' )
            % return set cardinality
            s = sum( s );
        else % return index vector
            s = find( s );
        end
    end
end

