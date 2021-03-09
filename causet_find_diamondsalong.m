function events = causet_find_diamondsalong( C, geodesics )
%CAUSET_FIND_DIAMONDSALONG finds all events along a (set of) geodesic(s),
% which are diamond links along the path(s).
% 
% Arguments:
% C                   logical upper triangular causal matrix.
% GEODESICS           (cell vector with) geodesic(s) as a row vector(s).
% 
% Returns:
% EVENTS              list of events. 
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    all_sel = false( 1, size( C, 1 ) );
    if ~iscell( geodesics )
        temp = cell( 1, 1 );
        temp{ 1 } = geodesics;
        geodesics = temp;
    end
    for b = 1 : length( geodesics )
        all_sel( geodesics{ b }( 1 ) ) = true;
        for i = 1 : ( length( geodesics{ b } ) - 2 )
            all_sel = all_sel ...
                | ( C( geodesics{ b }( i ), : ) ...
                    & transpose( C( :, geodesics{ b }( i + 2 ) ) ) );
        end
        all_sel( geodesics{ b }( length( geodesics{ b } ) ) ) = true;
    end
    events = find( all_sel );
end
