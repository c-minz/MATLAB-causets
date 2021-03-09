function [ linkstarts, linkends, tikz ] = causet_createregular( size, topo )
%CAUSET_CREATEREGULAR Creates a regular causet for a given number of
% elements and topology.
% 
% Arguments:
% SIZE is spacetime vector containing the number of rows in directions of
%   each dimension starting with time. For certain topologies (option
%   "trousers" or "down-trousers") two numbers for each direction are 
%   expected.
%   
% Optional arguments:
% TOPO specifies the topology. The options are 
%   "flat" (default) for a flat regular lattice, boundaries are unlinked
%   "cylinder"       for a cylinder topology, periodic spacelike boundaries
%   "torus"          for a torus topology, periodic spacelike and periodic 
%                    timelike boundaries
%   "trousers"       for a double cylinder in the past, joining to a single
%                    cylinder in the future
%   "down-trousers"  for a single cylinder in the past, splitted into a
%                    double cylinder in the future
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    if nargin < 2
        topo = "flat";
    end
    % get number of layer per dimension:
    if topo == "trousers" || topo == "down-trousers"
        tlayers = size( 1 : 2 );
        xlayers = size( 3 : 4 );
    else 
        tlayers = size( 1 );
        xlayers = size( 2 );
    end
    % separate in even/odd layers:
    oxlayers = ceil( xlayers / 2 );
    exlayers = floor( xlayers / 2 );
    % calculate TikZ point format:
    causet_pti = 0;
    causet_ptdigits = ceil( tlayers / 2 ) .* ( oxlayers + exlayers );
    if topo == "trousers"
        causet_ptdigits = causet_ptdigits .* [ 2 1 ];
    elseif topo == "down-trousers"
        causet_ptdigits = causet_ptdigits .* [ 1 2 ];
    end
    causet_ptdigits = length( num2str( sum( causet_ptdigits ) ) );
    causet_ptformat = char( 9 ) + "\\node (p%0" + causet_ptdigits + "d) at ( %d*\\causetL, %d*\\causetL ) [event] {};";
    % pre-allocation of links:
    if topo == "torus"
        linkcount = ( oxlayers + exlayers ) * tlayers;
    elseif topo == "cylinder"
        linkcount = ( oxlayers + exlayers ) * ( tlayers - 1 );
    else
        linkcount = ( oxlayers + exlayers - 1 ) * ( tlayers - 1 );
    end
    linkstarts = ones( 1, linkcount );
    linkends = ones( 1, linkcount );
    linki = 0;
    % calculate linkstarts, linkends, draw TikZ graphic:
    tikz = "";
    if topo == "trousers" || topo == "down-trousers"
        disp( "Operation not implemented." );
    else
        for ti = 0 : ( tlayers - 1 )
            isodd = mod( ti + 1, 2 );
            ximax = isodd * oxlayers + ( 1 - isodd ) * exlayers - 1;
            for xi = 0 : ximax
                causet_pti = causet_pti + 1;
                tikz = tikz + sprintf( causet_ptformat, causet_pti, 2 * xi + 1 - isodd, ti ) + newline;
                if ti >= 1 % no links to the past of past-infinity
                    if isodd % odd layers
                        if xi > 0
                            linki = linki + 1;
                            linkstarts( linki ) = causet_pti - exlayers - 1;
                            linkends( linki ) = causet_pti;
                        end
                        if xi < ximax || oxlayers == exlayers
                            linki = linki + 1;
                            linkstarts( linki ) = causet_pti - exlayers;
                            linkends( linki ) = causet_pti;
                        end
                        if topo == "cylinder" || topo == "torus"
                            if xi == 0
                                linki = linki + 1;
                                linkstarts( linki ) = causet_pti - 1;
                                linkends( linki ) = causet_pti;
                            elseif xi == ximax && exlayers < oxlayers
                                linki = linki + 1;
                                linkstarts( linki ) = causet_pti - oxlayers - exlayers + 1;
                                linkends( linki ) = causet_pti;
                            end
                        end
                    else % even layers
                        linki = linki + 1;
                        linkstarts( linki ) = causet_pti - oxlayers;
                        linkends( linki ) = causet_pti;
                        if xi < ximax || exlayers < oxlayers
                            linki = linki + 1;
                            linkstarts( linki ) = causet_pti - oxlayers + 1;
                            linkends( linki ) = causet_pti;
                        end
                        if topo == "cylinder" || topo == "torus"
                            if xi == ximax && exlayers == oxlayers
                                linki = linki + 1;
                                linkstarts( linki ) = causet_pti - oxlayers - exlayers + 1;
                                linkends( linki ) = causet_pti;
                            end
                        end
                    end
                end
                if topo == "torus" && ti == ( tlayers - 1 )
                    linki = linki + 1;
                    linkstarts( linki ) = causet_pti;
                    linkends( linki ) = xi + 1;
                    if isodd == 0 % even layers
                        if xi < ximax || exlayers < oxlayers
                            linki = linki + 1;
                            linkstarts( linki ) = causet_pti;
                            linkends( linki ) = xi + 2;
                        end
                        if xi == ximax && exlayers == oxlayers
                            linki = linki + 1;
                            linkstarts( linki ) = causet_pti;
                            linkends( linki ) = 1;
                        end
                    end
                end
            end
        end
    end
end

