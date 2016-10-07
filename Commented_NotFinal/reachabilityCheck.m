% ======================================================================
% MTRN4230 ROBOTICS 
% Team Auto (Group 5)
% ======================================================================
%
% Function: Reachability Check function for a given pixel coordinate value
%           passed from click go GUI for table image
%
% Input:    pixel x coordinate, pixel y coordinate
%
% Output:   reachability value (1 or 0)

function[reachable]=ReachabilityCheck(x,y)

% Ellipsed area of reachability

    xCenter = 800;
    yCenter = 297;
    xRadius = 797;
    yRadius = 570;

    result = (x-800)^2/789^2+(y-297)^2/570^2;

    if result <=1
        reachable =1;
    else
        reachable =0;
    end   
end
 
