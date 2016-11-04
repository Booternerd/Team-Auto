% ======================================================================
% MTRN4230 ROBOTICS 
% Team Auto (Group 5)
% ======================================================================
%
% Function: Assigns a Pz value according to the inputted coordinates and
%           knowledge of which image was selected for the click and go
%           function.
%
% Input:    x coordinate, y coordinate, selected Image number
%
% Output:   Pz 

function Pz = checkPz(x,y,whichI)

    % If the Image clicked is the first Image showing mainly table

    if (whichI == 1)

        % If the region of the pixel coordinates is in the table area
        if ((x>1) && (x<1600) && (y<1200) && (y>219))

            Pz = 157;

        else

        % If the region of the pixel coordinates is in the conveyer area
        if ((x>989) && (x<1600) && (y>1) && (y<211))
        
            Pz = 32.1;
            
        else
            Pz = [];
            fprintf('Pz out of area\n');
        end;
        
        end;
    end;
    
    % If the Image clicked is the second Image showing mainly conveyer
    
    if (whichI == 2)

        % If the region of the pixel coordinates is in the conveyer area
        
        if ((x>433) && (x<1249) && (y<701) && (y>6))

            Pz = 32.1;

        else

        % If the region of the pixel coordinates is in the table area
            
        if ((x>1) && (x<1189) && (y<1200) && (y>728))
        
            Pz = 157;
            
        else
            Pz = [];
            fprintf('Pz out of area\n');
        end;
    end;
    end;
    return;
end