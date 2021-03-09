% Copyright 2021, C. Minz. BSD 3-Clause License.

function prob_saveas_tikz( filename, hits, runs, eps, constraints )
    % calculate probabilities:
    posetcount = length( hits ) - 1;
    prob = double( hits( 1 : posetcount ) ) / double( runs );
    
    if nargin < 5
        constraints = [];
    end
    
    % approximate by fractions:
    if eps <= 0
        % use RAT function:
        threshold = 0.105;
        nom_limit = 6 * posetcount;
        minprob = min( prob );
        [ nom, denom ] = rat( prob / minprob, threshold );
        nom_oor = find( nom > nom_limit );
        if ~isempty( nom_oor )
            nom2 = round( prob / minprob );
            nom( nom_oor ) = nom2( nom_oor );
            denom( nom_oor ) = 1;
        end
        [ sorted_nom, I ] = sort( nom, 'descend' );
        sorted_denom = denom( I );
        denomprod = 1;
        for i = 1 : posetcount
            f_last = 1;
            f_power = 1;
            for f = factor( sorted_denom( i ) )
                if f_last ~= f
                    f_power = f;
                else
                    f_power = f_power * f;
                end
                if mod( denomprod, f_power ) ~= 0
                    maxnom = max( denomprod * f * ( sorted_nom ./ sorted_denom ) );
                    if maxnom < nom_limit
                        denomprod = denomprod * f;
                    end
                end
                f_last = f;
            end
        end
        nom = round( denomprod * ( nom ./ denom ) );
    else
        % use denominator sequence:
        cdenom = posetcount;
        cdenom_max = posetcount * 1000000;
        factors = [ 1000, 100, 10, 5, 2, 1.5, 1.1, 1 ];
        fi = 1;
        h = waitbar( 0, sprintf( 'Denominator: %d', cdenom ) );
        j = 1;
        while 1
            cdenom = factors( fi ) * cdenom + 1; % increase denominator
            nom = round( cdenom * prob );
            j = j + 1;
            if mod( j, 10 )
                waitbar( 0, h, sprintf( 'Denominator: %d, Approx: %f', ...
                    cdenom, max( abs( prob - nom / cdenom ) ) ) );
            end
            if ( sum( abs( prob - nom / cdenom ) >= eps ) == 0 ) && ( sum( nom == 0 ) == 0 )
                if fi < length( factors )
                    cdenom_max = cdenom;
                    cdenom = round( cdenom / factors( fi ) );
                    fi = fi + 1;
                else
                    % test constraints:
                    if ~isempty( constraints )
                        nom = nom * transpose( constraints );
                    end
                    % get correct approximation and quit if still good enough:
                    if cdenom >= cdenom_max
                        break
                    elseif nom ~= round( nom )
                        continue
                    elseif abs( prob - nom / sum( nom ) ) < eps
                        break
                    end
                end
            end
        end
        close( h );
    end
    
    % apply constraints and cancel fractions:
    if ~isempty( constraints )
        nom = round( nom * transpose( constraints ) );
    end
    for c = factor( min( nom( 1 ), 27720 ) )
        if sum( mod( nom, c ) ) == 0
            nom = nom / c;
        end
    end
    cdenom = sum( nom );
    
    % save to tikz lines:
    fileID = fopen( filename, 'w' );
    for i = 1 : posetcount
        fprintf( fileID, '\\node[prob] at (poset%02d) {%0.4f};\n', ...
            i, prob( i ) );
    end
    for i = 1 : posetcount
        fprintf( fileID, '\\node[probratio] at (poset%02d) {%d};\n', ...
            i, nom( i ) );
    end
    for i = 1 : posetcount
        fprintf( fileID, '\\node[probapprox] at (poset%02d) {%0.4f};\n', ...
            i, nom( i ) / cdenom );
    end
    fprintf( fileID, replace( sprintf( '\\\\node[samplesize] at (posetsummary) {\\\\num{%0.1E}};\\n', ...
        runs ), '+0', '' ) );
    fprintf( fileID, '\\node[denom] at (posetsummary) {%d};\n', ...
        cdenom );
    fclose( fileID );
end

