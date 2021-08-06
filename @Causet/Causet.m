classdef Causet < handle
%CAUSET    Class for causal sets. 
%   CAUSET(C, ...) generates an object from the logical matrix C. 
%   As a second argument, the link matrix L can be provided if it is 
%   known - otherwise it will be computed at the first use.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    properties(SetAccess = protected)
        Card   % int32: cardinality of the causal set
    end
    properties(GetAccess = protected, SetAccess = private)
        C      % logical, stricly upper-triangular matrix: causal relations
        L      % logical, stricly upper-triangular matrix: link relations
        Sels   % selections of events
    end
    methods(Access = protected)
        copyCausals( obj, srcobj, subset );
        clearCausals( obj );
        addCausal( obj, a, b, trans );
        removeCausal( obj, a, b, trans );
    end
    
    %% main methods:
    methods
        %% constructor
        function obj = Causet( varargin )
            %CAUSET    Construct a causet from its causal matrix (first
            %   argument) - and its link matrix as optional second
            %   argument.
            obj.Card = 0;
            obj.removeAllSels();
            if nargin > 0
                if islogical( varargin{ 1 } )
                    % let:
                    obj.C = varargin{ 1 };
                    obj.Card = size( obj.C, 1 );
                    if nargin > 1 && islogical( varargin{ 2 } ) && ...
                        sum( size( varargin{ 2 } ) - size( varargin{ 1 } ) ) == 0
                        obj.L = varargin{ 2 };
                    end
                end
            end
        end
        
        %% causal relations:
        s = SetOf( obj, list );
        s = SelOf( obj, list );
        e = addEvent( obj, varargin );
        removeEvents( obj, varargin );
        m = Caumat( obj, list );
        [ pcount, fcount ] = CausalCount( obj, plist, flist );
        c = SubCauset( obj, list );
        bool = isCausal( obj, a, b );
        bool = isCausalEq( obj, a, b );
        bool = isChain( obj, list );
        s = PastOf( obj, list, varargin );
        s = FutureOf( obj, list, varargin );
        s = ConeOf( obj, list, varargin );
        s = Interval( obj, a, b, varargin );
        s = PastInf( obj, varargin );
        s = FuturInf( obj, varargin );
        s = PastInfOf( obj, list, varargin );
        s = FutureInfOf( obj, list, varargin );
        varargout = CardPositioning( obj, e, ac );
        [ P, varargout ] = DAlembertian( obj, PrefPast, method );
        
        %% link relations:
        link( obj ); % force to recalculate links
        
        function links = get.L( obj )
            if isempty( obj.L )
                obj.link(); % find links
            end
            links = obj.L;
        end
        
        function bool = isLink( obj, a, b )
            narginchk( 3, 3 );
            bool = obj.L( a, b );
        end
        
        m = Linkmat( obj, list );
        [ pcount, fcount ] = LinkCount( obj, plist, flist );
        bool = isPath( obj, list );
        P = Paths( obj, a, b, varargin );
        r = Rank( obj, b, a );
        s = Layers( obj, list, k, varargin );
        s = GeodesicLayers( obj, list, k, varargin );
        s = Ranks( obj, list, k, varargin );
        lnums = LayerNumbers( obj, list, kmax );
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
        
        %% selections:
        function n = countSels( obj, type )
            sel = obj.Sels;
            sel_len = size( sel, 1 );
            if nargin < 2
                n = sel_len;
            else
                sel_idx = false( 1, sel_len );
                for i = 1 : sel_len
                    if strcmp( sel{ i, 2 }, type )
                        sel_idx( i ) = true;
                    end
                end
                n = sum( sel_idx );
            end
        end
        
        function i = addSels( obj, list, i, type, param )
            if islogical( list )
                list = find( list );
            end
            if ( nargin < 3 )
                i = 0;
            end
            if ( nargin < 4 )
                type = 'UserDefined';
            end
            if ( nargin < 5 )
                param = [];
            end
            if i == 0
                i = size( obj.Sels, 1 ) + 1;
                obj.Sels{ i, 1 } = list;
                obj.Sels{ i, 2 } = type;
                obj.Sels{ i, 3 } = param;
            else
                obj.Sels{ i, 1 } = ...
                    unique( [ obj.Sels{ i, 1 }, list ] );
            end
        end
        
        i = addSelsLayers( obj, list, k, i, type, param );
        
        function sel = getSels( obj, i, type )
            if nargin < 3
                type = '';
            end
            sel = false( 1, obj.Card );
            sel( obj.sels_getset( i, type ) ) = true;
        end
        
        function set = sels_getset( obj, i, type )
            if ( nargin < 3 ) || isempty( type )
                if length( i ) == 1
                    set = obj.sels{ i, 1 };
                else
                    set = obj.sels( i, 1 );
                end
            else
                sel = obj.sels;
                sel_len = size( sel, 1 );
                i_type = 0;
                sel_idx = false( 1, sel_len );
                for j = 1 : sel_len
                    if strcmp( sel{ j, 2 }, type )
                        i_type = i_type + 1;
                    end
                    if ~isempty( find( i == i_type, 1 ) )
                        sel_idx( i_type ) = true;
                    end
                end
                if length( i ) == 1
                    set = sel{ sel_idx, 1 };
                else
                    set = sel( sel_idx, 1 );
                end
            end
        end
        
        function events = sels_getall( obj, type )
            sel = obj.sels;
            sel_len = size( sel, 1 );
            sel_idx = false( 1, sel_len );
            for i = 1 : sel_len
                if strcmp( sel{ i, 2 }, type )
                    sel_idx( i ) = true;
                end
            end
            events = sel( sel_idx, 1 );
        end
        
        function type = sels_gettype( obj, i )
            type = obj.sels{ i, 2 };
        end
        
        function param = sels_getparam( obj, i )
            param = obj.sels{ i, 3 };
        end
        
        function sels_remove( obj, i, type )
            sel = obj.sels;
            sel_len = size( sel, 1 );
            sel_keep = true( 1, sel_len );
            if ( nargin < 3 ) || isempty( type )
                sel_keep( i ) = false;
            else
                i_type = 0;
                for j = 1 : sel_len
                    if strcmp( sel{ j, 2 }, type )
                        i_type = i_type + 1;
                    end
                    if ~isempty( find( i == i_type, 1 ) )
                        sel_keep( i_type ) = false;
                    end
                end
            end
            obj.sels = sel( sel_keep, : );
        end
        
        function removeAllSels( obj, type )
            if nargin < 2
                obj.Sels = cell( 0, 3 );
            else
                sel = obj.Sels;
                sel_len = size( sel, 1 );
                sel_keep = true( 1, sel_len );
                for i = 1 : sel_len
                    if strcmp( sel{ i, 2 }, type )
                        sel_keep( i ) = false;
                    end
                end
                obj.Sels = sel( sel_keep, : );
            end
        end
    end
    
    methods(Static, Access = protected)
        opmode = localopmode( varargin );
    end
    
    methods(Static)
        set = setchoosepair( setA, setB );
        set = setchoosek( set, k );
        s = setand( varargin );
        s = setor( varargin );
        s = setxor( varargin );
    end
end

