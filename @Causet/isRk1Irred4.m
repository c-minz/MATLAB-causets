function bool = isRk1Irred4( obj, lists )
%ISRK1IRRED4    Checks if the set of events are a (minimal) rank 1 
%   4-irreducible (with fourteen events).
%   (Warning: This function at an experimental stage.)
%
% Arguments:
% obj                 Causet class object.
% lists               Logical selection vector or set of events.
%                     OR: Cell vector of two logical selection vector or 
%                     two sets of events, describing two layers of events.
% 
% Returns:
% bool                True if there are fourteen events arranged in a 
%                     rank 1 4-irreducible. Otherwise it returns false.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    if ~iscell( lists )
        lists = { obj.PastInfOf( lists ), ...
                  obj.FutureInfOf( lists ) };
    end
    anum = length( lists{ 1 } );
    bnum = length( lists{ 2 } );
    bool = ( length( lists ) == 2 ) ...
        && ( anum > 0 ) && ( bnum > 0 ) && ( anum + bnum == 14 );
    if ~bool
        return
    end
    if ( bnum > anum ) % time swap
        temp = anum;
        anum = bnum;
        bnum = temp;
        lists = fliplr( lists );
    end
    alist = lists{ 1 };
    blist = lists{ 2 };
    [ alinks, blinks ] = obj.CausalCount( alist, blist );
    if ( alinks( 1 ) == 0 ) && ( blinks( 1 ) == 0 )
        [ blinks, alinks ] = obj.CausalCount( blist, alist );
    end
    if ( anum == 10 ) && ( bnum == 4 )
        bool = ( sum( alinks == 2 ) == 6 ) ... % 6 ev. with 2 links
            && ( sum( alinks == 3 ) == 4 ) ... % 4 ev. with 3 links
            && ( sum( blinks == 6 ) == 4 );    % 4 ev. with 6 links
    elseif ( anum == 9 ) && ( bnum == 5 )
        bool = ( sum( alinks == 2 ) == 3 ) ... % 3 ev. with 2 links
            && ( sum( alinks == 3 ) == 6 ) ... % 6 ev. with 3 links
            && ( sum( blinks == 3 ) == 1 ) ... % 1 ev. with 3 links
            && ( sum( blinks == 5 ) == 3 ) ... % 3 ev. with 5 links
            && ( sum( blinks == 6 ) == 1 );    % 1 ev. with 6 links
    elseif ( anum == 8 ) && ( bnum == 6 )
        bool = ( ( sum( alinks == 3 ) == 8 ) ...   % 8 ev. with 2 links
              && ( sum( blinks == 4 ) == 6 ) ) ... % 6 ev. with 4 links
            || ( ( sum( alinks == 2 ) == 1 ) ...   % 1 ev. with 2 links
              && ( sum( alinks == 3 ) == 6 ) ...   % 6 ev. with 3 links
              && ( sum( alinks == 4 ) == 1 ) ...   % 1 ev. with 2 links
              && ( sum( blinks == 3 ) == 2 ) ...   % 2 ev. with 3 links
              && ( sum( blinks == 4 ) == 2 ) ...   % 2 ev. with 4 links
              && ( sum( blinks == 5 ) == 2 ) );    % 2 ev. with 5 links
    elseif ( anum == 7 ) && ( bnum == 7 )
        bool = ( sum( alinks == 3 ) == 4 ) ... % 4 ev. with 3 links
            && ( sum( alinks == 4 ) == 3 ) ... % 3 ev. with 4 links
            && ( sum( blinks == 3 ) == 4 ) ... % 4 ev. with 3 links
            && ( sum( blinks == 4 ) == 3 );    % 3 ev. with 4 links
    else
        bool = false;
    end
end

