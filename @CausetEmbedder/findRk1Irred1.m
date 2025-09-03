function irreds = findRk1Irred1( obj, a, fcs, n, varargin )
%FINDRK1IRRED1    Searches for the first n many rank 1 1-irreducibles 
%   at event a. The events in fencesets are included step by step.
%
% Arguments:
% obj                 Causet class object.
% a                   Event at which each rank 1 1-irreducible has to
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
%                               for each rank 1 1-irreducible
%                       'sel'   logical matrix (selections) with a row for
%                               each rank 1 1-irreducible
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
    
    d = 1;
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
    for k = 1 : length( irrlists )
        irrlists{ k } = obj.SetOf( irrlists{ k } );
    end
    for k = ( length( irrlists ) + 1 ) : 1 : d
        irrlists{ k } = zeros( 1, 0 );
    end
    returnfence = isfield( opmode, 'return' ) && ...
        strcmp( opmode.return, 'fence' );
    returnsel = isfield( opmode, 'return' ) && ...
        strcmp( opmode.return, 'sel' );
    %% setup ranges for combinations:
    linkcount = length( irrlists{ 1 } );
    choicenum = 1 - linkcount;
    if choicenum == 1
        linkcount = length( fcs{ a } );
    end
    nmax = n;
    n = 0;
    % pre-allocate:
    if returnfence
        irreds = cell( min( linkcount, nmax ), 1 );
    elseif returnsel
        irreds = false( min( linkcount, nmax ), obj.Card );
    else
        irreds = cell( min( linkcount, nmax ), 1 );
    end
    if choicenum >= 0
        %% iterate and check the combinations:
        choices = causet.setchoosek( fcs{ a }, choicenum );
        for c1 = 1 : size( choices, 1 )
            if n >= nmax
                break
            end
            irred = [ irrlists{ 1 }, choices( c1, : ) ];
            if length( irred ) == 1
                n = n + 1;
                if returnfence
                    irreds( n, : ) = { { irred } };
                elseif returnsel
                    irreds( n, : ) = obj.SelOf( [ a, irred ] );
                else
                    irreds( n, : ) = { [ a, irred ] };
                end
            end
        end
    end
    %% remove pre-allocation:
    irreds = irreds( 1:n, : );
end
