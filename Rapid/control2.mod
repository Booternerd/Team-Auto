MODULE control2
    
    PERS string Command;
    PERS num Param{17};
    PERS num NumParams;
    PERS bool UpdateFlag;
    PERS bool ControlFlag;
    PERS bool StatusFlag;
    
    VAR speeddata SpeedSetting;
    
    PROC MainControl()
        ControlFlag := FALSE;
        WHILE TRUE DO
            IF ControlFlag THEN
                TEST Command
                CASE "MoveJointsAngle":
                    UpdateSpeedSetting(Param{7});
                    MoveJointsAngle [Param{1},Param{2},Param{3},Param{4},Param{5},Param{6}],SpeedSetting;
                CASE "MoveJoints":
                    UpdateSpeedSetting(Param{8});
                    MoveJoints [Param{1},Param{2},Param{3}],[Param{4},Param{5},Param{6},Param{7}],SpeedSetting;
                CASE "MoveLinear":
                    UpdateSpeedSetting(Param{8});
                    MoveLinear [Param{1},Param{2},Param{3}],[Param{4},Param{5},Param{6},Param{7}],SpeedSetting;
                CASE "SetVacRun":
                    SetVacRun(Param{1});
                CASE "SetVacSuck":
                    SetVacSuck(Param{1});
                CASE "SetConRun":
                    SetConRun(Param{1});
                CASE "SetConDir":
                    SetConDir(Param{1});
                DEFAULT:

                ENDTEST 
            ENDIF
            ControlFlag := FALSE;    
        ENDWHILE
    ENDPROC
    
    PROC UpdateSpeedSetting(num Value)
        IF Value = 1 THEN
            SpeedSetting := v50;
        ELSEIF Value = 2 THEN
            SpeedSetting := v100;
        ELSEIF Value = 3 THEN
            SpeedSetting := v150;
        ELSEIF Value = 4 THEN
            SpeedSetting := v200;
        ELSEIF Value = 5 THEN
            SpeedSetting := vmax;
        ENDIF
    ENDPROC
    
    PROC MoveJointsAngle(robjoint angles, speeddata speed)
        ! Input~ 'angles':angles of each joints in degrees i.e. [10,10,10,10,10,10]
        ! Moves the robot based on the angles of each joints
        MoveAbsJ [angles, [9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], speed, fine, tSCup;
    ENDPROC
    
    PROC MoveJoints(pos p, orient o, speeddata speed)
        ! Input: 'p'~position of end effector in mm i.e [Xpos, Ypos, Zpos]
        !        'o'~orientation of end effector in quaternion i.e. [1, 0, 0, 0]
        ! Moves the end effector based on pose by moving the joint
        ! Matlab have to perform a check to mke sure it is not out of reach
        MoveJ [p,o,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], speed, fine, tSCup;
    ENDPROC
    
    PROC MoveLinear(pos p, orient o, speeddata speed)
        ! Input: 'p'~position of end effector in mm i.e [Xpos, Ypos, Zpos]
        !        'o'~orientation of end effector in quaternion i.e. [1, 0, 0, 0]
        ! Moves the end effector based on pose linearly
        ! Not recomended!:singularity, and out of reach
        MoveL [p,o,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], speed, fine, tSCup;
    ENDPROC
    
    PROC SetVacRun(num Value)
        ! Switch VacRun
        IF Value = 2 THEN
            IF DO10_1 = 1 THEN          ! If VacRun On
                Value := 0;              ! Turn VacRun Off
            ELSEIF DO10_1 = 0 THEN      ! If VacRun Off
                Value := 1;              ! Turn VacRun On
            ENDIF
        ENDIF
        ! Turn VacRun On
        IF Value = 1 THEN
            SetDO DO10_1, 1;            ! VacRun = 1
        ! Turn VacRun Off
        ELSEIF Value = 0 THEN
            SetDO DO10_1, 0;            ! VacRun = 0
            SetDO DO10_2, 0;            ! VacSuck = 0
        ENDIF
    ENDPROC
    
    PROC SetVacSuck(num Value)
        ! Switch VacSuck
        IF Value = 2 THEN
            IF DO10_1 = 1 THEN          ! If VacRun On      
                IF DO10_2 = 1 THEN          ! If VacSuck On
                    Value := 0;                 ! Turn VacSuck Off
                ELSEIF DO10_2 = 0 THEN      ! If VacSuck Off 
                    Value := 1;                 ! Turn VacSuck On
                ENDIF            
            ELSEIF DO10_1 = 0 THEN      ! If VacRun Off
                Value := 0;                 ! Turn VacSuck Off
            ENDIF
        ENDIF
        ! Turn VacSuck On
        IF Value = 1 THEN
            IF DO10_1 = 1 THEN          ! If VacRun On
                SetDO DO10_2, 1;            ! VacSuck = 1           
            ELSEIF DO10_1 = 0 THEN      ! If VacRun Off (?REDUNDANT?)           
                SetDO DO10_2, 0;            ! VacSuck = 0
            ENDIF
        ! Turn VacSuck Off
        ELSEIF Value = 0 THEN
            SetDO DO10_2, 0;            ! VacSuck = 0 
        ENDIF   
    ENDPROC
    
    PROC SetConRun(num Value)
        ! Switch ConRun
        IF Value = 2 THEN
            IF DI10_1 = 1 THEN
                IF DO10_3 = 1 THEN
                    Value := 0;         
                ELSEIF DO10_3 = 0 THEN
                    Value := 1;
                ENDIF 
            ELSE
                SetDO DO10_3, 0;
            ENDIF
        ENDIF
        ! Turn ConRun On
        IF Value = 1 THEN
            IF DI10_1 = 1 THEN
                SetDO DO10_3, 1;
            ELSE
                SetDO DO10_3, 0;
            ENDIF
        ! Turn ConRun Off
        ELSEIF Value = 0 THEN
            SetDO DO10_3, 0;
        ENDIF
    ENDPROC
    
    PROC SetConDir(num Value)
        ! Switch ConDir
        IF Value = 2 THEN
            IF DO10_4 = 1 THEN
                Value := 0;        
            ELSEIF DO10_4 = 0 THEN
                Value := 1;
            ENDIF
        ENDIF
        ! Turn ConDir On
        IF Value = 1 THEN
            SetDO DO10_4, 1;
        ! Turn ConDir Off
        ELSEIF Value = 0 THEN
            SetDO DO10_4, 0;
        ENDIF
    ENDPROC

ENDMODULE