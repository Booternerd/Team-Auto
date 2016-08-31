MODULE Auto_Move_bot

    PROC Main_Move_bot() 
        ! use to test the functions made
        VAR pose p1;
        VAR robjoint p2;
        MoveToCalibPos;
        Move_Joints_Angle [20,20,20,20,20,20];
        MoveToCalibPos;
        p1 := get_Pose();
        p2 := get_Angles();
        Move_Joints [175,0,147],[0,0,-1,0];
        Move_Joints p1.trans,p1.rot;
        Move_Joints [175,0,147],[0,-0.7071068,0.7071068,0];
        Move_Joints_Angle p2;
    ENDPROC
    
    PROC Move_Joints_Angle(robjoint angles)
        ! Input~ 'angles':angles of each joints in degrees i.e. [10,10,10,10,10,10]
        ! Moves the robot based on the angles of each joints
        MoveAbsJ [angles, [9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v100, fine, tSCup;
    ENDPROC
    
    PROC Move_Joints(pos p, orient o)
        ! Input: 'p'~position of end effector in mm i.e [Xpos, Ypos, Zpos]
        !        'o'~orientation of end effector in quaternion i.e. [1, 0, 0, 0]
        ! Moves the end effector based on pose by moving the joint
        ! Matlab have to perform a check to mke sure it is not out of reach
        MoveJ [p,o,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v100, fine, tSCup;
    ENDPROC
    
    PROC Move_Linear(pos p, orient o)
        ! Input: 'p'~position of end effector in mm i.e [Xpos, Ypos, Zpos]
        !        'o'~orientation of end effector in quaternion i.e. [1, 0, 0, 0]
        ! Moves the end effector based on pose linearly
        ! Not recomended!:singularity, and out of reach
        MoveL [p,o,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], v100, fine, tSCup;
    ENDPROC
    
    FUNC pose get_Pose()
        ! Return: current pose of end effector 
        ! usage : VAR pose rPos := get_Pose();
        !       : rPos.trans~give pos in mm
        !       : rpos.rot~orientation in quaternion
        VAR robtarget rb;
        rb := CRobT(\Tool:=tsCup);
        RETURN [rb.trans, rb.rot]; 
    ENDFUNC
    
    FUNC robjoint get_Angles()
        ! Return: current angle of all joints in degrees 
        ! usage : VAR robjoint rAng := get_Angles();
        VAR jointtarget rb;
        rb := CJointT();
        RETURN rb.robax; 
    ENDFUNC

ENDMODULE