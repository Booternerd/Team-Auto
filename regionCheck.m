% region check
% checks which area (there are five areas, quadrants and the centre) the 
% blocks are located in

% 5 situations
% Centre == 1
% right top == 2
% left top == 3
% right bottom == 4
% left bottom == 5


function region = regionCheck(X,Y)

% quadrants first


    if X < 800 & Y < 600
        region = 2;
    else if X > 800 & Y < 600
            region = 3;
        else if X < 800 & Y > 600
                region = 4;
            else if X > 800 & Y > 600 
                    region = 5;
                end;
            end;
        end;
    end;

% Now overwrite if the region is in the centre

    if X > 450 & X < 1150 & Y > 300 & Y < 900
        region = 1;
    end;
    
    return;
    
end