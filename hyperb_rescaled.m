function [ rescaled_r, speed, rescaled_coords ] = ...
    hyperb_rescaled( unithyperbcoords, spacedim )
%HYPERB_RESCALED rescales the unit hyperboloid coordinates and returns the 
% rescaled radial coordinate. 
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.
    
    if nargin < 2
        spacedim = length( unithyperbcoords );
    end
    r2 = sum( unithyperbcoords.^2, 2 );
    s = sqrt( 1 + r2 );
    speed = sqrt( r2 ) ./ s;
    r = sqrt( r2 );
    if spacedim == 1
        rescaled_r = 2 * asinh( r );
    elseif spacedim == 2
        rescaled_r = 2 * pi() * ( sqrt( r2 + 1 ) - 1 );
    else
        rescaled_r = 4 * pi() * ...
            ( sinh( 2 * asinh( r ) ) / 4 - asinh( r ) / 2 );
    end
    rescaled_coords = unithyperbcoords;
%     for i = 1 : size( rescaled_coords, 1 )
%         rescaled_coords( i, : ) = rescaled_coords( i, : ) ...
%             * rescaled_r( i ) / r( i );
%     end
end
