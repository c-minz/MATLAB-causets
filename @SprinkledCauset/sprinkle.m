function sprinkle( obj, N )
%SPRINKLE    Generates causet coordinates by sprinkling events into a d 
%   dimensional spacetime volume with a given shape. 
% 
% Arguments:
% obj                 Sprinkledcauset class object.
% 
% Optional arguments:
% N                   Number (integer) of events to be sprinkled or double
%                     value as expected number parameter for Poisson 
%                     distribution. By default, it uses the cardinality 
%                     obj.card.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    %% initialise parameter:
    if ( nargin < 2 ) || isempty( N )
        N = obj.Card;
    end
    if isinteger( N )
        obj.lambda = [];
    else
        obj.lambda = N;
        N = int32( poissrnd( N ) );
    end
    shape = obj.Shape;
    shaperanges = obj.ShapeRanges;
    rndstream = obj.RandStream;
    isBicone = strcmp( shape, 'bicone' );
    isCylinder = strcmp( shape, 'cylinder' );
    d = obj.Dim;
    %% allocate memory for coordinates:
    if isBicone
        maxspaceradii = zeros( N, 1 );
    end
    coordinates = zeros( N, d );
    %% sprinkle in d-dimensional spacetime:
    if strcmp( shape, 'ball' ) || strcmp( shape, 'cylinder' ) || isBicone 
        % set parameters for shapes based on a ball:
        if strcmp( shape, 'ball' )
            balldstart = 1; % start dimension for ball
            ballrad = obj.ShapeParam; % ball radius
        elseif isBicone
            balldstart = 2;
            ballrad = obj.ShapeParam;
        else
            balldstart = 2;
            ballrad = obj.ShapeParam{ 2 };
        end
        balld = d - balldstart + 1; % number of ball dimensions
        % pick N random coordinate tuples uniformly:
        for i = 1 : N
            % get coordinates on sphere using normal distribution:
            coordinates( i, balldstart : d ) = randn( rndstream, 1, balld );
            r = sqrt( sum( coordinates( i, balldstart : d ).^2 ) );
            rscaling = rand( rndstream )^( 1 / balld );
            if isBicone
                % get time coordinate in upper or lower cone:
                hrand = rand( rndstream )^( 1 / d );
                hsign = 2 * round( rand( rndstream ) ) - 1;
                coordinates( i, 1 ) = hsign * ( 1 - hrand ) * ballrad;
                rscaling = hrand * rscaling; % squeeze radius
                maxspaceradii( i ) = rscaling * ballrad;
            elseif isCylinder
                % get time coordinate:
                coordinates( i, 1 ) = ...
                    shaperanges( 1, 1 ) + ...
                    ( shaperanges( 2, 1 ) - ...
                      shaperanges( 1, 1 ) ) .* rand( rndstream );
            end
            % make coordinates uniform:
            coordinates( i, balldstart : d ) = ...
                ( rscaling * ballrad / r ) .* ...
                coordinates( i, balldstart : d );
        end
    elseif strcmp( shape, 'cube' ) || strcmp( shape, 'cuboid' ) ...
        || strcmp( shape, 'diamond' )
        % set parameters for shapes based on a cube/cuboid:
        isDiamond = strcmp( shape, 'diamond' );
        scaling = sqrt( d - 1 );
        if isDiamond
            cuboidstart = 2; % start dimension for cube
        else
            cuboidstart = 1;
        end
        cuboidd = d - cuboidstart + 1; % number of cube dimenions
        % pick N random coordinate tuples uniformly:
        if isDiamond
            shapeparam = obj.ShapeParam;
            for i = 1 : N
                signs = ceil( 2^d * rand( rndstream ) );
                % get time coordinate in upper or lower pyramid:
                csign = 2 * mod( signs, 2 ) - 1;
                signs = floor( signs / 2 );
                hrand = 1 - rand( rndstream )^( 1 / d );
                coordinates( i, 1 ) = csign * ( scaling * shapeparam ) * hrand;
                % get space coordinates using uniform distribution:
                for idim = cuboidstart : d
                    csign = 2 * mod( signs, 2 ) - 1;
                    signs = floor( signs / 2 );
                    coordinates( i, idim ) = ...
                        csign * ( 1 - hrand ) * shapeparam * rand( rndstream );
                end
            end
        else
            for i = 1 : N
                % get coordinates using uniform distribution:
                coordinates( i, cuboidstart : d ) = ...
                    shaperanges( 1, cuboidstart : d ) + ...
                    ( shaperanges( 2, cuboidstart : d ) - ...
                      shaperanges( 1, cuboidstart : d ) ) .* ...
                      rand( rndstream, 1, cuboidd );
            end
        end
    end
    %% sort by coordinate time:
    [ sortedtime, I ] = sort( coordinates( :, 1 ) ); %#ok<ASGLU>
    coordinates = coordinates( I, : );
    %% store to object:
    obj.Card = int32( N );
    obj.Coords = coordinates;
    if isBicone
        obj.MaxSpaceRadii = maxspaceradii( I );
    end
end
