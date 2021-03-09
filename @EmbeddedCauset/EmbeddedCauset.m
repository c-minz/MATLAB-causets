classdef EmbeddedCauset < Causet
%EMBEDDEDCAUSET    Class for causal sets that are embedded in a spacetime 
%   region, so that there are coordinates for each causal set event.
% 
% Arguments:
% d                   Dimension of the spacetime for the sprinkling
%                     process.
% 
% Optional arguments by key-value pairs:
% Causet              A Causet base class object that is to be embedded.
% Metric              Name of the embedding spacetime (metric). Supported
%                     are 'Minkowski' (default value), 'Schwarzschild' and 
%                     'EddingtonFinkelstein'. The black hole spacetimes
%                     are parametrized. To set the parameter, use a cell
%                     array as value with the metric name in the first cell
%                     followed by the metric parameters. For the
%                     black hole spacetimes, the accepted parameter is
%                     the event horizon radius (1.0 by default).
% Shape               Name of the coordinate shape of the embedding region
%                     (as first value in a cell, followed by the parameters
%                     of the shape). For possible values, see initShape.
%                     Default (for 'Minkowski'): 'bicone'
%                     Default (for other metrics): 'cylinder'
% Coords              Coordinate matrix of shape N x d for the coordinates 
%                     of the events. The cardinality N is determined by 
%                     size of the first dimension of the matrix.
% CoordSys            Name of the used coordinate system. Accepted values
%                     are 'Cartesian' and 'spherical'.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    properties(SetAccess = protected)
        Metric % char: Name of the metric: 'Minkowski', 'Schwarzschild' or 'EddingtonFinkelstein'
        MetricParam % cell: Parameters, depending on the type of metric.
        Dim % double: Spacetime dimension.
        Shape % char: Name of the shape in spacetime.
        ShapeParam % cell: Parameters, depending on the type of shape.
        ShapeRanges % [2,d] double: Cartesian coordinate min and max of the shape.
        Volume % double: Size of the spacetime volume.
        CoordSys % char: Name of the coordinate system: 'Cartesian', 'spherical' (cylindrical in spacetime)
        Coords % [obj.card,obj.dim] double: Coordinates of causet events.
    end
    properties(Access = protected)
        MaxSpaceRadii % [N,d] double: Maximal space radius per event.
    end
    
    methods
        function obj = EmbeddedCauset( d, varargin )
            %% set defaults:
            obj.Metric = 'Minkowski';
            obj.Volume = [];
            obj.Card = 0;
            obj.CoordSys = 'Cartesian';
            obj.Coords = zeros( 0, d );
            obj.MaxSpaceRadii = [];
            isshapeinit = false;
            %% read key-value pairs:
            for i = 1:2:length( varargin )
                key = lower( varargin{ i } );
                value = varargin{ i + 1 };
                isvaluesupported = true;
                if strcmp( key, 'causet' )
                    isvaluesupported = isa( value, 'Causet' );
                    if isvaluesupported
                        obj.copyCausals( value );
                        evcard = size( obj.C, 1 );
                        obj.Card = evcard;
                        obj.Coords = NaN( evcard, d );
                    end
                elseif strcmp( key, 'metric' )
                    isvaluesupported = iscell( value ) ...
                        || ischar( value ) || isstring( value );
                    if isvaluesupported && iscell( value )
                        obj.Metric = value{ 1 };
                        obj.MetricParam = value( 2:length(value) );
                    elseif isvaluesupported
                        obj.Metric = value;
                    end
                elseif strcmp( key, 'shape' )
                    if ischar( value ) || isstring( value ) || isempty( value )
                        obj.initShape( d, value );
                        isshapeinit = true;
                    elseif iscell( value )
                        obj.initShape( d, value{1}, value{2:length(value)} );
                        isshapeinit = true;
                    else
                        isvaluesupported = false;
                    end
                elseif strcmp( key, 'coordsys' ) || strcmp( key, 'coordinatesystem' )
                    isvaluesupported = ischar( value ) || isstring( value );
                    if isvaluesupported
                        obj.CoordSys = value;
                    end
                elseif strcmp( key, 'coords' ) || strcmp( key, 'coordinates' )
                    isvaluesupported = isnumeric( value ) && ...
                        ( size( value, 2 ) == d );
                    if isvaluesupported
                        obj.Coords = value;
                        obj.Card = size( value, 1 );
                        if ~isshapeinit
                            ranges = zeros( 2, size( value, 2 ) );
                            for k = 1 : size( value, 2 )
                                ranges( :, k ) = ...
                                    [ min( value( :, k ) ), max( value( :, k ) ) ];
                            end
                            obj.initShape( d, 'cuboid', ranges );
                            isshapeinit = true;
                        end
                    end
                else
                    warning( 'Key ''%s'' is unknown.', key );
                end
                if ~isvaluesupported
                    warning( 'Value type ''%s'' is not supported for key ''%s''.', ...
                        class( value ), key );
                end
            end
            %% initialise:
            if ~isshapeinit
                if strcmp( obj.Metric, 'Minkowski' )
                    obj.initShape( d, 'bicone' );
                else
                    obj.initShape( d, 'cylinder' );
                end
            end
        end
        
        function vol = get.Volume( obj )
            if isempty( obj.Volume )
                obj.Volume = calcVolume( obj );
            end
            vol = obj.Volume;
        end
        
        transformCoords( obj, newcoordsys );
        
        [ handles, dims ] = plot( obj, varargin );
        
        s = TimeSlice( obj, t, k, varargin );
        
        %% causals:
        addEvent( obj, varargin );
        removeEvents( obj, varargin );
        relate( obj );
        R = EmbeddingRegion( obj, e, spacelike, R );
        e_crds = embedEvent( obj, e, ac, direction, method );
        e_crds = triangulate( obj, e, ac, direction );
        n = countLinkCrossings( obj, list, dims, includeEndPoints );
        
        %% selections:
        addSelsTimeLayers( obj, t, k, i );
    end
    
    methods(Static, Access = public)
        objs = create( srcobj, ac, method, timeout, plotpause, varargin );
        plotobj = createDiagram( srcobj, ac, plotpause, varargin );
        
        varargout = LightIntersect( pt_a, pt_b, metric, coordsys );
        varargout = EmbeddingRange( src, snk, at, metric, coordsys );
        
        test_embedding;
    end
    
    methods(Access = protected)
        initShape( obj, shapedim, shape, shapeparam );
        vol = calcVolume( obj );
    end
end

