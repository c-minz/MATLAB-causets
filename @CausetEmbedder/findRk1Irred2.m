function irreds = findRk1Irred2( obj, a, fcs, n, varargin )
%FINDRK1IRRED2    Searches for the first n many rank 1 2-irreducibles 
%   at event a. The events in fencesets are included step by step.
%
% Arguments:
% obj                 Causet class object.
% a                   Event at which each rank 1 2-irreducible has to
%                     start.
% fcs                 Cell vector for the cone sets of every event
%                     (non-empty along the fence).
%                     The e-th cell contains all events that are in the
%                     cone of event e. See FENCECONESETS
% 
% Optional arguments:
% n                   Maximal number of irreducibles to be searched for. If
%                     the number n is reached or if no further irreducible 
%                     is found, the search is canceled and all n 
%                     irreducibles are returned in a cell array.
%                     Default: 'all' (find all)
% 
% Optional arguments: (key-value pairs)
% 'return'            Char array for return value. Accepted values:
%                       'set'   (cell array of) vector of events (indices) 
%                               for each rank 1 2-irreducible
%                       'sel'   logical matrix (selections) with a row for
%                               each rank 1 2-irreducible
%                       'fence' cell vectors with event sets by increasing 
%                               fence number
%                     Default: 'set'
% 'irrlists'          cell vector of three sets of events that have to be 
%                     part of the irreducible. The i-th cell element 
%                     contains all events that are i many links 
%                     away from event a. The sets can be empty.
%                     Default: empty cell array 
%                              (no pre-set irreducible events)
% 
% Returns:
% irreds              (see 'return')
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    d = 2;
    %% check arguments:
    opmode = struct( varargin{:} );
    if nargin < 4 || isempty( n ) || strcmp( n, 'all' )
        n = Inf;
    end
    if isfield( opmode, 'irrlists' )
        irrlists = opmode.irrlists;
    else
        irrlists = cell( d, 0 );
    end
    for cnum = 1 : length( irrlists )
        irrlists{ cnum } = obj.SetOf( irrlists{ cnum } );
    end
    for cnum = ( length( irrlists ) + 1 ) : 1 : d
        irrlists{ cnum } = zeros( 1, 0 );
    end
    returnfence = isfield( opmode, 'return' ) && ...
        strcmp( opmode.return, 'fence' );
    returnsel = isfield( opmode, 'return' ) && ...
        strcmp( opmode.return, 'sel' );
    %% setup ranges for combinations:
    irrlistslen = cellfun( 'length', irrlists( 1, : ) );
    nmax = n;
    n = 0;
    % pre-allocate:
    if returnfence
        irreds = cell( min( 200, nmax ), 1 );
    elseif returnsel
        irreds = false( min( 200, nmax ), obj.Card );
    else
        irreds = cell( min( 200, nmax ), 1 );
    end
    %% iterate and check the combinations:
    for cnum = 2 : -1 : 1
        if n >= nmax
            break
        end
        choices1 = causet.setchoosek( fcs{ a }, cnum - irrlistslen( 1 ) );
        for c1 = 1 : size( choices1, 1 )
            irrfence1 = [ irrlists{ 1 }, choices1( c1, : ) ];
            if ( n >= nmax ) || isempty( irrfence1 )
                break
            end
            if length( irrfence1 ) == 1
                choices2 = causet.setchoosek( fcs{ irrfence1 }, ...
                    cnum - irrlistslen( 2 ) );
            else
                choices2 = zeros( 1, 0 );
            end
            for c2 = 1 : size( choices2, 1 )
                if n >= nmax
                    break
                end
                irrfence2 = [ irrlists{ 2 }, choices2( c2, : ) ];
                if isempty( irrfence2 )
                    irred_layA = a;
                    irred_layB = irrfence1;
                else
                    irred_layA = [ a, irrfence2 ];
                    irred_layB = irrfence1;
                end
                irred = [ irrfence1, irrfence2 ];
                if obj.isRk1Irred2( { irred_layA, irred_layB } )
                    n = n + 1;
                    if returnfence
                        irreds( n, : ) = { { irrfence1, irrfence2 } };
                    elseif returnsel
                        irreds( n, : ) = obj.SelOf( [ a, irred ] );
                    else
                        irreds( n, : ) = { [ a, irred ] };
                    end
                end
            end
        end
    end
    %% remove pre-allocation:
    irreds = irreds( 1:n, : );
end
