% Area surface of jenga detected and categorised as 1,2 or 3

function ID = areaOfFace(measurements)

    Area = measurements.Area;

    if Area > 4000
        ID = 1;
        return;
    else
        if Area > 1500 & Area <3999
            ID = 2;
            return;
        else
            if Area < 1499
                ID = 3;
                return;
            end;
        end;
    end;
    
    return;

end