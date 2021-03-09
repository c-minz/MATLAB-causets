function e = addEvent( obj, varargin )
%ADDEVENT    Adds an event to the causet.
% 
% Arguments:
% obj                 Causet class object.
% 
% Optional arguments:
% position            Use 'futureinf' or 'pastinf' (Default) to 
%                     add an event to the future or past of all other 
%                     events, respectively. 
% OR
% prec_list           Logical selection vector or set of events that 
%                     precede the new event.
% succ_list           Logical selection vector or set of events that 
%                     succeed the new event.
% 
% Returns:
% e                   Event that was added.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 1, 3 );
    
    N = obj.Card;
    if ( nargin == 1 ) || strcmp( varargin{ 1 }, 'pastinf' )
        succ = true( 1, N );
        isnoneprec = true;
        isnonesucc = false;
    elseif strcmp( varargin{ 1 }, 'futureinf' )
        prec = true( 1, N );
        isnoneprec = false;
        isnonesucc = true;
    else
        prec = varargin{ 1 };
        if nargin > 2
            succ = varargin{ 2 };
        else
            succ = [];
        end
        if islogical( prec )
            isnoneprec = sum( prec ) == 0;
        else
            isnoneprec = isempty( prec );
            prec = obj.SelOf( prec );
        end
        if islogical( succ )
            isnonesucc = sum( succ ) == 0;
        else
            isnonesucc = isempty( succ );
            succ = obj.SelOf( succ );
        end
    end
    if isnoneprec
        obj.C = [ false( N + 1, 1 ), [ succ; obj.C ] ];
        e = 1;
    elseif isnonesucc
        obj.C = [ [ obj.C, prec' ]; false( 1, N + 1 ) ];
        e = N + 1;
    else
        e = find( prec, 1, 'last' ) + 1;
        prec_range = 1 : ( e - 1 );
        succ_range = e : N;
        obj.C = [ [ obj.C( prec_range, prec_range ), prec( prec_range )', ...
                    obj.C( prec_range, succ_range ) ]; ...
                  [ succ( prec_range ), false, succ( succ_range ) ]; ...
                  [ obj.C( succ_range, prec_range ), prec( succ_range )', ...
                    obj.C( succ_range, succ_range ) ] ];
    end
    obj.C = logical( obj.C );
    obj.Card = N + 1;
    obj.L = []; % reset links
end

