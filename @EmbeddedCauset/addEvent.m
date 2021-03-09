function e = addEvent( obj, varargin )
%ADDEVENT    Adds an event to the causet.
% 
% Arguments:
% obj                 Embedded causet class object.
% 
% Optional arguments:
% coordinates         Use 'at' followed by a coordinate vector to place the
%                     new event at a given position.
% OR
% position            Use 'intervalfuture' or 'intervalpast' (Default) to 
%                     add an event to the future or past of all other 
%                     events, respectively. 
%                     The coordinates will be assigned automatically.
% OR
% prec_list           Logical selection vector or set of events that 
%                     precede the new event.
% succ_list           Logical selection vector or set of events that 
%                     succeed the new event. 
%                     The coordinates will be assigned automatically.
% 
% Returns:
% e                   Event that was added.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 1, 3 );
    if ( nargin > 1 ) && strcmp( varargin{ 1 }, 'at' )
        e = addEvent@Causet( obj, 'futureinf' );
        % assign coordinates:
        obj.Coords( e, : ) = varargin{ 2 };
        % sort by time, re-find event:
        [ sortedtime, I ] = sort( obj.Coords( :, 1 ) ); %#ok<ASGLU>
        obj.Coords = obj.Coords( I, : );
        e = find( I == e );
        % reset causal relations:
        obj.relate();
    else
        e = addEvent@Causet( obj, varargin{:} );
        obj.embedEvent( e );
    end
end

