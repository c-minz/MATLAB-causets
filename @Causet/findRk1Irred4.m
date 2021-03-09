function [ irreds, closed3fences ] = findRk1Irred4( obj, a, fcs, n, varargin )
%FINDRK1IRRED4    Searches for the first n many rank 1 4-irreducibles 
%   at event a. The events in fencesets are included step by step.
%
% Arguments:
% obj                 Causet class object.
% a                   Event at which each rank 1 4-irreducible has to
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
%                               for each rank 1 1-irreducible
%                       'sel'   logical matrix (selections) with a row for
%                               each rank 1 1-irreducible
%                     Default: 'set'
% 
% Returns:
% irreds              (see 'return')
% closed3fences
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    %% check arguments:
    opmode = struct( varargin{:} );
    if nargin < 4 || isempty( n ) || strcmp( n, 'all' )
        n = Inf;
    end
    returnsel = isfield( opmode, 'return' ) && ...
        strcmp( opmode.return, 'sel' );
    %% select pairs of rank 1 3-irreducibles:
    closed3fences = obj.findRk1Irred3( a, fcs, 'all', 'fence', 3 );
    count = size( closed3fences, 1 );
    if count < 2
        irreds = zeros( 0, 14 );
        return
    end
    nmax = n;
    n = 0;
    % pre-allocate:
    if returnsel
        irreds = false( min( 200, nmax ), obj.Card );
    else
        irreds = cell( min( 200, nmax ), 1 );
    end
    pair3irredsidx = causet.setchoosek( 1 : count, 2 );
    %% check each pair of 3-irreducibles ( A, B ) if they can be extended 
    %  to an rank 1 4-irreducible:
    for k = 1 : size( pair3irredsidx, 1 )
        A = closed3fences{ pair3irredsidx( k, 1 ) }; % red and purple
        B = closed3fences{ pair3irredsidx( k, 2 ) }; % blue and purple
        linksaway = [ length( union( A{ 1 }, B{ 1 } ) ), ...
                      length( union( A{ 2 }, B{ 2 } ) ), ...
                      length( union( A{ 3 }, B{ 3 } ) ) ];
        % Consider only irreducible combinations such that the number of
        % points that are [ 1 2 3 ] links away from event a is one of the 
        % two options:
        if isequal( linksaway, [ 2 4 2 ] ) % at purple wedge peak
            scoutA = A{ 3 }; % red (with one green link)
            scoutB = B{ 3 }; % blue (with one green link)
            if ~obj.isSpacelikeTo( scoutA, [ B{ 2 }, B{ 3 } ] ) || ...
               ~obj.isSpacelikeTo( scoutB, [ A{ 2 }, A{ 3 } ] )
                continue
            end
            wedgebase = A{ 1 };
            wedgepeak = a;
            wedgeextA = A{ 2 };
            wedgeextB = B{ 2 };
        elseif isequal( linksaway, [ 3 3 2 ] ) % at purple wedge base
            scoutA = setdiff( A{ 2 }, B{ 2 } ); % red (with one green link)
            scoutB = setdiff( B{ 2 }, A{ 2 } ); % blue (with one green link)
            if ~obj.isSpacelikeTo( scoutA, [ B{ 1 }, B{ 2 }, B{ 3 } ] ) || ...
               ~obj.isSpacelikeTo( scoutB, [ A{ 1 }, B{ 2 }, A{ 3 } ] )
                continue
            end
            wedgebase = [ a, intersect( A{ 2 }, B{ 2 } ) ];
            wedgepeak = intersect( A{ 1 }, B{ 1 } );
            wedgeextA = [ setdiff( A{ 1 }, B{ 1 } ), A{ 3 } ];
            wedgeextB = [ setdiff( B{ 1 }, A{ 1 } ), B{ 3 } ];
        else
            continue
        end
        scoutconnect = intersect( fcs{ scoutA }, ...
                                  fcs{ scoutB } ); % green (and black)
        if isempty( scoutconnect )
            continue
        end
        %% find far connection between A and B: the ambassador (green)
%         ambassadorset = setdiff( scoutconnect, ...
%                                  union( fcs{ wedgebase( 1 ) }, ...
%                                         fcs{ wedgebase( 2 ) } ) );
%         if isempty( ambassadorset )
%             continue
%         end
%         for ambassador = ambassadorset % green
            %% Extended A (red) and B (blue) each by one event that connect 
            %  all members of one layer: the leaders (orange and cyan)
            wedgeextA_coneinter = intersect( fcs{ wedgeextA( 1 ) }, ...
                                             fcs{ wedgeextA( 2 ) } );
%             wedgeextB_coneinter = intersect( fcs{ wedgeextB( 1 ) }, ...
%                                              fcs{ wedgeextB( 2 ) } );
            wedgebase_coneinter = intersect( fcs{ wedgebase( 1 ) }, ...
                                             fcs{ wedgebase( 2 ) } );
            leaderAset01 = ...
                setdiff( intersect( fcs{ wedgepeak }, wedgeextA_coneinter ), ...
                    [ fcs{ wedgeextB( 1 ) }, fcs{ wedgeextB( 2 ) } ] );%, ...
