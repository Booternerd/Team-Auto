function[reachable]=ReachabilityCheck2(x,y)
 
    xCenter = 490;
    yCenter = 519;
    xRadius = 657;
    yRadius = 518;

%     result = (((x-xCenter)^2/xRadius^2) + ((y-yCenter)^2/yRadius^2))
result = (x-490)^2/657^2+(y-519)^2/518^2;

    if result <=1
        reachable =1;
    else
        reachable =0;
    end   
end
 
