% elliptical reachability check

function[reachable]=ReachabilityCheck(x,y)

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
 