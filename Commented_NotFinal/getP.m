% ======================================================================
% MTRN4230 ROBOTICS 
% Team Auto (Group 5)
% ======================================================================
%
% Function: Gets position of real world coordinates from the pixel
%           coordinates.
%
% Input:    pixel x coordinate, pixel y coordinate
%           CAng        = value for rotation
%           xo,yo       = Robot pixel center
%           xv,yv       = offsets
%           xp2mm,yp2mm = Pixel to Real distance ratio
%
% Output:   Coordinates for real world X and Y

function [X,Y] = getP(x,y)

load('c2g.mat');

% x,y pixel coordinate of undistorted image (TABLE)

xt = xv + x*cos(CAng) + y*sin(CAng);
yt = yv + y*cos(CAng) - x*sin(CAng);

X = (xt - xo)*xp2mm;
Y = (yt - yo)*yp2mm;

return;

end