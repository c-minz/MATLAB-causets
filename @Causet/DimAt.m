function [ dim, irred, closingfaces ] = DimAt( obj, a, slice, fencemax, dimmax )
%DIMAT    Identifies the flat (Minkowski) spacetime dimension at event a 
%   as part of some 2-layer Cauchy slice by searching for 1-rank (2-layer)
%   irreducibles. It tests up to dimension dimmax.
%   [Performance warning: This function can also be operated with more than
%                         two layers in the Cauchy slice. However, the
%                         performance can be drastically reduced since the
%                         search consideres all combinations of linked
%                         events.]
% 
% Arguments:
% obj                 Causet class object.
% a                   Event in the Cauchy slice from where the 1-rank
%                     irreducible have to start.
% slice               Logical selection vector or set of events that 
%                     defines the (2-layer) Cauchy slice.
% 
% Optional arguments:
% fencemax            Maximal fence number.
%                     Default: Twice the maximal dimension dimmax.
% dimmax              Maximal dimension.
%    Warning:         The current version does only support 1-rank 
%                     irreducibles up to dimension 1+3..
%                     Default: 4
% 
% Returns:
% dim                 Dimension (up to dimmax) at event a.
% irred               Set of events in the 1-rank dim-irreducible that
%                     determined the dimension result dim.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 3, 5 );
    
    %% set defaults:
    if ~islogical( slice )
        slice = obj.SelOf( slice );
    end
    if ( nargin < 5 ) || isempty( dimmax ) || ( dimmax < 1 )
        dimmax = 4;
    end
    if ( nargin < 4 ) || isempty( fencemax ) || ( fencemax < 0 )
        fencemax = 2 * dimmax;
    end
    %% check dimensions:
    found = false;
    closingfaces = {};
    [ fcsets, fencemax ] = ...
        obj.FenceConeSets( a, slice, fencemax, 1 : fencemax );
    %% check dimension 1+2 and larger:
    if ( dimmax >= 3 ) && ( fencemax >= 3 )
        if dimmax > 4
            warning( [ 'The current version does only support ', ...
                       '1-rank irreducibles up to dimension 1+3.' ] );
        end
        %% check dimension 1+3:
        %  Current support only for 1-rank 4-irreducibles up to a fence
        %  number of 4 (plus 1 for a closing face).
        if dimmax >= 4
            dim = 4;
            [ irreds, closed3fences ] = ...
                obj.find1Rk4Irred( a, fcsets( 3, : ), 1, 'set' );
            if ~isempty( irreds )
                irred = irreds{ 1 };
                closingfaces = findClosingFaces( obj, irred );
                found = true;
            end
        end
        %% check dimension 1+2:
        if ~found && ( dimmax >= 3 )
            dim = 3;
            for f = 3 : fencemax
                if ( f == 3 ) && ( dimmax >= 4 )
                    irreds = closed3fences;
                else
                    irreds = obj.find1Rk3Irred( a, fcsets( f, : ), ...
                        'all', 'fence', [ f, f ] );
                end
                if ~isempty( irreds )
                    % At least one closed k-fence is present.
                    idx = 1;
                    kmax = length( irreds );
                    for k = 1 : kmax
                        irred = irreds{ k };
                        irred = [ a, cat( 2, irred{:} ) ];
                        [ thiscfaces, cfcount ] = ...
                            findClosingFaces( obj, irred );
                        if ( cfcount( 1 ) > 0 ) && ( cfcount( 2 ) > 0 )
                            closingfaces = thiscfaces; % closed on both sides
                            idx = k;
                            break
                        elseif ( cfcount( 1 ) > 0 ) || ( cfcount( 2 ) > 0 )
                            closingfaces = thiscfaces; % closed on one side
                            idx = k;
                        end
                    end
                    irred = irreds{ idx };
                    irred = [ a, cat( 2, irred{:} ) ];
                    found = true;
                    break
                end
            end
        end
    end
    %% check dimension 1+1:
    if ~found && ( dimmax >= 2 ) && ( fencemax >= 1 )
        dim = 2;
        irreds = obj.find1Rk2Irred( a, fcsets( 1, : ), 'all' );
        if ~isempty( irreds )
            idx = 1;
            if fencemax >= 2
                kmax = length( irreds );
                for k = 1 : kmax
                    [ thiscfaces, cfcount ] = ...
                        findClosingFaces( obj, irreds{ k }, true );
                    if ( cfcount( 1 ) > 0 ) && ( cfcount( 2 ) > 0 )
                        closingfaces = thiscfaces; % closed on both sides
                        idx = k;
                        break
                    elseif ( cfcount( 1 ) > 0 ) || ( cfcount( 2 ) > 0 )
                        closingfaces = thiscfaces; % closed on one side
                        idx = k;
                    end
                end
            end
            irred = irreds{ idx };
            found = true;
        end
    end
    %% check dimension 1+0:
    if ~found && ( dimmax >= 1 ) && ( fencemax >= 1 )
        dim = 1;
        irreds = obj.find1Rk1Irred( a, fcsets( 1, : ), 1 );
        if ~isempty( irreds )
            irred = irreds{ 1 };
            found = true;
        end
    end
    %% no causal (link) relation present, dimension 0+0:
    if ~found
        dim = 0;
        irred = a;
    end
    return

    %% nested function to return the closing faces for an irreducible:
    function [ cfaces, cfacescount ] = findClosingFaces( obj, irred, onlymaxlayer )
        botset = obj.PastInfOf( irred );
        topset = obj.FutureInfOf( irred );
        if ( nargin < 3 ) || ~onlymaxlayer
            dobot = true;
            dotop = true;
        else
            dobot = length( botset ) > length( topset );
            dotop = ~dobot;
        end
        temp = slice;
        temp( irred ) = false;
        if ~dobot
            botconeinter = zeros( 1, 0 );
        else
            botconeinter = obj.ConeOf( botset, ...
                'links', true, 'lop', 'and', 'partof', temp );
        end
        if ~dotop
            topconeinter = zeros( 1, 0 );
        else
            topconeinter = obj.ConeOf( topset, ...
                'links', true, 'lop', 'and', 'partof', temp );
        end
        cfacescount = [ length( botconeinter ), length( topconeinter ) ];
        if sum( cfacescount ) == 0
            cfaces = {};
        else
            cfaces = { botconeinter, topconeinter };
        end
    end
end
