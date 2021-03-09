function s = CentralAntichain( obj, varargin )
%CENTRALANTICHAIN    Returns the maximal antichain that include the events 
%   with equal future and past cardinalities.
% 
% Arguments:
% obj                 Causet class object.
% 
% Optional arguments: (key-value pairs)
% 'incl'              Index of an event that has to be included in the
%                     antichain.
%                     Default: none (antichain is not relative to any 
%                              event)
% 'partof'            Logical (selection) vector or set of events for 
%                     which the antichain is computed (e.g. a interval in 
%                     the causet).
%                     Default: all events of the causet
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
    
    %% get operation mode:
    opmode = struct( varargin{:} );
    e = [];
    if isfield( opmode, 'partof' )
        mat = obj.Caumat( opmode.partof );
        opmode.partof = obj.SetOf( opmode.partof );
        if isfield( opmode, 'incl' )
            e = find( opmode.partof == opmode.incl );
        end
    else
        mat = obj.C;
        if isfield( opmode, 'incl' )
            e = opmode.incl;
        end
    end
    %% get antichain from minimal cardinality difference:
    if isempty( e )
        cards = abs( sum( mat, 1 ) - sum( mat, 2 )' );
    else
        cards = abs( sum( mat, 1 )  - sum( mat( :, e ) ) ...
                   - sum( mat, 2 )' + sum( mat( e, : ) ) );
    end
    s = cards == min( cards );
    if sum( sum( mat( s, s ) ) ) ~= 0
        antichain = find( s );
        s = false( 1, obj.Card );
        for a = antichain
            s( a ) = true;
            if sum( sum( mat( s, s ) ) ) ~= 0
                s( a ) = false;
            end
        end
    end
    %% extend antichain to maximal antichain:
    for c = unique( cards )
        for a = find( cards == c )
            s( a ) = true;
            if sum( sum( mat( s, s ) ) ) ~= 0
                s( a ) = false;
            end
        end
    end
    %% return operation:
    if isfield( opmode, 'partof' )
        s = opmode.partof( s );
        if isfield( opmode, 'return' ) && strcmp( opmode.return, 'sel' )
            % return logical selection vector
            s = obj.SelOf( s );
        elseif isfield( opmode, 'return' ) && strcmp( opmode.return, 'card' )
            % return set cardinality
            s = length( s );
        else % return index vector
        end
    else
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

