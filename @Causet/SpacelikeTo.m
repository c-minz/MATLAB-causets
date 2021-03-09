function s = SpacelikeTo( obj, list, varargin )
%SPACELIKETO    Returns a (logical) vector of events that are spacelike 
%   separated to every element in the specified list.
% 
% Arguments:
% obj                 Embeddedcauset class object.
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
    
    %% get operation mode:
    opmode = struct( varargin{:} );
    if opmode.isfield( 'links' ) && opmode.links % use links
        mat = obj.L;
    else % use causality (default)
        mat = obj.C;
    end
    %% combine sets:
    if islogical( list )
        list = find( list );
    end
    s = true( 1, obj.Card );
    s( events ) = false; % unselect events
    for e = list
        s( mat( :, e ) ) = false; % unselect event pasts
        s( mat( e, : ) ) = false; % unselect event futures
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

