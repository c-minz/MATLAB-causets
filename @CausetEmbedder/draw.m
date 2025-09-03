function [ handles, plotobj ] = draw( obj, varargin )
%DRAW    Creates a 2D pseudo-embedding of the causet and plots the result.
% 
% Arguments:
% obj                 Causet class object.
% 
% Optional arguments: (each key has to be followed by a value)
% 'Antichain'         Set of events that form a maximal antichain. Every
%                     embedding attempt will start with this antichain. If
%                     unset, multiple antichains will be tested.
%                     Default: (automatically determined)
% 'PlotPause'         Set pause time to show progress of diagram drawing.
%                     Default: 0 (no progress drawings, only final result)
% ( ... )             See @embeddedcauset.plot
% 
% Returns:            
% handles             See EmbeddedCauset.plot
% plotobj             The generated Embedded causet class object.
    
%     plotargsbegin = 1;
%     ac = [];
%     plotpause = 0;
%     for i = 1:2:length( varargin )
%         key = varargin{ i };
%         value = varargin{ i + 1 };
%         if strcmpi( key, 'antichain' )
%             ac = value;
%         elseif strcmpi( key, 'plotpause' )
%             plotpause = value;
%         else
%             break
%         end
%         plotargsbegin = plotargsbegin + 2;
%     end
%     varargin = varargin( plotargsbegin : length( varargin ) );
%     plotobj = embeddedcauset.createDiagram( obj, ac, plotpause, varargin{:} );
%     plotobj.removeevents( plotobj.card );
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    %% temporary test:
    ac = obj.CentralAntichain();
    coords = zeros( obj.Card, 2 );
    t = 0; dt = 1;
    while ~isempty( ac )
        ac_len = length( ac );
        coords( ac, 1 ) = t;
        if ac_len == 1
            coords( ac, 2 ) = 0;
        else
            x = ( ac_len - 1 ) * sqrt( 1 / double( obj.Card ) + 1 / ac_len^2 );
            coords( ac, 2 ) = linspace( -x, x, ac_len );
        end
        ac = obj.PastInfOf( obj.FutureOf( ac ) );
        t = t + dt;
    end
    ac = obj.FutureInfOf( obj.PastOf( obj.CentralAntichain() ) );
    t = -dt;
    while ~isempty( ac )
        ac_len = length( ac );
        coords( ac, 1 ) = t;
        if ac_len == 1
            coords( ac, 2 ) = 0;
        else
            x = ( ac_len - 1 ) * sqrt( 1 / double( obj.Card ) + 1 / ac_len^2 );
            coords( ac, 2 ) = linspace( -x, x, ac_len );
        end
        ac = obj.FutureInfOf( obj.PastOf( ac ) );
        t = t - dt;
    end
    plotobj = EmbeddedCauset( 2, 'Causet', obj, 'Coords', coords );
    %% plot and return:
    axis off
    handles = plotobj.plot( 'AxisStyle', 'equal', 'AxisLimits', 'auto', ...
        varargin{:} );
end
