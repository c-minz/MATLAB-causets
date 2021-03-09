function lnums = LayerNumbers( obj, list, kmax )
%LAYERNUMBERS    Returns a vector of the layer numbers up to kmax.
% 
% Arguments:
% obj                 Causet class object.
% list                Logical selection vector for the events to be tested.
% kmax                Maximal number of layers. If sign(kmax)=+/-1, the 
%                     layer numbers will start from the past/future 
%                     "infinity" of the selection, respectively.
% 
% Returns:
% lnums               Row vector of length N that contains the layer number
%                     for each element (relative to the set events). Not
%                     identified events are recorded by NaN.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    lnums = nan( 1, obj.Card ); % pre-allocate memory
    events_sel = obj.SelOf( list );
    s = sign( kmax );
    kmax = abs( kmax );
    for i = obj.SetOf( list )
        lnum = 0;
        if s > 0
            for j = find( obj.PastOf( i, 'return', 'sel' ) & events_sel )
                lnum = max( obj.Interval( j, i, 'return', 'card' ) - 1, lnum );
            end
        else
            for j = find( obj.FutureOf( i, 'return', 'sel' ) & events_sel )
                lnum = max( obj.Interval( i, j, 'return', 'card' ) - 1, lnum );
            end
        end
        if lnum <= kmax
            lnums( i ) = s * lnum;
        end
    end
end
