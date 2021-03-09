function s = ConeOf( obj, list, varargin )
%CONEOF    Returns the past- and future-cones of all elements in list. 
%   Depending on the operation parameters (options), the cones are
%   unified (default) or intersected.
% 
% Arguments:
% obj                 Causet class object.
% list                Logical selection vector or set of events.
% 
% Optional arguments: (key-value pairs)
% 'partof'            Vector of events or logical (selection) vector of
%                     events. The result will be a subset of this set.
%                     Default: entire object
% 'links'             Boolean switch to use linked events only.
%                     Default: false (use all causally related events)
% 'origins'           Boolean switch to include cone origins (events itself
%                     in the sets).
%                     Default: false
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
    
    %% get operation mode:
    opmode = struct( varargin{:} );
    if isfield( opmode, 'links' ) && opmode.links % use links
        mat = obj.L;
    else % use causality (default)
        mat = obj.C;
    end
    %% combine sets:
    if islogical( list )
        list = find( list );
    end
    incl_coneo = isfield( opmode, 'origins' ) && opmode.origins;
    if isfield( opmode, 'lop' ) && strcmp( opmode.lop, 'and' )
        % intersection of sets
        s = true( 1, obj.Card );
        for e = list
            se = mat( e, : ) | mat( :, e )';
            if incl_coneo
                se( e ) = true;
            end
            s = s & se;
        end
    elseif isfield( opmode, 'lop' ) && strcmp( opmode.lop, 'xor' )
        % symmetric difference of sets
        s = false( 1, obj.Card );
        for e = list
            se = mat( e, : ) | mat( :, e )';
            if incl_coneo
                se( e ) = true;
            end
            s = xor( s, se );
        end
    else % union of sets (default)
        s = false( 1, obj.Card );
        for e = list
            s = s | ( mat( e, : ) | mat( :, e )' );
        end
        if incl_coneo
            s( list ) = true;
        end
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

