function [X,Y] = getP(x,y)

load('c2g.mat');

% x,y pixel coordinate of undistorted image (TABLE)

xt = xv + x*cos(CAng) + y*sin(CAng);
yt = yv + y*cos(CAng) - x*sin(CAng);

X = (xt - xo)*xp2mm;
Y = (yt - yo)*yp2mm;

return;

end