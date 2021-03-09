% Copyright 2021, C. Minz. BSD 3-Clause License.

function prob_saveas_tikzdata( filename, hits, runs )
    % calculate probabilities:
    hitscount = sum( hits );
    prob = double( hits ) / double( hitscount );
    
    % save to data file:
    fileID = fopen( sprintf( '%s.%s', filename, 'table' ), 'w' );
    fprintf( fileID, '# Runs: %d, Hits: %d\n', runs, hitscount );
    fprintf( fileID, '#n prob\n' );
    for i = 1 : length( hits )
        fprintf( fileID, '%d %0.5f\n', i, prob( i ) );
    end
    fclose( fileID );
    
    % save to data file, log scale:
    fileID = fopen( sprintf( '%s.%s', filename, 'log.table' ), 'w' );
    fprintf( fileID, '# Runs: %d, Hits: %d\n', runs, hitscount );
    fprintf( fileID, '#n log( hits )\n' );
    for i = 1 : length( hits )
        logvalue = log( double( hits( i ) ) );
        if ~isnan( logvalue ) && ~isinf( logvalue ) && ( logvalue > 0 )
            fprintf( fileID, '%d %0.5f\n', i, log( double( hits( i ) ) ) );
        end
    end
    fclose( fileID );
end

