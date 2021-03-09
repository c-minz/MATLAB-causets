function tikzstring = causet_saveas_links2tikz( links, linkselector, style )
%CAUSET_SAVEAS_LINKS2TIKZ converts a link matrix into a string to be used in 
% LaTeX TikZ.
% 
% Arguments:
% LINKS is the links matrix to be converted into a TikZ string.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    tikzstring = "";
    n = size( links );
    links_ptdigits = length( num2str( n( 1 ) ) );
    links_format = "\\draw[causalrel%d] (p%0" + links_ptdigits + ...
        "d) -- (p%0" + links_ptdigits + "d);";
    for i = 1 : n( 1 )
        for j = 1 : n( 2 )
            if linkselector( i ) && linkselector( j ) && ...
                    ( links( i, j ) || links( j, i ) )
                tikzstring = tikzstring + char(9) + ...
                    sprintf( links_format, style, i, j ) + newline;
            end
        end
    end
end

