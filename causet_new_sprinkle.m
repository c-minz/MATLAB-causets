function [ coordinates, coordinateranges, volume, events ] = causet_new_sprinkle( N, d, ...
    stshape, reducevolumeparams, rndstream, shapeparam )
%CAUSET_NEW_SPRINKLE generates causet coordinates by sprinkling N events 
% into a D dimensional SPACETIME volume with a given SHAPE. 
% 
% Arguments:
% N                   number of events to be sprinkled.
% D                   number of spacetime dimensions.
% 
% Optional arguments:
% STSHAPE             specifies the spacetime shape of the sprinkling
%                     region.
%    'bicone'         ball-shape in space-dimensions, scaled down into 
%                     the future and into the past - forming a bicone. 
%                     (Default)
%    'cube'           cube shape.
%    'cuboid'         cuboid shape.
%    'closeddoublecone' same as bicone.
%    'cylinder'       ball-shape in space-dimensions, stacked to a cylinder
%                     along the time-dimension.
%    '*cylinder'      cylinder shape with 2 times (* = bi), 3 times 
%                     (* = tri), 10 times (* = dec) default height.
%    'ball'           spacetime ball.
%    'diamond'        cube-shape in space-dimensions, scaled down into the 
%                     future and into the past - forming a closed diamond.
% REDUCEVOLUMEPARAMS  parameters to define selections of events for a 
%                     reduced volume. Currently supported for the
%                     bicone sprinkling only. Default: [ 0, 1 ]. 
%                     The first parameter is the relative factor TO which 
%                     the volume is reduced with every step from the 
%                     future and/or from the past. 
%                     The second parameter is the number of iterations
%                     (number of volume splits plus 1). 
%                     As an optional third value, it can be specified if 
%                     the volume is reduced from the future (-1, default),
%                     from the past (1) or both (0).
% RNDSTREAM           stream for random number generation. Use 'global' to 
%                     select the global stream (Default).
% SHAPEPARAM          is a single number (radius and size) for 
%                     'bicone', 'ball' and 'diamond'. 'cylinder' and 
%                     'cube' also allow for a single number, which gives 
%                     the size in positive and negative coordinate 
%                     directions. (Default)
%
%                     A 'cuboid' asks for a [ 2, d ] matrix 
%                     for the COORDINATERANGES. 
%                     Passing a { [ 2, 1 ], 1 } cell array for 'cylinder', 
%                     allows to specify the time coordinate range as 
%                     [ 2, 1 ] matrix in the first cell, and the cylinder 
%                     radius in the second cell.
% 
% Returns:
% COORDINATES         positions of the points in a [ N, d ] matrix.
% COORDINATERANGES    [ 2, d ] matrix with minimal and maximal values, 
%                     which are possible for each dimension.
% VOLUME              of the spacetime shape.
% EVENTS              logical [ N, n ] matrix as selections of n subvolumes
%                     for the N sprinkled events. The first column is the
%                     entire set.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    %% set start up parameter:
    if nargin < 3
        stshape = 'bicone';
    else
        stshape = lower( stshape );
    end
    if strcmp( stshape, 'closeddoublecone' )
        stshape = 'bicone';
    end
    if nargin < 4 || isempty( reducevolumeparams )
        reducevolumeparams = [ 0, 1 ];
    elseif length( reducevolumeparams ) < 2
        reducevolumeparams = [ reducevolumeparams, 2 ];
    end
    if nargin < 5 || strcmp( rndstream, 'global' )
        rndstream = RandStream.getGlobalStream;
    end
    if nargin < 6
        shapeparam = 1;
    end
    if length( shapeparam ) == 1
        if strcmp( stshape, 'cube' )
            shapeparam = shapeparam * ones( 2, d );
            shapeparam( 1, : ) = -shapeparam( 1, : );
            stshape = 'cuboid';
        elseif strcmp( stshape, 'cylinder' ) || strcmp( stshape, 'bicylinder' ) || ...
           strcmp( stshape, 'tricylinder' ) || strcmp( stshape, 'deccylinder' )
            cylsize = shapeparam;
            shapeparam = cell( 2, 1 );
            shapeparam{ 1 } = cylsize * [ -1; 1 ];
            shapeparam{ 2 } = cylsize;
            stshape = 'cylinder';
        end
    end
    if strcmp( stshape, 'bicylinder' )
        shapeparam{ 1 } = 2 * shapeparam{ 1 };
    elseif strcmp( stshape, 'tricylinder' )
        shapeparam{ 1 } = 3 * shapeparam{ 1 };
    elseif strcmp( stshape, 'deccylinder' )
        shapeparam{ 1 } = 10 * shapeparam{ 1 };
    end
    %% allocate memory for coordinates:
    isBicone = strcmp( stshape, 'bicone' );
    if isBicone
        spaceradii = zeros( N, 1 );
    end
    coordinates = zeros( N, d );
    coordinateranges = zeros( 2, d );
    %% sprinkle in d-dimensional spacetime:
    if strcmp( stshape, 'ball' ) || strcmp( stshape, 'cylinder' ) || isBicone 
        % set parameters for shapes based on a ball:
        isCylinder = strcmp( stshape, 'cylinder' );
        if strcmp( stshape, 'ball' )
            balldstart = 1; % start dimenion for ball
            ballrad = shapeparam; % ball radius
        elseif isBicone
            balldstart = 2;
            ballrad = shapeparam;
            coordinateranges( :, 1 ) = ballrad * [ -1; 1 ];
        else
            balldstart = 2;
            coordinateranges( :, 1 ) = shapeparam{ 1 };
            ballrad = shapeparam{ 2 };
        end
        % compute volume:
        if strcmp( stshape, 'ball' )
            volume = ballrad^d * pi^( d / 2 ) / gamma( d / 2 + 1 );
        else
            volume = ballrad^( d - 1 ) * pi^( d / 2 - 0.5 ) / gamma( d / 2 + 0.5 );
            volume = ( coordinateranges( 2, 1 ) - coordinateranges( 1, 1 ) ) * volume;
            if isBicone
                volume = volume / d;
            end
        end
        balld = d - balldstart + 1; % number of ball dimensions
        % set coordinate ranges for ball:
        coordinateranges( 1, balldstart : d ) = -ballrad * ones( 1, balld );
        coordinateranges( 2, balldstart : d ) = ballrad * ones( 1, balld );
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
                spaceradii( i ) = rscaling * ballrad;
            elseif isCylinder
                % get time coordinate:
                coordinates( i, 1 ) = ...
                    coordinateranges( 1, 1 ) + ...
                    ( coordinateranges( 2, 1 ) - ...
                      coordinateranges( 1, 1 ) ) .* rand( rndstream );
            end
            % make coordinates uniform:
            coordinates( i, balldstart : d ) = ...
                ( rscaling * ballrad / r ) .* ...
                coordinates( i, balldstart : d );
        end
    elseif strcmp( stshape, 'cuboid' ) || strcmp( stshape, 'diamond' )
        % set parameters for shapes based on a cube/cuboid:
        isDiamond = strcmp( stshape, 'diamond' );
        scaling = sqrt( d - 1 );
        if isDiamond
            cubedstart = 2; % start dimension for cube
            coordinateranges( 1, : ) = -shapeparam * ones( 1, d );
            coordinateranges( 2, : ) = shapeparam * ones( 1, d );
            coordinateranges( :, 1 ) = scaling * coordinateranges( :, 1 );
        else
            cubedstart = 1;
            coordinateranges = shapeparam;
        end
        % compute volume:
        volume = 1;
        for i = 1 : d
            volume = ( coordinateranges( 2, i ) - coordinateranges( 1, i ) ) * volume;
        end
        if isDiamond
            volume = volume / d;
        end
        cubed = d - cubedstart + 1; % number of cube dimenions
        % pick N random coordinate tuples uniformly:
        if isDiamond
            for i = 1 : N
                signs = ceil( 2^d * rand( rndstream ) );
                % get time coordinate in upper or lower pyramid:
                csign = 2 * mod( signs, 2 ) - 1;
                signs = floor( signs / 2 );
                hrand = 1 - rand( rndstream )^( 1 / d );
                coordinates( i, 1 ) = csign * ( scaling * shapeparam ) * hrand;
                % get space coordinates using uniform distribution:
                for idim = cubedstart : d
                    csign = 2 * mod( signs, 2 ) - 1;
                    signs = floor( signs / 2 );
                    coordinates( i, idim ) = ...
                        csign * ( 1 - hrand ) * shapeparam * rand( rndstream );
                end
            end
        else
            for i = 1 : N
                % get coordinates using uniform distribution:
                coordinates( i, cubedstart : d ) = ...
                    coordinateranges( 1, cubedstart : d ) + ...
                    ( coordinateranges( 2, cubedstart : d ) - ...
                      coordinateranges( 1, cubedstart : d ) ) .* ...
                      rand( rndstream, 1, cubed );
            end
        end
    end
    %% sort by coordinate time:
    [ sortedtime, I ] = sort( coordinates( :, 1 ) );
    coordinates = coordinates( I, : );
    %% select events:
    events = true( N, abs( reducevolumeparams( 2 ) ) );
    if isBicone
        spaceradii = spaceradii( I );
        if ( reducevolumeparams( 2 ) < 0 ) % single volume
            m_range = 1;
            m_offset = 0;
            tau = 2 * ballrad * reducevolumeparams( 1 )^( 1 / d );
        else
            volumesplits = reducevolumeparams( 2 ) - 1;
            m_range = volumesplits : -1 : 1;
            m_offset = 1;
            tau = 2 * ballrad ...
                * reducevolumeparams( 1 ).^( ( 1 : volumesplits ) / d );
        end
        reducefuture = ( length( reducevolumeparams ) == 2 ) ...
            || ( reducevolumeparams( 3 ) == -1 ); % also default
        reducepast = ( length( reducevolumeparams ) > 2 ) ...
            && ( reducevolumeparams( 3 ) == 1 );
        reduceboth = ( length( reducevolumeparams ) > 2 ) ...
            && ( reducevolumeparams( 3 ) == 0 );
        if reduceboth
            biconetip = tau / 2;
        else
            biconetip = tau - ballrad;
        end
        for i = 1 : N
            for m = m_range
                if ( reducefuture && ( spaceradii( i ) ...
                        < biconetip( m ) - sortedtime( i ) ) ) ...
                || ( reducepast && ( spaceradii( i ) ...
                        < biconetip( m ) + sortedtime( i ) ) ) ...
                || ( reduceboth && ( spaceradii( i ) ...
                        < biconetip( m ) - sortedtime( i ) ) ...
                    && ( spaceradii( i ) ...
                        < biconetip( m ) + sortedtime( i ) ) )
                    % events is in this and further volumes:
                    break
                else
                    % events is not in this volume:
                    events( i, m + m_offset ) = false;
                    % ... but perhaps in further volumes:
                    continue
                end
            end
        end
    end
end
