function i = addSelsTimeLayers( obj, t, k, i )
%ADDSELSTIMELAYERS    Adds an event selection for a k-layers Cauchy slice 
%   at coordinate time t towards the future (if k > 0) and towards the 
%   past (if k < 0).
% 
% Arguments:
% obj                 Embeddedcauset class object.
% t                   Coordinate time.
% 
% Optional arguments:
% k                   Number of added layers. k > 0 for layers towards 
%                     future, k < 0 for layers towards past. 
%                     With k = +/-Inf, all layers towards future/past 
%                     infinity are added, respectively.
%                     If k is a vector, then all k-layers are added (all k
%                     values have to have the same sign).
%                     Default: 0 (antichain)
% i                   Index of selection to which the Cauchy layer will be
%                     added.
%                     Default: 0 (add new selection item)
% 
% Returns:
% i                   Index of added selection.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    if nargin < 3
        k = 0;
    end
    if nargin < 4
        i = 0;
    end
    i = obj.addSelsLayers( obj.TimeSlice( t ), k, i, 'Cauchy', t );
end
