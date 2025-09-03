function [ conesets, maxfn, removed ] = ...
    FenceConeSets( obj, a, slice, maxfn, minfn )
%FENCECONESETS    Returns the fence cone subsets of slice such that the
%   fence is originiating from event a. The return is a obj.card long cell 
%   array.
%
% Arguments:
% obj                 Causet class object.
% a                   Event in the Cauchy slice.
% slice               A logical selection vector or set of events as a 
%                     Cauchy slice.
% 
% Optional arguments:
% maxfn               Maximal fence number (link count away from event a). 
%                     Use 'all' to extract every fence.
%                     Default: no limit
% minfn               Vector of minimal accepted fence numbers. 
%                     Default: Scalar value 1 (no limit)
% 
% Returns:
% conesets            Cell array of cone subsets for each event (in the
%                     slice). The row index ranges over the values of the
%                     vector minfn (by default only one row). The column
%                     index ranges from 1 to obj.card.
% maxfn               Maximal fence number (link count away from a).
% removed             Cell array of event sets that have been removed 
%                     from the fence because their fence number was lower 
%                     than minfn. The row index ranges over the values of
%                     the vector minfn. There is only one column.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    if ( nargin < 4 ) || strcmp( maxfn, 'all' )
        maxfn = obj.Card;
    end
    removesmallfences = ( nargin == 5 ) || isempty( minfn );
    if ~removesmallfences
        minfn = 1;
    end
    minfn_count = length( minfn );
    %% create fence cone sets up to fence number maxfn:
    conesets = cell( minfn_count, obj.Card );
    removed = cell( minfn_count, 1 );
    unfenced = true( 1, obj.Card );
    fencesets = cell( minfn_count, 1 );
    for j = 1 : minfn_count
        fencesets{ j } = cell( 1, minfn( j ) );
    end
    fenceset = a;
    unfenced( a ) = false;
    isfuturepointing = obj.FutureOf( a, 'links', true, ...
        'partof', slice, 'return', 'card' ) > 0;
    k = 0;
    while ( k < maxfn ) && ~isempty( fenceset )
        k = k + 1;
        fencestepsel = false( 1, obj.card );
        for e = fenceset
            if isfuturepointing
                conesel = obj.FutureOf( e, 'links', true, ...
                    'partof', slice, 'return', 'sel' ) ...
                    & unfenced;
            else
                conesel = obj.PastOf( e, 'links', true, ...
                    'partof', slice, 'return', 'sel' ) ...
                    & unfenced;
            end
            coneset = obj.SetOf( conesel );
            if ~isempty( coneset )
                conesets{ 1, e } = coneset;
                fencestepsel = fencestepsel | conesel; % cumulate fence steps
            end
        end
        isfuturepointing = ~isfuturepointing; % alternate cone direction
        unfenced = unfenced & ~fencestepsel; % exclude fence step from now on
        fenceset = obj.SetOf( fencestepsel );
        for j = find( k <= minfn )
            fencesets{ j }{ k } = fenceset;
        end
    end
    maxfn = k - 1;
    for e = 1 : obj.Card
        if isempty( conesets{ 1, e } )
            conesets{ 1, e } = zeros( 1, 0 );
        end
    end
    if ~removesmallfences
        return
    end
    minfn = min( minfn, k + 1 );
    %% remove events that are only part of a fence with fence number less 
    %  than minfn:
    for j = 2 : minfn_count
        conesets( j, : ) = conesets( 1, : );
    end
    removedsel = false( minfn_count, obj.Card );
    for k = ( max( minfn ) - 1 ) : -1 : 1
        for j = find( k < minfn )
            for e = fencesets{ j }{ k }
                if ~isempty( conesets{ j, e } )
                    conesets{ j, e } = setdiff( conesets{ j, e }, ...
                        removed{ j } );
                end
                if isempty( conesets{ j, e } )
                    removedsel( j, e ) = true;
                    removed{ j } = find( removedsel( j, : ) );
                end
            end
        end
    end
    for j = 1 : minfn_count
        if minfn( j ) > 0
            if ~isempty( conesets{ j, a } )
                conesets{ j, a } = setdiff( conesets{ j, a }, ...
                    removed{ j } );
            end
            if isempty( conesets{ j, a } )
                removedsel( j, a ) = true;
                removed{ j } = find( removedsel( j, : ) );
            end
        end
    end
end
