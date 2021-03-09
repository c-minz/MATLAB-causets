function varargout = EmbeddingRange( src, snk, at, metric, coordsys )
%EMBEDDINGRANGE    Returns the range (minimum and maximum) of one 
%   coordinate in the Cartesian coordinate tuple 'at'.  The Cartesian 
%   coordinate vectors src and snk determine the Alexandrov subset of the 
%   spacetime. 
%   The returned range is a line segment of the Alexandrov subset. 
% 
% Arguments:
% src                 Coordinate vector of the past event of the Alexandrov
%                     subset.
% snk                 Coordinate vector of the future event of the 
%                     Alexandrov subset.
% at                  Coordinate vector at which the Alexandrov subset is 
%                     intersected. A coordinate range will be returned for
%                     the one coordinate value that is set to NaN.
% 
% Optional arguments:
% metric              Name of the spacetime metric.
%                     Default: 'Minkowski' (currently the only option)
% coordsys            Name of the coordinate system.
%                     Default: 'Cartesian' (currently the only option)
% 
% Returns:
% I                   Two element (column) vector with minimum and maximum 
%                     of the coordinate range.
% [ min, max ]        Minimum and maximum of the range.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 3, 5 );
    varargout = cell( 1, nargout );
    if nargin < 4
        metric = 'Minkowski';
    end
    if nargin < 5
        coordsys = 'Cartesian';
    end
    if strcmp( metric, 'Minkowski' ) && strcmp( coordsys, 'Cartesian' )
        if length( at ) == 2
            if isnan( at( 1 ) ) % determine time range:
                I = [ max( -at( 2 ) + src( 2 ) + src( 1 ), ...
                            at( 2 ) - snk( 2 ) + snk( 1 ) ); ...
                      min(  at( 2 ) - src( 2 ) + src( 1 ), ...
                           -at( 2 ) + snk( 2 ) + snk( 1 ) ) ];
            else
                I = [ max( -at( 1 ) + src( 1 ) + src( 2 ), ...
                            at( 1 ) - snk( 1 ) + snk( 2 ) ); ...
                      min(  at( 1 ) - src( 1 ) + src( 2 ), ...
                           -at( 1 ) + snk( 1 ) + snk( 2 ) ) ];
            end
            if nargout < 2
                varargout{ 1 } = I;
            else
                varargout{ 1 } = I( 1 );
                varargout{ 2 } = I( 2 );
            end
        end
    end
end
