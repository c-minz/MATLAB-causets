function initShape( obj, d, shape, shapeparam )
%INITSHAPE    Defines the embedding pre-compact spacetime region.
% 
% Arguments:
% obj                 Embeddedcauset class object.
% 
% Optional arguments:
% d                   (Spacetime) Dimension of the shape. Default: 4
% shape               Specifies the shape of a pre-compact region in 
%                     spacetime. All coordinates are measured in the same 
%                     dimensionless units. 
%                     Default: 'bicone'
%   'bicone'          Ball-shape in space dimensions, conically scaled into 
%                     future and past. It extends the same length in all 
%                     dimensions from -x to x, by default x=1. x can be set
%                     by a single double value in shapeparam.
%   'closeddoublecone' Same as bicone.
%   'ball'            Spacetime ball (in all spacetime dimensions). The
%                     radius can be specified as shapeparam (default 1).
%   'cube'            Cube shape in all spacetime dimensions. The half-
%                     length can be specified as shapeparam (default 1).
%   'cuboid'          Cuboid shape with different coordinate ranges in all 
%                     spacetime dimensions. Specifying no length parameter 
%                     or a single parameter value turns it into a 'cube'. 
%                     Set all ranges by a [2,d] double matrix for min and 
%                     max values of the coordinates, respectively.
%   'cylinder'        Ball-shape in space dimensions, equally stacked to a 
%                     cylinder along the time dimension. The ranges can be 
%                     identically set as for 'bicone'. Use a [2,1] double 
%                     matrix as first length parameter for the time range 
%                     and a second length parameter for the space radius.
%   '*cylinder'       Cylinder shape with 2 times (* = bi), 3 times 
%                     (* = tri), 10 times (* = dec) the height.
%   'diamond'         Cube-shape in space dimensions, conically scaled into 
%                     future and past. The ranges are identically set as 
%                     for 'bicone'.
% shapeparam          Shape parameter(s). Default: 1
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    %% set shape and shapeparam:
    if ( nargin < 2 ) || isempty( d ) || ( d < 1 )
        d = 4;
    end
    if ( nargin < 3 ) || isempty( shape )
        shape = 'bicone';
    end
    if ( nargin < 4 ) || isempty( shapeparam )
        shapeparam = 1;
    end
    shape = lower( shape );
    if strcmp( shape, 'closeddoublecone' )
        shape = 'bicone';
    end
    if length( shapeparam ) == 1
        if strcmp( shape, 'cuboid' )
            shapeparam = shapeparam * ones( 2, d );
            shapeparam( 1, : ) = -shapeparam( 1, : );
        elseif strcmp( shape, 'cylinder' ) || strcmp( shape, 'bicylinder' ) || ...
           strcmp( shape, 'tricylinder' ) || strcmp( shape, 'deccylinder' )
            cylsize = shapeparam;
            shapeparam = cell( 2, 1 );
            shapeparam{ 1 } = cylsize * [ -1; 1 ];
            shapeparam{ 2 } = cylsize;
            shape = 'cylinder';
        end
    end
    if strcmp( shape, 'bicylinder' )
        shapeparam{ 1 } = 2 * shapeparam{ 1 };
    elseif strcmp( shape, 'tricylinder' )
        shapeparam{ 1 } = 3 * shapeparam{ 1 };
    elseif strcmp( shape, 'deccylinder' )
        shapeparam{ 1 } = 10 * shapeparam{ 1 };
    end
    obj.Dim = d;
    obj.Shape = shape;
    obj.ShapeParam = shapeparam;
    %% set coordinateranges:
    shaperanges = zeros( 2, d );
    if strcmp( shape, 'ball' ) || strcmp( shape, 'cylinder' ) ...
        || strcmp( shape, 'bicone' ) 
        if strcmp( shape, 'ball' )
            balldstart = 1; % start dimension for ball
            ballrad = shapeparam; % ball radius
        elseif strcmp( shape, 'bicone' )
            balldstart = 2;
            ballrad = shapeparam;
            shaperanges( :, 1 ) = ballrad * [ -1; 1 ];
        else
            balldstart = 2;
            shaperanges( :, 1 ) = shapeparam{ 1 };
            ballrad = shapeparam{ 2 };
        end
        balld = d - balldstart + 1; % number of ball dimensions
        shaperanges( 1, balldstart : d ) = -ballrad * ones( 1, balld );
        shaperanges( 2, balldstart : d ) = ballrad * ones( 1, balld );
    elseif strcmp( shape, 'diamond' ) || strcmp( shape, 'cube' )
        shaperanges( 1, : ) = -shapeparam * ones( 1, d );
        shaperanges( 2, : ) = shapeparam * ones( 1, d );
        if strcmp( shape, 'diamond' )
            shaperanges( :, 1 ) = sqrt( d - 1 ) * shaperanges( :, 1 );
        end
    elseif strcmp( shape, 'cuboid' )
        shaperanges = shapeparam;
    end
    obj.ShapeRanges = shaperanges;
end
