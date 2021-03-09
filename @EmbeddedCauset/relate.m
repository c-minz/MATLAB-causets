function relate( obj )
%RELATE    Uses the coodinates from the embedding to set the causal 
%   structure.
% 
% Arguments:
% obj                 Embeddedcauset class object.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    N = obj.Card;
    obj.clearCausals();
    coord = obj.Coords;
    if strcmp( obj.Metric, 'Minkowski' )
        d = obj.Dim;
        for b = 2 : N
            for a = 1 : ( b - 1 )
                dcoord = coord( b, : ) - coord( a, : );
                causalmeasure = dcoord( 1, 1 )^2 - ...
                    sum( dcoord( 1, 2:d ).^2 );
                if causalmeasure >= 0
                    obj.addCausal( a, b );
                end
            end
        end
    elseif strcmp( obj.Metric, 'Schwarzschild' ) ...
        || strcmp( obj.Metric, 'EddingtonFinkelstein' )
        isSchwarzschild = strcmp( obj.Metric, 'Schwarzschild' );
        rS = obj.MetricParam{ 1 };
        for a = 1 : N
            ta = coord( a, 1 );
            ra = abs( coord( a, 2 ) );
            a_isoutside = ra > rS;
            a_sign = sign( coord( a, 2 ) );
            if isSchwarzschild
                a_r_temp = ra + rS * log( abs( ra / rS - 1 ) );
                a_out = a_r_temp - ta;
                a_in = a_r_temp + ta;
            else%if isEddingtonFinkelstein
                a_out = ra - ta + 2 * rS * log( abs( ra / rS - 1 ) );
                a_in = ra + ta;
            end
            for b = ( a + 1 ) : N
                rb = abs( coord( b, 2 ) );
                b_sign = sign( coord( b, 2 ) );
                if a_sign == b_sign
                    if isSchwarzschild
                        tb_out = rb - a_out + ...
                            rS * log( abs( rb / rS - 1 ) );
                        tb_in = - rb + a_in - ...
                            rS * log( abs( rb / rS - 1 ) );
                    else%if isEddingtonFinkelstein
                        tb_out = rb - a_out + 2 * ...
                            rS * log( abs( rb / rS - 1 ) );
                        tb_in = a_in - rb;
                    end
                    tb = coord( b, 1 );
                    if ( ( rb <= ra ) ... % closer to the singul.
                      && ( tb >= tb_in ) ... % above lower cone bound
                      && ( a_isoutside ... 
                        || ( tb <= tb_out ) ) ) ... % below upper cone bound
                    || ( a_isoutside ...
                      && ( rb > ra ) ... % even further outside
                      && ( tb >= tb_out ) ) % above outer cone bound
                        obj.addCausal( a, b );
                    end
                end
            end
        end
    end
end
