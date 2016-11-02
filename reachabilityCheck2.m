% ======================================================================
% MTRN4230 ROBOTICS 
% Team Auto (Group 5)
% ======================================================================
%
% Function: Reachability Check function for a given pixel coordinate value
%           passed from click go GUI for Conveyer image
%
% Input:    pixel x coordinate, pixel y coordinate
%
% Output:   reachability value (1 or 0)

function[reachable]=ReachabilityCheck2(x,y)
 
    xCenter = 490;
    yCenter = 519;
    xRadius = 657;
    yRadius = 518;

    result = (x-490)^2/657^2+(y-519)^2/518^2;

    if result <=1
        reachable =1;
    else
        reachable =0;
    end   
end
 
