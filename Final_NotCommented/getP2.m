function [X,Y] = getP2(x,y,Pz)

load('c2g2.mat');

% x,y pixel coordinate of undistorted image

% if Pz is on the table region (i.e. Pz = 347)

if Pz == 157
    
    xt = xv + x*cos(CAng) + y*sin(CAng);
    yt = yv + y*cos(CAng) - x*sin(CAng);

    X = (xt - xoT)*xp2mmT;
    Y = (yt - yoT)*yp2mmT;
    
else

% if Pz is on the conveyer region (i.e. Pz = 122.1)
if Pz == 32.1
    
    xt = xv + x*cos(CAng) + y*sin(CAng);
    yt = yv + y*cos(CAng) - x*sin(CAng);
    
    xt2 = xv + xoC*cos(CAng) + y*sin(CAng);
    yt2 = yv + yoC*cos(CAng) - x*sin(CAng);

    X = (xt - xt2)*xp2mmC;
    Y = (yt - yt2)*yp2mmC;

%     X = (xt - xoC)*xp2mmC;
%     Y = (yt - yoC)*yp2mmC;
    
else
    X = [];
    Y = [];
    fprintf('Coordinates clicked are out of area\n');
end;
end;

return;

end