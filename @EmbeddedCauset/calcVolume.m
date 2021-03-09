function volume = calcVolume( obj )
%CALCVOLUME    Computes the spacetime volume of the embedding 
%  (pre-compact) region of spacetime.
% 
% Arguments:
% obj                 Embedded causet class object.
% 
% Returns:
% volume              Volume of the embedding region (sprinkling shape).
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    shape = obj.Shape;
    d = obj.Dim;
    if strcmp( shape, 'ball' )
        ballrad = obj.ShapeParam;
        volume = ballrad^d * pi^( d / 2 ) / gamma( d / 2 + 1 );
    elseif strcmp( shape, 'bicone' )
        ballrad = obj.ShapeParam;
        volume = ballrad^( d - 1 ) ...
            * pi^( d / 2 - 0.5 ) / gamma( d / 2 + 0.5 );
        volume = 2 * obj.ShapeParam * volume / d;
    elseif strcmp( shape, 'cylinder' )
        trange = obj.ShapeParam{ 1 };
        ballrad = obj.ShapeParam{ 2 };
        volume = ballrad^( d - 1 ) ...
            * pi^( d / 2 - 0.5 ) / gamma( d / 2 + 0.5 );
        volume = ( trange( 2 ) - trange( 1 ) ) * volume;
    elseif strcmp( shape, 'cube' )
        volume = ( 2 * obj.ShapeParam )^d;
    elseif strcmp( shape, 'diamond' )
        volume = sqrt( d - 1 ) * ( 2 * obj.ShapeParam )^d / d;
    elseif strcmp( shape, 'cuboid' )
        ranges = obj.ShapeParam;
        volume = 1;
        for i = 1 : d
            volume = ( ranges( 2, i ) - ranges( 1, i ) ) * volume;
        end
    end
end

