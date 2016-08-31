MODULE Auto_Move_bot
    
    PROC Move_Joints_Angle(robjoint angles, speeddata speed)
        ! Input~ 'angles':angles of each joints in degrees i.e. [10,10,10,10,10,10]
        ! Moves the robot based on the angles of each joints
        MoveAbsJ [angles, [9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], speed, fine, tSCup;
    ENDPROC
    
    PROC Move_Joints(pos p, orient o, speeddata speed)
        ! Input: 'p'~position of end effector in mm i.e [Xpos, Ypos, Zpos]
        !        'o'~orientation of end effector in quaternion i.e. [1, 0, 0, 0]
        ! Moves the end effector based on pose by moving the joint
        ! Matlab have to perform a check to mke sure it is not out of reach
        MoveJ [p,o,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], speed, fine, tSCup;
    ENDPROC
    
    PROC Move_Linear(pos p, orient o, speeddata speed)
        ! Input: 'p'~position of end effector in mm i.e [Xpos, Ypos, Zpos]
        !        'o'~orientation of end effector in quaternion i.e. [1, 0, 0, 0]
        ! Moves the end effector based on pose linearly
        ! Not recomended!:singularity, and out of reach
        MoveL [p,o,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], speed, fine, tSCup;
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