function saveas_csvtable( filename, table )
%SAVEAS_CSVTABLE saves the data table in FILENAME.csv
% 
% Arguments:
% FILENAME            filename without extension. The extension is added.
% TABLE               data table to be saved with 5 decimal precision.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    fileID = fopen( sprintf( '%s.%s', filename, 'csv' ), 'w' );
    cols = size( table, 2 );
    for i = 1 : size( table, 1 )
        for j = 1 : ( cols - 1 )
            fprintf( fileID, '%0.5f, ', table( i, j ) );
        end
        fprintf( fileID, '%0.5f\n', table( i, cols ) );
    end
    fclose( fileID );
end

