MODULE Control
    
    ! Persistent variable declaration
    PERS num ControlIndex;
    PERS num DummyIndex;
    PERS string ControlQueue{10};
    PERS string DummyQueue{10};
    PERS bool NotClose;
    
    VAR string Message;
    VAR string DummyMessage;
    VAR string Command;
    VAR num Param{10};
    VAR num ParamNum;
    VAR num Dummy{10};
    VAR num DummyNum;
    VAR speeddata Speed;
    
    ! Main function
    PROC ControlMain()
        ControlQueue:=["","","","","","","","","",""];
        DummyQueue:=["","","","","","","","","",""];
        NotClose := TRUE;
        WHILE NotClose DO
            WHILE ControlIndex > 1 DO
                PopMessage;
                PopDummy;
                DecodeMessage;
                DecodeDummy;
                IF Command = "MA" THEN
                    UpdateSpeed(Param{7});
                    MoveJointsAngle [Param{1},Param{2},Param{3},Param{4},Param{5},Param{6}],Speed;
                ELSEIF Command = "MJ" THEN
                    UpdateSpeed(Param{8});
                    MoveJoints [Param{1},Param{2},Param{3}],[Param{4},Param{5},Param{6},Param{7}],Speed;
                    ! errorcheck()
                    ! Use Dummy{x}
                    ! REMOVE THE BELOW
