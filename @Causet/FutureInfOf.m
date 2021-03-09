function s = FutureInfOf( obj, list, varargin )
%FUTUREINFOF    Returns the future infinity anti-chain for a subset of 
%   events.
% 
% Arguments:
% obj                 Causet class object.
% list                Logical selection vector or set of events.
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
    s = list( sum( obj.Caumat( list ), 2 ) == 0 );
    if isfield( opmode, 'partof' )
        s = intersect( s, obj.SetOf( opmode.partof ) );
    end
    if isfield( opmode, 'return' ) && strcmp( opmode.return, 'sel' )
        % return logical selection vector
        s = obj.SelOf( s );
    elseif isfield( opmode, 'return' ) && strcmp( opmode.return, 'card' )
        % return set cardinality
        s = length( s );
    else % return index vector
    end
end

