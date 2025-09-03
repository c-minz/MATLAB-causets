classdef CausetEmbedder < handle
%CAUSETEMBEDDER    Class to reconstruct spacetime properties and embed a 
%   causal set object. 
%   CAUSETEMBEDDER(C) generates an object from a Causet object.
% 
% Arguments:
% causet              Causet class object.
% 
% Copyright 2021-2025, C. Minz. BSD 3-Clause License.
    
    properties(GetAccess = protected, SetAccess = private)
        causet   % Causet: object to be embedded
    end
    
    %% main methods:
    methods
        %% constructor
        function obj = CausetEmbedder( causet )
            if nargin <= 0
                error( 'A Causet object is required.' );
            end
            if ~isa( causet, 'Causet' )
                error( 'The argument has to be of type Causet.' );
            end
            obj.causet = causet;
        end
        
        [ handles, plotobj ] = draw( obj, varargin );
        
        %% spacelike and antichain:
        bool = isSpacelikeTo( obj, alist, blist );
        s = SpacelikeTo( obj, list, varargin );
        bool = isAntichain( obj, list );
        s = CentralAntichain( obj, varargin );
        n = Dist( obj, a, b, ac );
        poss = AntichainPerms( obj, ac );
        [ all_perms, layer_indices ] = Perms( obj, present, ignorehigherdim );
        
        %% spacetime dimension:
        [ conesets, maxfn, removed ] = ...
            FenceConeSets( obj, a, slice, maxfn, minfn );
        irreds = findRk1Irred1( obj, a, fcs, n, varargin );
        irreds = findRk1Irred2( obj, a, fcs, n, varargin );
        [ irreds, maxfencenum ] = findRk1Irred3( obj, a, fcs, n, varargin );
        [ irreds, closed3fences ] = findRk1Irred4( obj, a, fcs, n, varargin );
        bool = isRk1Irred( obj, k, lists );
        bool = isRk1Irred1( obj, lists );
        bool = isRk1Irred2( obj, lists );
        bool = isRk1Irred3( obj, lists, maxfencenum );
        bool = isRk1Irred4( obj, lists );
        [ dim, irred, closingfaces ] = DimAt( obj, a, slice, fencemax, dimmax );
        
        function d = estimate_dim( obj, estimation, pastevent, futureevent )
            if nargin < 2
                estimation = '';
            end
            if nargin < 3
                pastevent = 1;
            end
            if nargin < 4
                futureevent = obj.card;
            end
            if ~obj.C( pastevent, futureevent )
                d = 0;
                return
            end
            switch estimation
                case { 'flat', 'Myrheim-Meyer', 2 }
                    chains = causet_get_chains( obj.C( pastevent : futureevent, pastevent : futureevent ), 2 );
                    d = causet_get_MMdim( chains );
                case { 'curved', 'Myrheim-Meyer extended', 4 }
                    chains = causet_get_chains( obj.C( pastevent : futureevent, pastevent : futureevent ), 4 );
                    d = causet_get_MMdim( chains );
                case { 'sprinkle', 'sprinkling' }
                    d = 0;
                    if ~isempty( obj.sprinkling )
                        d = obj.sprinkling.dim;
                    end
                otherwise % { 'log', 'midpoint' }
                    [ midpoints, mincard ] = causet_get_midpoint( obj.C ); %#ok<ASGLU>
                    d = log2( obj.card * length( mincard ) / sum( mincard ) );
            end
        end
        
        %% save as TikZ graphic:
        function saveastikz( obj, filename, ...
                linkstyles, unit, dimensions, fadingdepth )
            if nargin < 3
                linkstyles = { true( 1, obj.card ) };
            end
            if nargin < 4
                unit = 1;
            end
            if nargin < 5
                dimensions = [ 2, 1 ];
            end
            if nargin < 5
                fadingdepth = 1;
            end
            drawingstyles = sum( obj.sprinkling.subvolume_select, 2 );
            causet_saveas_tikz( obj.sprinkling.coordinates, obj.L, ...
                filename, unit, drawingstyles, linkstyles, ...
                dimensions, fadingdepth );
        end
    end
end

