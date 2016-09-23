MODULE Status_IO
    
    PERS string Command;
    PERS num Param{17};
    PERS num NumParams;
    PERS bool UpdateFlag;
    PERS bool ControlFlag;
    PERS bool StatusFlag;
    
    PROC MainStatus()
        StatusFlag := FALSE;
        WHILE TRUE DO
            IF StatusFlag THEN
                NumParams := 4;
                Param{1} := GetVacRun();
                Param{2} := GetVacSuck();
                Param{3} := GetConRun();
                Param{4} := GetConDir();
                UpdateFlag := TRUE;
                StatusFlag := FALSE;
            ENDIF
        ENDWHILE
    ENDPROC
    
    FUNC pose GetPose()
        ! Return: current pose of end effector 
        ! usage : VAR pose rPos := get_Pose();
        !       : rPos.trans~give pos in mm
        !       : rpos.rot~orientation in quaternion
        VAR robtarget rb;
        rb := CRobT(\Tool:=tsCup);
        RETURN [rb.trans, rb.rot]; 
    ENDFUNC
    
    FUNC robjoint GetAngles()
        ! Return: current angle of all joints in degrees 
        ! usage : VAR robjoint rAng := get_Angles();
        VAR jointtarget rb;
        rb := CJointT();
        RETURN rb.robax; 
    ENDFUNC
    
    FUNC dionum GetVacRun()
        RETURN DO10_1; 
    ENDFUNC
    
    FUNC dionum GetVacSuck()
        RETURN DO10_2; 
    ENDFUNC
    
    FUNC dionum GetConRun()
        RETURN DO10_3; 
    ENDFUNC
    
    FUNC dionum GetConDir()
        RETURN DO10_4; 
    ENDFUNC
    
ENDMODULE