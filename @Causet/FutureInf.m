function s = FutureInf( obj, varargin )
%FUTUREINF    Returns the future infinity anti-chain.
% 
% Arguments:
% obj                 Causet class object.
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
    s = ( sum( obj.C, 2 ) == 0 )';
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