%                       fcs{ ambassador } ] );
%             leaderBset02 = ...
%                 setdiff( intersect( fcs{ wedgepeak }, wedgeextB_coneinter ), ...
%                     [ fcs{ wedgeextA( 1 ) }, fcs{ wedgeextA( 2 ) }, ...
%                       fcs{ ambassador } ] );
            leaderAset23 = intersect( fcs{ scoutA }, wedgebase_coneinter );
%             leaderBset13 = intersect( fcs{ scoutB }, wedgebase_coneinter );
            for il = 0% : 3
                if il < 2 % extend A spacelike to scoutA
                    leaderAset = leaderAset01;
                else
                    leaderAset = leaderAset23;
                end
                if isempty( leaderAset )
                    continue
                end
%                 if mod( il, 2 ) == 0 % extend B spacelike to scoutB
%                     leaderBset = leaderBset02;
%                 else
%                     leaderBset = leaderBset13;
%                 end
%                 if isempty( leaderBset )
%                     continue
%                 end
                for leaderA = leaderAset % orange
%                     for leaderB = leaderBset % cyan
%                         if ~obj.isSpacelikeTo( leaderA, leaderB )
%                             continue
%                         end
%                         leadersconnect = [ leaderA, leaderB, ... 
%                             union( fcs{ leaderA }, fcs{ leaderB } ) ];
                        %% extended A and B by two more events: the agents
                        %  Agents are not connected to the leaders.
%                         for ic = 1 : 4
%                             agent1set = [];
%                             preagent2set = [];
%                             agent2set = [];
%                             assigncase( ic );
%                             for agent1 = agent1set % black
%                                 if ic == 2
%                                     % agent 1 communicates with ambassador
%                                     agent2set = setdiff( preagent2set, ...
%                                         fcs{ agent1 } );
%                                 end
%                                 for agent2 = agent2set % black
                                    n = n + 1;
                                    irred = [ wedgepeak, wedgebase, ...
                                            wedgeextA, wedgeextB, ...
                                            scoutA, scoutB, ...
                                            ambassador ];%, leaderA, leaderB, agent1, agent2 ];
                                    if returnsel
                                        irreds( n, : ) = obj.SelOf( irred );
                                    else
                                        irreds( n, : ) = { irred };
                                    end
                                    if n == nmax
                                        return
                                    end
%                                 end
%                             end
%                         end
%                     end
                end
            end
%         end
    end
    %% remove pre-allocation and reset operation mode:
    irreds = irreds( 1:n, : );
    return

    %% nested function for the agent case assignment:
%     function assigncase( agentcase )
%         if agentcase == 1
%             % 1. case: no agent communicates with ambassador
%             agent1set = setdiff( intersect( scoutconnect, fcs{ wedgebase( 1 ) } ), ...
%                                  [ leadersconnect, fcs{ wedgebase( 2 ) } ] );
%             agent2set = setdiff( intersect( scoutconnect, fcs{ wedgebase( 2 ) } ), ...
%                                  [ leadersconnect, fcs{ wedgebase( 1 ) } ] );
%         elseif agentcase == 2
%             % 2. case: agent 1 communicates with ambassador
%             agent1set = setdiff( ...
%                 intersect( intersect( fcs{ ambassador }, ...
%                     setxor( fcs{ wedgeextA( 1 ) }, fcs{ wedgeextA( 2 ) } ) ), ...
%                     setxor( fcs{ wedgeextB( 1 ) }, fcs{ wedgeextB( 2 ) } ) ), ...
%                 leadersconnect );
%             preagent2set = setdiff( ...
%                 intersect( scoutconnect, ...
%                     setxor( fcs{ wedgebase( 1 ) }, fcs{ wedgebase( 2 ) } ) ), ...
%                 leadersconnect );
%         elseif agentcase == 3
%             % 3. case: both agents communicate with ambassador, option 1
%             agent1set = setdiff( ...
%                 intersect( fcs{ ambassador }, ...
%                     setdiff( intersect( fcs{ wedgeextA( 1 ) }, fcs{ wedgeextB( 1 ) } ), ...
%                         union( fcs{ wedgeextA( 2 ) }, fcs{ wedgeextB( 2 ) } ) ) ), ...
%                 leadersconnect );
%             agent2set = setdiff( ...
%                 intersect( fcs{ ambassador }, ...
%                     setdiff( intersect( fcs{ wedgeextA( 2 ) }, fcs{ wedgeextB( 2 ) } ), ...
%                         union( fcs{ wedgeextA( 1 ) }, fcs{ wedgeextB( 1 ) } ) ) ), ...
%                 leadersconnect );
%         elseif agentcase == 4
%             % 4. case: both agents communicate with ambassador, option 2
%             agent1set = setdiff( ...
%                 intersect( fcs{ ambassador }, ...
%                     setdiff( intersect( fcs{ wedgeextA( 1 ) }, fcs{ wedgeextB( 2 ) } ), ...
%                         union( fcs{ wedgeextA( 2 ) }, fcs{ wedgeextB( 1 ) } ) ) ), ...
%                 leadersconnect );
%             agent2set = setdiff( ...
%                 intersect( fcs{ ambassador }, ...
%                     setdiff( intersect( fcs{ wedgeextA( 2 ) }, fcs{ wedgeextB( 1 ) } ), ...
%                         union( fcs{ wedgeextA( 1 ) }, fcs{ wedgeextB( 2 ) } ) ) ), ...
%                 leadersconnect );
%         end
%     end
end
