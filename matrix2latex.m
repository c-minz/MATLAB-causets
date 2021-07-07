function latex = matrix2latex( A )
%MATRIX2LATEX converts a matrix into LaTeX code.
% 
% Arguments:
% A is the matrix to be converted.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    % fractionformat = "{}^{%d}/_{%d}";
    fractionformat = "\\frac{%d}{%d}";
    
    latex = "\begin{pmatrix}" + newline;
    n = size( A );
    for i = 1 : n( 1 )
        latex = latex + char( 9 );
        latex = latex + sprintf( '%0.3f', A( i, 1 ) );
        for j = 2 : n( 2 )
            latex = latex + sprintf( ' & %0.3f', A( i, j ) );
%             if A( i, j ) == 0
%                 latex = latex + "\cdot";
%             else
%                 [ nom, denom ] = rat( A( i, j ) );
%                 if denom == 1
%                     latex = latex + nom;
%                 else
%                     latex = latex + sprintf( fractionformat, nom, denom );
%                 end
%             end
%             if j < n( 2 )
%                 latex = latex + " & ";
%             end
        end
        if i < n( 1 )
            latex = latex + " \\" + newline;
        else
            latex = latex + newline;
        end
    end
    latex = latex + "\end{pmatrix}";
end

