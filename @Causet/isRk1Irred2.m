function bool = isRk1Irred2( obj, lists )
%ISRK1IRRED2    Checks if the set of events forms an rank 1 2-irreducible 
%   (wedge of three events).
%
% Arguments:
% obj                 Causet class object.
% lists               Logical selection vector or set of events.
%                     OR: Cell vector of two logical selection vector or 
%                     two sets of events, describing two layers of events.
% 
% Returns:
% bool                True if there are three events arranged in a wedge. 
%                     Otherwise it returns false.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    if iscell( lists )
        alist = lists{ 1 };
        blist = lists{ 2 };
    else
        alist = obj.PastInfOf( lists );
        blist = obj.FutureInfOf( lists );
    end
    anum = length( alist );
    bnum = length( blist );
    bool = ( length( lists ) == 2 ) ...
        && ( anum > 0 ) && ( bnum > 0 ) && ( anum + bnum == 3 );
    if ~bool
        return
    end
    [ alinks, blinks ] = obj.CausalCount( alist, blist );
    if ( alinks( 1 ) == 0 ) && ( blinks( 1 ) == 0 )
        [ blinks, alinks ] = obj.CausalCount( blist, alist );
    end
    if ( anum == 2 ) && ( bnum == 1 )
        bool = ( sum( alinks == 1 ) == 2 ) ... % 2 ev. with 1 links
            && ( sum( blinks == 2 ) == 1 );    % 1 ev. with 2 links
    elseif ( anum == 1 ) && ( bnum == 2 )
        bool = ( sum( alinks == 2 ) == 1 ) ... % 1 ev. with 2 links
            && ( sum( blinks == 1 ) == 2 );    % 2 ev. with 1 links
    else
        bool = false;
    end
end

