function bool = isRk1Irred3( obj, lists, maxfencenum )
%ISRK1IRRED3    Checks if the set of events forms an rank 1 3-irreducible 
%   (crown causet or longer closed fences).
%
% Arguments:
% obj                 Causet class object.
% lists               Logical selection vector or set of events.
%                     OR: Cell vector of two logical selection vector or 
%                     two sets of events, describing two layers of events.
% 
% Optional arguments:
% maxfencenum         Highest number of links that is necessary to connect
%                     two events. This argument can be proved to improve
%                     performance for multiple function calls. If not
%                     provided, then it will be computed from lists.
% 
% Returns:
% bool                True if there are six events arranged in a crown or
%                     any higher even number of events arranged in a closed
%                     fence. Otherwise it returns false.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    %% turn input into two layers:
    if iscell( lists )
        alist = lists{ 1 };
        blist = lists{ 2 };
    else
        alist = obj.PastInfOf( lists );
        blist = obj.FutureInfOf( lists );
    end
    anum = length( alist );
    bnum = length( blist );
    irredsize = anum + bnum;
    bool = ( length( lists ) == 2 ) && ( anum > 0 ) ...
        && ( anum == bnum ) && ( irredsize >= 6 );
    if ~bool
        return
    end
    %% Is it larger than a crown? Then check if it can be a closed fence:
    if irredsize > 6 % not a 3-crown
        if nargin < 3
            % compute maxfencenum:
            fence = obj.FenceAt( alist( 1 ), [ alist, blist ], ...
                irredsize / 2 );
            maxfencenum = 0;
            for k = 1 : length( fence )
                if isempty( fence{ k } )
                    break
                end
                maxfencenum = k;
            end
        end
        bool = ( irredsize == 2 * maxfencenum ); % Is it a closed fence?
    end
    if ~bool
        return
    end
    %% Count in/out links for each event in the crown or closed fence:
    [ alinks, blinks ] = obj.CausalCount( alist, blist );
    if ( alinks( 1 ) == 0 ) && ( blinks( 1 ) == 0 )
        [ blinks, alinks ] = obj.CausalCount( blist, alist );
    end
    % 2 links out or 2 links in per event:
    bool = ( sum( alinks == 2 ) == anum ) ...
        && ( sum( blinks == 2 ) == bnum );
end
