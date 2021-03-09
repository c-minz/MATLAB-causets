function poss = AntichainPerms( obj, ac )
%ANTICHAINPERMS    Returns the possible permutations of the antichain ac 
%   such that it can be embed in (1 + 1 dimensional) Minkowski spacetime.
%   
% Arguments:
% obj                 Causet class object.
% ac                  Set of events that form a maximal antichain.
% 
% Returns:
% poss                Cell vector of permutation matrices for all 
%                     independent pieces of the antichain. The return is
%                     empty if there exists no permutation of the antichain
%                     that can be embedded in 1 + 1 dimensional Minkowski
%                     spacetime.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    narginchk( 2, 2 );
    
    %% get the distance matrix for the antichain:
    %   Symmetric matrix, [ ac_card, ac_card ]
    ac_card = length( ac );
    ac_dist = nan( ac_card, ac_card );
    for i = 1 : ac_card
        for j = ( i + 1 ) : ac_card
            dist_elem = obj.Dist( ac( i ), ac( j ), ac );
            ac_dist( i, j ) = dist_elem;
            ac_dist( j, i ) = dist_elem;
        end
    end
    %% process spacelike separated pieces of antichain:
    ac_unproc = true( 1, ac_card );
    poss_allpieces = cell( 1, ac_card ); % pre-allocate
    p = 0;
    ac_next = 1;
    while ~isempty( ac_next )
        p = p + 1; % piece index
        dist_firstmin = min( ac_dist( ac_next, : ) );
        sel_closest = ac_dist( ac_next, : ) == dist_firstmin;
        sel_closest( ac_next ) = true;
        % get all permutations for the first event and its closest neighbours:
        poss = Extension_Perms( find( sel_closest ), 0, ac_dist );
        poss = poss{ 1 }; % only one position is possible, no split
        % convert to cell array:
        poss = num2cell( poss, 2 );
        % extend the piece:
        poss = ExtendAntichain( poss, true( 1, length( poss ) ), ac_dist );
        if isempty( poss ) % antichain error
            p = 0;
            poss_allpieces = cell( 1, 0 );
            break
        end
        % convert sub-indices to events:
        poss_piece = cat( 1, poss{:} );
        poss_allpieces{ p } = ac( poss_piece );
        ac_unproc( poss_piece( 1, : ) ) = false;
        ac_next = find( ac_unproc, 1 );
    end
    poss = poss_allpieces( 1, 1 : p );
end

