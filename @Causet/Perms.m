function [ all_perms, layer_indices ] = Perms( obj, ac, ignorehigherdim )
%PERMS    Returns the possible permutations of the antichain ac 
%   such that it can be embed in (1 + 1 dimensional) Minkowski spacetime.
%   
% Arguments:
% obj                 Causet class object.
% 
% Optional arguments:
% ac                  Set of events that form a maximal antichain.
%                     Default: obj.CentralAntichain()
% ignorehigherdim     Boolean parameter to determine what happens when a
%                     piece of an antichain cannot be embedded into 1 + 1 
%                     Minkowski spacetime. If it is false (Default), an
%                     empty set is returned for the permutations for this 
%                     antichain piece. If it is true, all permutations of
%                     the antichain piece are returned.
% 
% Returns:
% all_perms           Returns a cell vector with one element for each 
%                     spacelike separated piece of the causet that is
%                     sliced by the antichain "present". Each element is a
%                     cell vector with 3 elements. The first element is a
%                     cell vector of permutation matrices of the past 
%                     layers increasing index towards the past infinity; 
%                     the second element is a cell vector with a single 
%                     permutation matrix for the present layer; and the 
%                     third element is a cell vector for the layers with 
%                     increasing index towards the future infinity.
% layer_indices       Returns a cell vector with one element for each 
%                     spacelike separated piece of the causet that is
%                     sliced by the antichain "present". The elements are
%                     double vectors each with the length obj.card(). The
%                     vector holds the averaged layer numbers for all the
%                     events that are in this piece. If an event is not in
%                     the piece, the entry in the vector is NaN. Notice
%                     that the averaged layer index of an event in the 
%                     piece can either be an integer or half and integer.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 1, 3 );
    if nargin < 2
        ac = obj.CentralAntichain();
    end
    if nargin < 3
        ignorehigherdim = false;
    end
    
    piece_poss = obj.AntichainPerms( ac );
    piece_count = length( piece_poss );
    all_perms = cell( 1, piece_count );
    layer_indices = cell( 1, piece_count );
    for i = 1 : piece_count
        present = sort( piece_poss{ i }( 1, : ) );
        %% allocate memory for the simplicial complex of each layer:
        layer_ranges = NaN( obj.Card, 2 );
        layers_past_count = max( abs( obj.LayerNumbers( ...
            obj.PastOf( present, 'inclbnd' ), -Inf ) ) );
        layers_future_count = max( obj.layernumbers( ...
            obj.FutureOf( present, 'inclbnd' ), Inf ) );
        piece_perms = cell( 1, 3 );
        piece_perms{ 1 } = cell( 1, layers_past_count );
        piece_perms{ 3 } = cell( 1, layers_future_count );
        scomplex = obj.AntichainPerms( present );
        if isempty( scomplex )
            if ignorehigherdim
                piece_perms{ 2 } = { perms( present ) };
            else
                piece_perms{ 2 } = { [] };
            end
        else % there is only one piece by construction:
            piece_perms{ 2 } = scomplex;
        end
        %% compute antichain permutations (layer configurations):
        layer_ranges( present, : ) = 0;
        k_range = [ 0, -1 : -1 : -layers_past_count, ...
            0, 1 : 1 : layers_future_count ];
        for k = k_range
            if k == 0
                stacked = present;
                prev_ac = present;
                continue
            end
            k_abs = abs( k );
            k_sign = sign( k ) + 2;
            stacked = unique( [ stacked, obj.Layers( stacked, k ) ] );
            if k < 0
                ac = sort( obj.PastInfOf( stacked ) );
            else
                ac = sort( obj.FutureInfOf( stacked ) );
            end
            layer_ranges( ac, 1 ) = min( k, layer_ranges( ac, 1 ) );
            layer_ranges( ac, 2 ) = max( k, layer_ranges( ac, 2 ) );
            if isequal( prev_ac, ac )
                if k_abs == 1
                    piece_perms{ k_sign }{ k_abs } = ...
                        piece_perms{ 2 }; % present
                elseif k_abs > 0
                    piece_perms{ k_sign }{ k_abs } = ...
                        piece_perms{ k_sign }{ k_abs - 1 };
                end
            else
                scomplex = obj.AntichainPerms( ac );
                if isempty( scomplex )
                    if ignorehigherdim
                        piece_perms{ k_sign }{ k_abs } = perms( ac );
                    else
                        piece_perms{ k_sign }{ k_abs } = [];
                    end
                else % there is only one piece by construction:
                    piece_perms{ k_sign }{ k_abs } = scomplex{ 1 };
                end
            end
            prev_ac = ac;
        end
        all_perms{ i } = piece_perms;
        layer_indices{ i } = ...
            ( layer_ranges( :, 1 ) + layer_ranges( :, 2 ) ) / 2;
    end
end
