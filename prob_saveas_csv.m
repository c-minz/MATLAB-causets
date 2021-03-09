% Copyright 2021, C. Minz. BSD 3-Clause License.

function prob_saveas_csv( filename, hits, yaxisscale, xvalues )
    
    if nargin < 4
        yaxisscale = 1;
    end
    if yaxisscale >= 2
        % save to data file, y-axis in log scale:
        fileID = fopen( sprintf( '%s.%s', filename, 'log.csv' ), 'w' );
        for i = 1 : length( hits )
            logvalue = log( avhits( i ) );
            if ~isnan( logvalue ) && ~isinf( logvalue ) && ( logvalue > 0 )
                if nargin < 5
                    fprintf( fileID, '%d, %0.5f\n', i, log( logvalue ) );
                else
                    fprintf( fileID, '%d, %0.5f\n', xvalues( i ), log( logvalue ) );
                end
            end
        end
        fclose( fileID );
        yaxisscale = floor( ( yaxisscale - 1 ) / 2 );
    end
    
    if yaxisscale >= 1
        % save to data file, y-axis in linear scale:
        fileID = fopen( sprintf( '%s.%s', filename, 'csv' ), 'w' );
        for i = 1 : length( hits )
            if nargin < 5
                fprintf( fileID, '%d, %0.5f\n', i, avhits( i ) );
            else
                fprintf( fileID, '%d, %0.5f\n', xvalues( i ), avhits( i ) );
            end
        end
        fclose( fileID );
    end
end