!                        DecodeDummy;
!                        WaitTime 1;
!                        MoveToCalibPos;
!                        WaitTime 1;
!                        MoveJointsAngle [Dummy{1},Dummy{2},Dummy{3},Dummy{4},Dummy{5},Dummy{6}],Speed;
                ELSEIF Command = "ML" THEN
                    UpdateSpeed(Param{8});
                    MoveLinear [Param{1},Param{2},Param{3}],[Param{4},Param{5},Param{6},Param{7}],Speed;
                    ! Use Dummy{x}
                ELSEIF Command = "SetConRun" THEN
                    SetConRun Param{1};
                ELSEIF Command = "SetConDir" THEN
                    SetConDir Param{1};
                ELSEIF Command = "SetVacRun" THEN
                    SetVacRun Param{1};
                ELSEIF Command = "SetVacSol" THEN
                    SetVacSol Param{1};
                ELSEIF Command = "Home" THEN
                    MoveToCalibPos;
                ENDIF
            ENDWHILE
        ENDWHILE
        ERROR
            IF ERRNO = ERR_PATH_STOP THEN
                StopMove;
                ClearPath;
                StorePath;
                RestoPath;
                StartMove;
            ENDIF
            StopMove;
            ClearPath;
            StartMove;
            TRYNEXT;
    ENDPROC
    
    PROC PopMessage()
        Message := ControlQueue{1};
        ControlIndex := ControlIndex-1;
        FOR i FROM 1 TO 9 DO
            ControlQueue{i} := ControlQueue{i+1};
        ENDFOR
    ENDPROC
    
    PROC PopDummy()
        DummyMessage := DummyQueue{1};
        DummyIndex := DummyIndex-1;
        FOR i FROM 1 TO 9 DO
            DummyQueue{i} := DummyQueue{i+1};
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
    
    PROC DecodeDummy()
        VAR num Length; 
        VAR num Position;
        VAR string Remainder;
        VAR string DummyStr{10};
        VAR bool KeepDecoding;
        VAR bool Temp;
        Remainder := DummyMessage;
        DummyNum := 0;
        KeepDecoding := TRUE;
        WHILE KeepDecoding DO
            Length := StrLen(Remainder);
            Position := StrFind(Remainder,1,STR_WHITE);
            IF Position = Length+1 THEN
                DummyNum := DummyNum+1;
                DummyStr{DummyNum} := Remainder;
                KeepDecoding := FALSE;
            ELSE
                DummyNum := DummyNum+1;
                DummyStr{DummyNum} := StrPart(Remainder,1,Position-1);
                Remainder := StrPart(Remainder,Position+1,Length-Position);
            ENDIF
        ENDWHILE
        FOR i FROM 1 TO DummyNum DO
            Temp := StrtoVal(DummyStr{i},Dummy{i});
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
        VAR errnum myerrnum;
        VAR jointtarget target;
        VAR jointtarget jointpos2;
        VAR robtarget jointpos3;
        
        target := [angles, [9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        jointpos3 := CalcRobT(target, tSCup);
        jointpos2 := CalcJointT(jointpos3, tSCup, \ErrorNumber:=myerrnum);
        IF myerrnum = 1135 OR myerrnum = ERR_ROBLIMIT THEN
            !ERR_ROBLIMIT
            TPWrite "Joint can not be reached. =P";
        Else
            MoveAbsJ [angles, [9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], speed, fine, tSCup;
        ENDIF
        ERROR
            IF ERRNO = ERR_PATH_STOP THEN
                StopMove;
                ClearPath;
                StorePath;
                RestoPath;
                StartMove;
            ENDIF
            StopMove;
            ClearPath;
            StartMove;
            TRYNEXT;
    ENDPROC
    
    PROC MoveJoints(pos p, orient o, speeddata speed)
        ! Input: 'p'~position of end effector in mm i.e [Xpos, Ypos, Zpos]
        !        'o'~orientation of end effector in quaternion i.e. [1, 0, 0, 0]
        ! Moves the end effector based on pose by moving the joint
        ! Matlab have to perform a check to mke sure it is not out of reach
        VAR errnum myerrnum;
        VAR jointtarget jointpos2;
        VAR robtarget jointpos3;
        
        jointpos3 := CalcRobT([[Dummy{1},Dummy{2},Dummy{3},Dummy{4},Dummy{5},Dummy{6}],[9E9,9E9,9E9,9E9,9E9,9E9]], tSCup);
        jointpos2 := CalcJointT(jointpos3, tSCup, \ErrorNumber:=myerrnum);
        
        IF myerrnum = 1135 OR myerrnum = ERR_ROBLIMIT THEN
            !ERR_ROBLIMIT
            TPWrite "Joint can not be reached. =P";
        Else
            MoveJ [p,o,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], speed, fine, tSCup;
        ENDIF
        ERROR
            IF ERRNO = ERR_PATH_STOP THEN
                StopMove;
                ClearPath;
                StorePath;
                RestoPath;
                StartMove;
            ENDIF
            StopMove;
            ClearPath;
            StartMove;
            TRYNEXT;
    ENDPROC
    
    PROC MoveLinear(pos p, orient o, speeddata speed)
        ! Input: 'p'~position of end effector in mm i.e [Xpos, Ypos, Zpos]
        !        'o'~orientation of end effector in quaternion i.e. [1, 0, 0, 0]
        ! Moves the end effector based on pose linearly
        ! Not recomended!:singularity, and out of reach
        VAR errnum myerrnum;
        VAR jointtarget jointpos2;
        VAR robtarget jointpos3;
        
        jointpos3 := CalcRobT([[Dummy{1},Dummy{2},Dummy{3},Dummy{4},Dummy{5},Dummy{6}],[9E9,9E9,9E9,9E9,9E9,9E9]], tSCup);
        jointpos2 := CalcJointT(jointpos3, tSCup, \ErrorNumber:=myerrnum);
        
        IF myerrnum = 1135 OR myerrnum = ERR_ROBLIMIT THEN
            !ERR_ROBLIMIT
            TPWrite "Joint can not be reached. =P";
        Else
            MoveL [p,o,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], speed, fine, tSCup;
        ENDIF
        ERROR
            IF ERRNO = ERR_PATH_STOP THEN
                StopMove;
                ClearPath;
                StorePath;
                RestoPath;
                StartMove;
            ENDIF
            StopMove;
            ClearPath;
            StartMove;
            TRYNEXT;    
    ENDPROC
    
    PROC SetVacRun(num Value)
        ! Switch VacRun
        IF Value = 2 THEN
            IF DOutput(DO10_1) = 1 THEN          ! If VacRun On
                Value := 0;              ! Turn VacRun Off
            ELSEIF DOutput(DO10_1) = 0 THEN      ! If VacRun Off
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
            IF DOutput(DO10_1) = 1 THEN          ! If VacRun On      
                IF DOutput(DO10_2) = 1 THEN          ! If VacSuck On
                    Value := 0;                 ! Turn VacSuck Off
                ELSEIF DOutput(DO10_2) = 0 THEN      ! If VacSuck Off 
                    Value := 1;                 ! Turn VacSuck On
                ENDIF            
            ELSEIF DOutput(DO10_1) = 0 THEN      ! If VacRun Off
                Value := 0;                 ! Turn VacSuck Off
            ENDIF
        ENDIF
        ! Turn VacSol On
        IF Value = 1 THEN
            IF DOutput(DO10_1) = 1 THEN          ! If VacRun On
                SetDO DO10_2, 1;            ! VacSuck = 1           
            ELSEIF DOutput(DO10_1) = 0 THEN      ! If VacRun Off (?REDUNDANT?)           
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
                IF DOutput(DO10_3) = 1 THEN
                    Value := 0;         
                ELSEIF DOutput(DO10_3) = 0 THEN
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
            IF DOutput(DO10_4) = 1 THEN
                Value := 0;        
            ELSEIF DOutput(DO10_4) = 0 THEN
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