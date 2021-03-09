function P = Paths( obj, a, b, varargin )
%PATHS    Returns a cell array of sets of events each forming a path from 
%   event a to event b.
% 
% Arguments:
% obj                 Embeddedcauset class object.
% a                   Event index of the first event in the interval.
% b                   Event index of the last event in the interval.
% 
% Optional arguments: (key-value pairs)
% 'length'            Length constraint of the returned paths. 
%                     Accepted values:
%                       'any'   length of paths can be arbitrary
%                       'min'   minimal paths only
%                       'max'   maximal paths (timelike geodesics) only
%                       k       double (integer) value for the length of
%                               the paths
%                       [n,x]   double (integer) values for the minimal 
%                               and maximal length of the paths
%                     Default: 'any'
% 'sort'              Sort paths by their length. Accepted values:
%                       'none'  do not sort result
%                       'ascend' sort ascending by length
%                       'descend' sort descending by length
%                     Default: 'none'
% 'return'            Type of return value. Accepted values:
%                       'set'   cell array of vectors of event (indices)
%                       'sel'   logical matrix with a row for every path 
%                               (selection)
%                       'card'  vector of all different path cardinalities
%                     Default: 'set'
% 
% Returns:
% P                   Cell array of sets of events such that each set 
%                     forms a path from event a to event b.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    %% get operation mode:
    opmode = struct( varargin{:} );
    opmode.findmin = false;
    opmode.findmax = false;
    if ~isfield( opmode, 'length' )
        opmode.minlen = 0;
        opmode.maxlen = Inf;
    elseif ischar( opmode.length )
        opmode.minlen = 0;
        opmode.maxlen = Inf;
        opmode.findmin = strcmp( opmode.length, 'min' );
        opmode.findmax = strcmp( opmode.length, 'max' );
    else
        opmode.minlen = opmode.length( 1 );
        opmode.maxlen = opmode.length( length( opmode.length ) );
    end
    %% handle short paths:
    P = cell( 0, 1 );
    if ~obj.isCausalEq( a, b ) % no paths
    elseif a == b % single event path
        if ( opmode.minlen <= 1 ) && ( 1 <= opmode.maxlen )
            P = { a };
        end
    elseif obj.isLink( a, b ) % two event path
        if ( opmode.minlen <= 2 ) && ( 2 <= opmode.maxlen )
            P = { [ a, b ] };
        end
    elseif 3 <= opmode.maxlen % at least three event path
        b_linked = obj.C( a, : ) & obj.L( :, b )';
        P = Paths_find( a, a, 3 );
        if opmode.findmin
            P = P( cellfun( 'length', P ) == opmode.maxlen );
        elseif opmode.findmax
            P = P( cellfun( 'length', P ) == opmode.minlen );
        elseif isfield( opmode, 'sort' ) && ...
                ~strcmpi( opmode.sort, 'none' )
            [ slen, idx ] = sort( cellfun( 'length', P ), ...
                opmode.sort ); %#ok<ASGLU>
            P = P( idx );
        end
    end
    %% convert to return value:
    if isfield( opmode, 'return' ) && strcmp( opmode.return, 'sel' )
        % return logical selection matrix
        P_len = length( P );
        P_mat = false( length( P ), obj.Card );
        for j = 1 : P_len
            P_mat( j, : ) = obj.SelOf( P{ j } );
        end
    elseif isfield( opmode, 'return' ) && strcmp( opmode.return, 'card' )
        % return set cardinality
        if ( opmode.findmin || opmode.findmax ) && ~isempty( P )
            P = length( P{ 1 } ); % all have the same length
        else
            P = unique( cellfun( 'length', P ) );
        end
    else % return index vector (default)
    end
    
    %% handle long paths:
    function P = Paths_find( path_a, a, len )
        a_linked = obj.L( a, : ) & obj.C( :, b )';
        perimetral = find( a_linked & b_linked );
        internal = find( a_linked & ~b_linked );
        perimetral_count = length( perimetral );
        internal_count = length( internal );
        %% one event between a and b:
        if ( opmode.minlen <= len ) && ( perimetral_count > 0 ) && ...
                ( ~opmode.findmax || ( internal_count == 0 ) )
            P = cell( 1, perimetral_count );
            i = 0;
            for e = perimetral
                i = i + 1;
                P{ i } = [ path_a, e, b ];
            end
            if opmode.findmin
                opmode.maxlen = min( opmode.maxlen, len );
                return
            end
        else
            P = cell( 1, 0 );
        end
        if opmode.findmax
            opmode.minlen = max( opmode.minlen, len );
        end
        if len == opmode.maxlen
            return
        end
        %% two or more events between a and b:
        len = len + 1;
        P2 = cell( 1, internal_count );
        i = 0;
        for e = internal
            i = i + 1;
            P2{ i } = Paths_find( [ path_a, e ], e, len );
        end
        P = [ P, P2{:} ];
    end
end
