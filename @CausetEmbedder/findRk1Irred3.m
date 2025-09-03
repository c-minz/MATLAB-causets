function [ irreds, maxfencenum ] = findRk1Irred3( obj, a, fcs, n, varargin )
%FINDRK1IRRED3    Searches for the first n many rank 1 3-irreducibles 
%   at event a. The events in fencesets are included step by step.
%
% Arguments:
% obj                 Causet class object.
% a                   Event at which each rank 1 3-irreducible has to
%                     start.
% fcs                 Cell vector for the cone sets of every event
%                     (non-empty along the fence).
%                     The e-th cell contains all events that are in the
%                     cone of event e. See FENCECONESETS
% 
% Optional arguments:
% n                   Maximal number of irreducibles to be returned.
%                     Default: 'all' (find all)
% 
% Optional arguments: (key-value pairs)
% 'return'            Char array for return value. Accepted values:
%                       'set'   (cell array of) vector of events (indices) 
%                               for each rank 1 3-irreducible
%                       'sel'   logical matrix (selections) with a row for
%                               each rank 1 3-irreducible
%                       'fence' cell vectors with event sets by increasing 
%                               fence number
%                     Default: 'set'
% 'irrlists'          cell vector of three sets of events that have to be 
%                     part of the irreducible. The i-th cell element 
%                     contains all events that are i many links 
%                     away from event a. The sets can be empty.
%                     Default: empty cell array 
%                              (no pre-set irreducible events)
% 'fence'             Vector of minimal and maximal fence number.
%                     Default: infinite (dynamic) mode
% 
% Returns:
% irreds              (see 'return')
% maxfencenum         Maximal number of links that any event in the
%                     returned irreducible is away from event a.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    %% check arguments:
    opmode = struct( varargin{:} );
    maxfencenum_isdynamic = isfield( opmode, 'fence' );
    if maxfencenum_isdynamic
        minfencenum = 3;
        maxfencenum = 200;
    elseif length( opmode.fence ) == 1
        minfencenum = 3;
        maxfencenum = opmode.fence;
    else
        minfencenum = opmode.fence( 1 );
        maxfencenum = opmode.fence( 2 );
    end
    if nargin < 4 || isempty( n ) || strcmp( n, 'all' )
        n = Inf;
    end
    returnfence = isfield( opmode, 'return' ) && ...
        strcmp( opmode.return, 'fence' );
    returnsel = isfield( opmode, 'return' ) && ...
        strcmp( opmode.return, 'sel' );
    %% pre-allocate memory:
    if ( maxfencenum < 3 ) || ( length( fcs{ a } ) < 2 ) 
        % too small to find 3-irreducibles, return:
        if returnfence
            irreds = cell( 0, 1 );
        elseif returnsel
            irreds = false( 0, obj.Card );
        else
            irreds = [];
        end
        return
    end
    nmax = n;
    n = 0;
    if returnsel
        irreds = false( min( 200, nmax ), obj.Card );
    else
        irreds = cell( min( 200, nmax ), 1 );
    end
    maxf = 3;
    irred = cell( 1, maxfencenum );
    choicelists = cell( 1, maxfencenum );
    choiceidx = zeros( 1, maxfencenum );
    %% set first choice list:
    f = 1; % fence number
    choicelists{ 1 } = causet.setchoosek( fcs{ a }, 2 );
    isfenceclosing = false;
    isfencewidened = false;
    %% iterate through choices, create further choice lists, and validate:
    while ( n < nmax ) && ( f > 0 )
        if f > maxf
            maxf = f;
        end
        %% increase f-th choice index:
        choiceidx( f ) = choiceidx( f ) + 1;
        if choiceidx( f ) <= size( choicelists{ f }, 1 )
            irred{ f } = choicelists{ f }( choiceidx( f ), : );
        else % The f-th choices are exhausted.
            f = f - 1; % goto previous fence number
            if isfenceclosing
                % Only single choice is exhausted, choose two now.
                isfenceclosing = false;
                isfencewidened = true;
            else
                continue
            end
        end
        %% validate irreducible:
        if isfenceclosing
            irredlayers = { cat( 2, irred{ 1 : 2 : f } ), ... % odd
                            cat( 2, a, irred{ 2 : 2 : f } ) }; % even
            if obj.isRk1Irred3( irredlayers, f )
                n = n + 1;
                if returnfence
                    irreds{ n } = irred( 1, 1 : f );
                elseif returnsel
                    irreds( n, : ) = obj.SelOf( ...
                        [ irredlayers{ 1 }, irredlayers{ 2 } ] );
                else
                    irreds{ n } = [ irredlayers{ 1 }, irredlayers{ 2 } ];
                end
            end
            continue
        end
        %% reached maximum, re-allocate memory if dynamics enabled:
        if f + 1 > maxfencenum
            if ~maxfencenum_isdynamic
                choiceidx( f ) = Inf;
                continue
            else
                newmaxfencenum = 2 * maxfencenum; % double the memory
                temp = cell( 1, newmaxfencenum );
                temp( 1, 1 : maxfencenum ) = irred;
                irred = temp;
                temp = cell( 1, newmaxfencenum );
                temp( 1, 1 : maxfencenum ) = choicelists;
                choicelists = temp;
                temp = zeros( 1, newmaxfencenum );
                temp( 1, 1 : maxfencenum ) = choiceidx;
                choiceidx = temp;
                maxfencenum = newmaxfencenum;
            end
        end
        %% set next choice list:
        isfenceclosing = ~isfencewidened && ( f + 1 >= minfencenum );
        isfencewidened = false;
        e1 = choicelists{ f }( choiceidx( f ), 1 );
        e2 = choicelists{ f }( choiceidx( f ), 2 );
        einter12 = intersect( fcs{ e1 }, fcs{ e2 } );
        f = f + 1; % next fence number
        if isfenceclosing
            if isempty( einter12 )
                choicelists{ f } = zeros( 0, 1 );
            else
                choicelists{ f } = einter12';
            end
        else
            e1cone = setdiff( fcs{ e1 }, einter12 );
            e2cone = setdiff( fcs{ e2 }, einter12 );
            if isempty( e1cone ) || isempty( e2cone )
                choicelists{ f } = zeros( 0, 2 );
            else
                choicelists{ f } = causet.setchoosepair( e1cone, e2cone );
            end
        end
        choiceidx( f ) = 0;
    end
    %% remove pre-allocation:
    irreds = irreds( 1:n, : );
    maxfencenum = maxf;
end
