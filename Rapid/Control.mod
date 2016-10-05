MODULE Control
    
    ! Persistent variable declaration
    PERS num ControlIndex;
    PERS string ControlQueue{10};
    
    VAR string Message;
    VAR string Command;
    VAR num Param{10};
    VAR num ParamNum;
    VAR speeddata Speed;
    
    ! Main function
    PROC ControlMain()
        !ControlQueue{1} := "MoveJointsAngle 10 10 10 10 10 10 3";
        !ControlQueue{2} := "MoveJointsAngle 0 0 0 0 0 0 5";
        !ControlQueue{3} := "MoveJointsAngle -20 20 -20 20 -20 20 1";
        !ControlQueue{4} := "MoveJointsAngle 0 0 0 0 0 0 5";
        !ControlIndex := 5;
        WHILE TRUE DO
            WHILE ControlIndex > 1 DO
                PopMessage;
                DecodeMessage;
                IF Command = "MA" THEN
                    UpdateSpeed(Param{7});
                    MoveJointsAngle [Param{1},Param{2},Param{3},Param{4},Param{5},Param{6}],Speed;
                ELSEIF Command = "MJ" THEN
                    UpdateSpeed(Param{8});
                    MoveJoints [Param{1},Param{2},Param{3}],[Param{4},Param{5},Param{6},Param{7}],Speed;
                ELSEIF Command = "ML" THEN
                    UpdateSpeed(Param{8});
                    MoveLinear [Param{1},Param{2},Param{3}],[Param{4},Param{5},Param{6},Param{7}],Speed;
                ELSEIF Command = "SetConRun" THEN
                    SetConRun Param{1};
                ELSEIF Command = "SetConDir" THEN
                    SetConDir Param{1};
                ELSEIF Command = "SetVacRun" THEN
                    SetVacRun Param{1};
                ELSEIF Command = "SetVacSol" THEN
                    SetVacSol Param{1};
                ENDIF
            ENDWHILE
        ENDWHILE
    ENDPROC
    
    PROC PopMessage()
        Message := ControlQueue{1};
        ControlIndex := ControlIndex-1;
        FOR i FROM 1 TO 9 DO
            ControlQueue{i} := ControlQueue{i+1};
        ENDFOR
    ENDPROC
    
    PROC DecodeMessage()
        VAR num Length; 
        VAR num Position;
        VAR string Remainder;
        VAR string ParamStr{10};
        VAR bool KeepDecoding;
        VAR bool Temp;
        Length := StrLen(Message);
        Position := StrFind(Message,1,STR_WHITE);
        Command := StrPart(Message,1,Position-1);
        Remainder := StrPart(Message,Position+1,Length-Position);
        ParamNum := 0;
        KeepDecoding := TRUE;
        WHILE KeepDecoding DO
            Length := StrLen(Remainder);
            Position := StrFind(Remainder,1,STR_WHITE);
            IF Position = Length+1 THEN
                ParamNum := ParamNum+1;
                ParamStr{ParamNum} := Remainder;
                KeepDecoding := FALSE;
            ELSE
                ParamNum := ParamNum+1;
                ParamStr{ParamNum} := StrPart(Remainder,1,Position-1);
                Remainder := StrPart(Remainder,Position+1,Length-Position);
            ENDIF
        ENDWHILE
        FOR i FROM 1 TO ParamNum DO
            Temp := StrtoVal(ParamStr{i},Param{i});
        ENDFOR
    ENDPROC
    
    PROC UpdateSpeed(num Value)
        IF Value = 1 THEN
            Speed := v50;
        ELSEIF Value = 2 THEN
            Speed := v100;
        ELSEIF Value = 3 THEN
            Speed := v150;
        ELSEIF Value = 4 THEN
            Speed := v200;
        ELSEIF Value = 5 THEN
            Speed := vmax;
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
    
    PROC SetVacSol(num Value)
        ! Switch VacSol
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
        ! Turn VacSol On
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