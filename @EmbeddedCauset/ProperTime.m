function propertime = ProperTime( obj, a, b, signed )
%PROPERTIME    Returns the proper distance between the single events A and
%   B. The value is NaN if A and B are not related. If SIGNED = true, the 
%   value is positive if B is in the future of A and negative if A is in 
%   the future of B.
% 
% Arguments:
% obj                 Causet class object.
% a                   Event index.
% b                   Event index.
% 
% Optional arguments:
% signed              Include the causal order between A and B as sign in 
%                     the return value.
%                     Default: false
% 
% Returns:
% propertime          Proper time (square root of the Minkowski metric 
%                     square) from event A to event B or NaN if A and B 
%                     are not causally related. If SIGNED = true, the 
%                     value is positive if A < B, negative if A > B.
% 
% Copyright 2024, C. Minz. BSD 3-Clause License.

    narginchk( 3, 4 );
    if ( length( a ) ~= 1 ) && ( length( b ) ~= 1 )
        error( 'Inputs A and B must be single event indices.' );
    end
    if nargin < 4
        signed = false;
    end
    
    propertime = NaN;  % default for not causally related
    if strcmp( obj.Metric, 'Minkowski' )
        d = obj.Dim;
        dcoord = obj.Coords( b, : ) - obj.Coords( a, : );
        metricmeasure = dcoord( 1, 1 )^2 - sum( dcoord( 1, 2:d ).^2 );
        if metricmeasure < 0.0
            return
        end
        propertime = sqrt(metricmeasure);
        if signed && obj.isCausal( b, a )
            propertime = -propertime;
        end
    else
        error( 'Metrics other than Minkowski are not implemented.' );
    end
end

