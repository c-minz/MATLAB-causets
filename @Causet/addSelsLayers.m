function i = addSelsLayers( obj, list, k, i, type, param )
%ADDSELSLAYERS    Adds an event selection of the k-layers of list.
% 
% Arguments:
% obj                 Causet class object.
% list                Logical vector or list of events from which the 
%                     layers are taken. If k >= 0, the layers are taken 
%                     from the past of events. Otherwise they are taken 
%                     from the future of events.
% 
% Optional arguments:
% k                   Number of layers. k > 0 for layers towards future, 
%                     k < 0 for layers towards past. With k = +/-Inf, all
%                     layers towards future/past infinity are added,
%                     respectively.
%                     If k is a vector, then all k-layers are added (all k
%                     values have to have the same sign).
%                     Default: 0 (antichain)
% i                   Index of selection to which the layers will be
%                     added.
%                     Default: 0 (add new selection item)
% type                Specifies the type name of the selection.
%                     Default: 'layers'
% param               Specifies the parameters of the selection. It adds
%                     as last element to a cell array.
%                     Default: k
% 
% Returns:
% i                   Index of added selection.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    %% initialise, set defaults:
    if islogical( list )
        events_sel = list;
    else
        events_sel = false( 1, obj.Card );
        events_sel( list ) = true;
    end
    if nargin < 3
        k = 0;
    end
    if ( nargin < 4 ) || ( length( i ) ~= length( k ) )
        i = zeros( 1, length( k ) );
    end
    if nargin < 5
        type = 'layers';
    end
    if nargin < 6
        param = {};
    elseif ~iscell( param )
        param = { param };
    end
    %% identify and add k-layers:
    kmax = max( abs( k ) );
    if k( 1 ) < 0
        kmax = -kmax;
    end
    lnums = obj.LayerNumbers( events_sel, kmax );
    if kmax >= 0 % select layers from future
        for j = 1 : length( k )
            kj = k(j);
            if ~isinf( kj )
                events_sel = lnums <= kj;
            end
            i(j) = obj.addSels( events_sel, i(j), type, [ param, {kj} ] );
        end
    else%if kmax < 0 % select layers from past
        for j = 1 : length( k )
            kj = k(j);
            if ~isinf( kj )
                events_sel = lnums >= kj;
            end
            i(j) = obj.addSels( events_sel, i(j), type, [ param, {kj} ] );
        end
    end
end