%% function to extend a 2D antichain:
function poss = ExtendAntichain( poss, extending, D )
    if sum( extending ) == 0
        return
    end
    deleting = false( 1, length( poss ) );
    poss_count = sum( ~extending );
    for i = find( extending )
        %% select arrangement possibility:
        pitem = poss{ i };
        pitem_len = length( pitem );
        sel_unproc = true( 1, size( D, 1 ) );
        sel_unproc( pitem ) = false;
        if sum( sel_unproc ) == 0 % entire antichain is processed
            extending( i ) = false; % possibility is complete
            poss_count = poss_count + 1;
            continue
        end
        %% find next closest elements to events of the antichain (piece):
        %  a fence cannot close (no local cylinder topology)
        sel_closest = sel_unproc;
        isatfarleft = true;
        isatfarright = false;
        placement_left = true;
        placement_right = true;
        for j = 1 : pitem_len
            p = pitem( j );
            dist_min = min( D( p, sel_closest ) );
            if isnan( dist_min )
                if isatfarleft
                    placement_left = false;
                else
                    isatfarright = true;
                end
            elseif isatfarright
                placement_right = false;
            else
                isatfarleft = false;
                sel_closest = sel_closest & ( D( p, : ) == dist_min );
                placement_left = placement_left ...
                              && ( dist_min >= j );
                placement_right = placement_right ...
                              && ( dist_min > ( pitem_len - j ) );
            end
            if ~placement_left && ~placement_right
                break
            end
        end
        if isatfarleft % piece of antichain is processed
            extending( i ) = false; % possibility is complete
            poss_count = poss_count + 1;
            continue
        end
        closest = find( sel_closest );
        closest_len = length( closest );
        if ( ~placement_left && ~placement_right ) || ( closest_len == 0 )
            deleting( i ) = true; % possibility cannot be completed
            continue
        end
        %% distribute closest elements to the placements (left/right):
        if placement_left && ~placement_right
            split_len = 0;
            split_pos = closest_len;
        elseif ~placement_left && placement_right
            split_len = 0;
            split_pos = 0;
        else
            split_len = pitem_len;
            split_pos = 0 : closest_len;
        end
        extperms = Extension_Perms( closest, split_len, D );
        newposs = cell( length( split_pos ), 1 );
        j = 1;
        for s = split_pos
            thisperms = extperms{ j };
            thisperms_count = size( thisperms, 1 );
            poss_extended = zeros( thisperms_count, ...
                pitem_len + closest_len );
            poss_extcount = 0;
            testrangesL = [ 1, s; s + 1, s + pitem_len ];
            testrangesR = [ s + 1, s + pitem_len; ...
                pitem_len + 1, pitem_len + closest_len - s ];
            for m = 1 : thisperms_count
                thisextended = [ thisperms( m, 1 : s ), pitem, ...
                    thisperms( m, ( s + 1 ) : closest_len ) ];
                if isValidPerm( thisextended, testrangesL, D ) && ...
                   isValidPerm( thisextended, testrangesR, D )
                    poss_extcount = poss_extcount + 1;
                    poss_extended( poss_extcount, : ) = thisextended;
                end
            end
            newposs{ j } = poss_extended( 1 : poss_extcount, : );
            j = j + 1;
        end
        poss{ i } = cat( 1, newposs{:} );
        poss_count = poss_count + size( poss{ i }, 1 );
    end
    % build list of possibilities:
    newposs = cell( poss_count, 1 );
    newextending = false( 1, poss_count );
    newposs_count = 0;
    for i = find( ~deleting )
        pitem = poss{ i };
        pitem_len = size( pitem, 1 );
        pitem_last = newposs_count + pitem_len;
        pitem_range = ( newposs_count + 1 ) : pitem_last;
        newposs_count = pitem_last;
        newposs( pitem_range, 1 ) = num2cell( pitem, 2 );
        newextending( pitem_range ) = extending( i );
    end
    poss = ExtendAntichain( newposs, newextending, D );
end

%% perms function that also verifies the distances between the elements 
%  and allows for a split between some pair of neighbours :
function extperms = Extension_Perms( closest, split_len, D )
    closest_perms = perms( closest );
    closest_count = length( closest );
    if split_len == 0
        srange = 0;
    else
        srange = 0 : closest_count;
    end
    ep_count = size( closest_perms, 1 );
    ep_testranges = [ 1 ; 1 ] * [ 1, size( closest_perms, 2 ) ];
    accepted = true( ep_count, length( srange ) );
    for p = 1 : ep_count
        for s = srange
            accepted( p, s + 1 ) = isValidPerm( closest_perms( p, : ), ...
                ep_testranges, D, s, split_len );
        end
    end
    extperms = cell( 1, length( srange ) );
    for s = srange
        extperms{ s + 1 } = closest_perms( accepted( :, s + 1 ), : );
    end
end

%% check if a permutation is valid:
%  perm can be split after index split_pos by split_len (added to the
%  distance between these indexes)
function isval = isValidPerm( perm, testranges, D, split_pos, split_len )
    if nargin < 4
        split_pos = 0;
    end
    if nargin < 5
        split_len = 0;
    end
    isval = true;
    for i = testranges( 1, 1 ) : testranges( 1, 2 )
        for j = max( i + 1, testranges( 2, 1 ) ) : testranges( 2, 2 )
            maxdist = D( perm( i ), perm( j ) );
            actualdist = j - i;
            if ( i <= split_pos ) && ( j > split_pos )
                % if these elements are split, add split_len:
                actualdist = actualdist + split_len;
            end
            if actualdist > maxdist
                isval = false;
                break
            end
        end
        if ~isval
            break
        end
    end
end
