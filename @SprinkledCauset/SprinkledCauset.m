classdef SprinkledCauset < EmbeddedCauset
%SPRINKLEDCAUSET    Class for sprinkled causal sets.
%   When initializing an sprinkled causet object, a specified coordinate 
%   shape of a spacetime with a given metric is sprinkled and the causal
%   structure of the spacetime is restricted to the sprinkled set to obtain
%   a causal set.
% 
% Arguments:
% N                   Explicit integer value as the number of events to be 
%                     sprinkled, or double value as expected number 
%                     parameter for the Poisson distribution.
% d                   Dimension of the spacetime for the sprinkling
%                     process.
% 
% Optional arguments by key-value pairs:
% Shape               Coordinate shape to be sprinkled. See super class
%                     EmbeddedCauset.
% Metric              Metric of the underlying spacetime. See super class
%                     EmbeddedCauset.
% RandStream          Random number stream that should be used for the
%                     sprinkling process. By default, the global stream is
%                     used: RandStream.getGlobalStream
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    properties(SetAccess = protected)
        lambda % Poisson distribution parameter.
        RandStream % Random number stream for class construction.
    end
    
    methods
        function obj = SprinkledCauset( N, d, varargin )
            rndst = [];
            super_args = {};
            for i = 1:2:length( varargin )
                key = lower( varargin{ i } );
                value = varargin{ i + 1 };
                isvaluesupported = true;
                if strcmp( key, 'shape' )
                    super_args = [ super_args(:)', ...
                        {'Shape'}, {value} ];
                elseif strcmp( key, 'metric' )
                    super_args = [ super_args(:)', ...
                        {'Metric'}, {value} ];
                elseif strcmp( key, 'randstream' )
                    isvaluesupported = isa( value, 'RandStream' );
                    if isvaluesupported
                        rndst = value;
                    end
                else
                    warning( 'Key ''%s'' is unknown.', key );
                end
                if ~isvaluesupported
                    warning( 'Value type ''%s'' is not supported for key ''%s''.', ...
                        class( value ), key );
                end
            end
            obj@EmbeddedCauset( d, super_args{:} );
            if isempty( rndst )
                obj.RandStream = RandStream.getGlobalStream;
            else
                obj.RandStream = rndst;
            end
            sprinkle( obj, N );
            obj.relate();
        end
    end
    
    methods(Access = private)
        sprinkle( obj, N );
    end
end

