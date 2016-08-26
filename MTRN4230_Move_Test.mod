MODULE MTRN4230_Move_Sample
    
    VAR pos rPos:= [175,0,147];
    ! The Main procedure. When you select 'PP to Main' on the FlexPendant, it will go to this procedure.
    PROC MainMove()
        
        ! This is a procedure defined in a System Module, so you will have access to it.
        ! This will move the robot to its calibration.
	! Test bit thingy
        MoveToCalibPos;
        
        ! Call a procedure that we have defined below.
        MoveJSample;
        
        ! Call another procedure that we have defined.
        MoveLSample;
        
        ! Call another procedure, but provide some input arguments.
        VariableSample pTableHome, 100, 100, 0, v100, fine;
        
        MoveToCalibPos;
        
    ENDPROC
    
    PROC MoveJSample()
    
        ! 'MoveJ' executes a joint motion towards a robtarget. This is used to move the robot quickly from one point to another when that 
        !   movement does not need to be in a straight line.
        ! 'pTableHome' is a robtarget defined in system module. The exact location of this on the table has been provided to you.
        ! 'v100' is a speeddata variable, and defines how fast the robot should move. The numbers is the speed in mm/sec, in this case 100mm/sec.
        ! 'fine' is a zonedata variable, and defines how close the robot should move to a point before executing its next command. 
        !   'fine' means very close, other values such as 'z10' or 'z50', will move within 10mm and 50mm respectively before executing the next command.
        ! 'tSCup' is a tooldata variable. This has been defined in a system module, and represents the tip of the suction cup, telling the robot that we
        !   want to move this point to the specified robtarget. Please be careful about what tool you use, as using the incorrect tool will result in
        !   the robot not moving where you would expect it to. Generally you should be using
        
        ! MoveJ: move joints based end effector position in mm and orientation in quaternion 
        ! ie [[175,0,147],[0,0,-1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        !    |  pos     | |orient  |
        MoveJ pConvHome, v100, fine, tSCup;
        
        ! MoveAbsJ : move joints based on joints angle in degrees
        MoveAbsJ [[20,20,20,20,20,20],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]],v400,fine,tSCup; 
        
        
        
ENDPROC
    
    PROC MoveLSample()
        
        ! 'MoveL' will move in a straight line between 2 points. This should be used as you approach to pick up a chocolate
        ! 'Offs' is a function that is used to offset an existing robtarget by a specified x, y, and z. Here it will be offset 100mm in the positive z direction.
        !   Note that function are called using brackets, whilst procedures and called without brackets.
        MoveJ Offs(pTableHome, 0, 0, 100), v100, fine, tSCup;
        
    ENDPROC
    
    PROC VariableSample(robtarget target, num x_offset, num y_offset, num z_offset, speeddata speed, zonedata zone)
        
        ! Call 'MoveL' with the input arguments provided. Moves in a linear way
        MoveL Offs(target, x_offset, y_offset, z_offset), speed, zone, tSCup;
        
    ENDPROC
    
ENDMODULE