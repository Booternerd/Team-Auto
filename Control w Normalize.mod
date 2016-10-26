MODULE Control
    
    ! Persistent variable declaration
    PERS num ControlIndex;
    !PERS num DummyIndex;
    PERS string ControlQueue{10};
    !PERS string DummyQueue{10};
    PERS bool NotClose;
    PERS bool Reachability;
    
    VAR string Message;
    !VAR string DummyMessage;
    VAR string Command;
    VAR num Param{10};
    VAR num ParamNum;
    !VAR num Dummy{10};
    !VAR num DummyNum;
    VAR speeddata Speed;
    VAR num PrevAngle;
    VAR num HeightDefault := 314.82;
    VAR num HeightSweepUpper := 214.82;
    VAR num HeightSweepLower := 179.82;
    VAR num HeightFace1 := 154.82;
    VAR num HeightFace2 := 164.32;

    ! Main function
    PROC ControlMain()
        ControlIndex := 1;
        ControlQueue:=["","","","","","","","","",""];
        !DummyQueue:=["","","","","","","","","",""];
        Reachability := TRUE;
        NotClose := TRUE;
        MoveToCalibPos;
        NormalizeSweepGet 200, 100, 45;
        NormalizeSweep 400,-50;
        NormalizeSweep 400,50;
        WHILE NotClose DO
            WHILE ControlIndex > 1 DO
                PopMessage;
                !PopDummy;
                DecodeMessage;
                !DecodeDummy;
                IF Command = "MA" THEN
                    UpdateSpeed(Param{7});
                    MoveJointsAngle [Param{1},Param{2},Param{3},Param{4},Param{5},Param{6}],Speed;
                ELSEIF Command = "MJ" THEN
                    UpdateSpeed(Param{8});
                    MoveJoints [Param{1},Param{2},Param{3}],[Param{4},Param{5},Param{6},Param{7}],Speed;
                ELSEIF Command = "MF" THEN
                    MoveJoints1 Param{1},Param{2},Param{3},Param{4},Param{5},Param{6},Param{7};
                ELSEIF Command = "ML" THEN
                    UpdateSpeed(Param{8});
                    MoveLinear [Param{1},Param{2},Param{3}],[Param{4},Param{5},Param{6},Param{7}],Speed;
                ELSEIF Command = "NSG" THEN
                    NormalizeSweepGet Param{1},Param{2},Param{3};
                ELSEIF Command = "NS" THEN
                    NormalizeSweep Param{1},Param{2};
                ELSEIF Command = "ND" THEN
                    NormalizeDrop Param{1},Param{2};
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
    
    !PROC PopDummy()
    !    DummyMessage := DummyQueue{1};
    !    DummyIndex := DummyIndex-1;
    !    FOR i FROM 1 TO 9 DO
    !        DummyQueue{i} := DummyQueue{i+1};
    !    ENDFOR
    !ENDPROC
    
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
    
    !PROC DecodeDummy()
    !   VAR num Length; 
    !    VAR num Position;
    !    VAR string Remainder;
    !    VAR string DummyStr{10};
    !    VAR bool KeepDecoding;
    !    VAR bool Temp;
    !    Remainder := DummyMessage;
    !    DummyNum := 0;
    !    KeepDecoding := TRUE;
    !    WHILE KeepDecoding DO
    !        Length := StrLen(Remainder);
    !        Position := StrFind(Remainder,1,STR_WHITE);
    !        IF Position = Length+1 THEN
    !            DummyNum := DummyNum+1;
    !            DummyStr{DummyNum} := Remainder;
    !            KeepDecoding := FALSE;
    !        ELSE
    !            DummyNum := DummyNum+1;
    !            DummyStr{DummyNum} := StrPart(Remainder,1,Position-1);
    !            Remainder := StrPart(Remainder,Position+1,Length-Position);
    !        ENDIF
    !    ENDWHILE
    !    FOR i FROM 1 TO DummyNum DO
    !        Temp := StrtoVal(DummyStr{i},Dummy{i});
    !    ENDFOR
    !ENDPROC
    
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
            Reachability := False;
        Else
            MoveAbsJ [angles, [9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]], speed, fine, tSCup;
            Reachability := True;
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
            Reachability := False;
            StartMove;
            TRYNEXT;
    ENDPROC
    
    PROC MoveJoints(pos p, orient o, speeddata speed)
        ! Input: 'p'~position of end effector in mm i.e [Xpos, Ypos, Zpos]
        !        'o'~orientation of end effector in quaternion i.e. [1, 0, 0, 0]
        ! Moves the end effector based on pose by moving the joint
        ! Matlab have to perform a check to mke sure it is not out of reach
        VAR errnum myerrnum;
        VAR jointtarget jointpos;
        VAR robtarget target;

        target := [p,o,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        jointpos := CalcJointT(target, tSCup, \ErrorNumber:=myerrnum);
        
        IF myerrnum = 1135 OR myerrnum = ERR_ROBLIMIT THEN
            !ERR_ROBLIMIT
            TPWrite "Joint can not be reached. =P";
            Reachability := False;
            ! Add error variable
            
        Else
            MoveJ target, speed, fine, tSCup;
            Reachability := True;
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
            Reachability := False;
            StartMove;
            TRYNEXT;
    ENDPROC
    
    PROC MoveLinear(pos p, orient o, speeddata speed)
        ! Input: 'p'~position of end effector in mm i.e [Xpos, Ypos, Zpos]
        !        'o'~orientation of end effector in quaternion i.e. [1, 0, 0, 0]
        ! Moves the end effector based on pose linearly
        ! Not recomended!:singularity, and out of reach
        VAR errnum myerrnum;
        VAR jointtarget jointpos;
        VAR robtarget target;
        
        target := [p,o,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        jointpos := CalcJointT(target, tSCup, \ErrorNumber:=myerrnum);
        
        IF myerrnum = 1135 OR myerrnum = ERR_ROBLIMIT THEN
            !ERR_ROBLIMIT
            TPWrite "Joint can not be reached. =P";
            Reachability := False;
            ! Add error variable
        Else
            !SingArea \Wrist;
            MoveL target, speed, fine, tSCup;
            Reachability := True;
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
            Reachability := False;
            StartMove;
            TRYNEXT;    
    ENDPROC
    
    FUNC dionum getRP(pose P)
        VAR dionum r;
        VAR errnum myerrnum;
        VAR jointtarget jointpos2;
        VAR robtarget target;
        
        target := [P.trans,P.rot,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        jointpos2 := CalcJointT(target, tSCup, \ErrorNumber:=myerrnum);
        
        RETURN r; 
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
    ENDFUNC
    
    PROC MoveJoints1(num p1, num p2, num p3, num p4, num p5, num p6, num p7)
        ! Input: 'p'~position of end effector in mm i.e [Xpos, Ypos, Zpos]
        !        'o'~orientation of end effector in quaternion i.e. [1, 0, 0, 0]
        ! Moves the end effector based on pose by moving the joint
        ! Matlab have to perform a check to mke sure it is not out of reach
        VAR errnum myerrnum;
        VAR jointtarget rb;
        VAR jointtarget align;
        VAR jointtarget jp;
        VAR robtarget target;
        VAR robtarget rt;
        rb := CJointT();
        
        align := [[rb.robax.rax_1, 0, rb.robax.rax_3, rb.robax.rax_4, rb.robax.rax_5, rb.robax.rax_6],rb.extax];
        MoveAbsJ align, vmax, fine, tSCup;
        
        target := [[p1, p2, p3],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        jp := CalcJointT(target, tSCup, \ErrorNumber:=myerrnum);
        rb := CJointT();
        align := [[jp.robax.rax_1, rb.robax.rax_2, rb.robax.rax_3, rb.robax.rax_4, rb.robax.rax_5, rb.robax.rax_6],jp.extax];
        
        MoveJ [[p1,p2,p3+300],[0,0,1,0],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]], vmax, fine, tSCup;
        
        MoveJ [[p1,p2,p3],[0,0,1,0],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]], v100, fine, tSCup;
        
        WaitTime 0.5;
        
        SetVacRun 1;
        SetVacSol 1;
        
        MoveJ [[p1,p2,p3+100],[0,0,1,0],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]], vmax, fine, tSCup;
        
        MoveJ [[p5,p6,p3+100],[0,0,1,0],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]], vmax, fine, tSCup;
        
        rb := CJointT();
        align := [[rb.robax.rax_1, rb.robax.rax_2, rb.robax.rax_3, rb.robax.rax_4, rb.robax.rax_5, rb.robax.rax_6+p4],rb.extax];
        
        MoveAbsJ align, vmax, fine, tSCup;
        
        rt := CalcRobT(align, tSCup);
        
        MoveJ [[p5,p6,p7],[rt.rot.q1,rt.rot.q2,rt.rot.q3,rt.rot.q4],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]], v100, fine, tSCup;
        
        SetVacSol 0;
        SetVacRun 0;
        
         MoveJ [[p5,p6,p7+200],[rt.rot.q1,rt.rot.q2,rt.rot.q3,rt.rot.q4],[0,0,0,0],[9E9,9E9,9E9,9E9,9E9,9E9]], v100, fine, tSCup;
        
!        VAR errnum myerrnum;
!        VAR jointtarget jointpos;
!        VAR robtarget target;

!        target := [p,o,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
!        jointpos := CalcJointT(target, tSCup, \ErrorNumber:=myerrnum);
        
!        IF myerrnum = 1135 OR myerrnum = ERR_ROBLIMIT THEN
!            !ERR_ROBLIMIT
!            TPWrite "Joint can not be reached. =P";
!            Reachability := False;
!            ! Add error variable
            
!        Else
!            MoveJ target, speed, fine, tSCup;
!            Reachability := True;
!        ENDIF
!        ERROR
!            IF ERRNO = ERR_PATH_STOP THEN
!                StopMove;
!                ClearPath;
!                StorePath;
!                RestoPath;
!                StartMove;
!            ENDIF
!            StopMove;
!            ClearPath;
!            Reachability := False;
!            StartMove;
!            TRYNEXT;
    ENDPROC
    
    
    !=====================================================================================
    
    PROC NormalizeSweepGet(num x, num y, num o)
        VAR robtarget target;
        VAR jointtarget rb;
        VAR jointtarget align;
        target := [[x,y,HeightDefault],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ target, v100, fine, tSCup;
        target := [[x,y,HeightFace1],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ target, v100, fine, tSCup;
        SetVacRun 1;
        SetVacSol 1;
        target := [[x,y,HeightDefault],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ target, v100, fine, tSCup;
        rb := CJointT();
        align := [[rb.robax.rax_1, rb.robax.rax_2, rb.robax.rax_3, rb.robax.rax_4, rb.robax.rax_5, rb.robax.rax_6+o],rb.extax];
        MoveAbsJ align, v100, fine, tSCup;
    ENDPROC
    
    PROC NormalizeSweep(num x, num y)
        VAR num HypCentreX; VAR num HypCentreY;
        VAR num StartX; VAR num StartY;
        VAR num EndX;   VAR num EndY;
        VAR num DistanceA; VAR num DistanceA1; VAR num DistanceA2;
        VAR num DistanceB; VAR num DistanceB1; VAR num DistanceB2;
        VAR num DistanceC; VAR num DistanceC1; VAR num DistanceC2;
        VAR num Angle;
        VAR robtarget target;
        VAR robtarget rt;
        VAR jointtarget rb;
        VAR jointtarget align;
        VAR num Height := 197;
        HypCentreX := 361.5;
        HypCentreY := 0;
        DistanceB := y-HypCentreY;
        DistanceC := x-HypCentreX;
        DistanceA := Sqrt(Pow(DistanceB,2)+Pow(DistanceC,2));
        DistanceA1 := DistanceA+40;
        DistanceA2 := DistanceA-40;
        DistanceB1 := DistanceA1 / DistanceA * DistanceB;
        DistanceB2 := DistanceA2 / DistanceA * DistanceB;
        DistanceC1 := DistanceA1 / DistanceA * DistanceC;
        DistanceC2 := DistanceA2 / DistanceA * DistanceC;
        StartX := HypCentreX + DistanceC1;
        StartY := HypCentreY + DistanceB1;
        EndX := HypCentreX + DistanceC2;
        EndY := HypCentreY + DistanceB2;
        Angle := ATan(DistanceC/DistanceB);
        IF Angle < 0 THEN
            Angle := Angle+90;
        ELSE
            Angle := Angle-90;
        ENDIF
        ! Angle orientiation
        rb := CJointT();
        align := [[rb.robax.rax_1, rb.robax.rax_2, rb.robax.rax_3, rb.robax.rax_4, rb.robax.rax_5, rb.robax.rax_6+Angle],rb.extax];
        MoveAbsJ align, v100, fine, tSCup;
        rt := CalcRobT(align,tSCup);
        ! Move to Start position (default height)
        target := [[StartX,StartY,HeightDefault],rt.rot,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ target, v100, fine, tSCup;
        rt := CalcRobT(align,tSCup);
        ! Move to Start position (upper sweep height)
        target := [[StartX,StartY,HeightSweepUpper],rt.rot,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ target, v100, fine, tSCup;
        ! Move to End position (upper sweep height)
        target := [[EndX,EndY,HeightSweepUpper],rt.rot,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ target, v100, fine, tSCup;
         ! Move to Start position (upper sweep height)
        target := [[StartX,StartY,HeightSweepUpper],rt.rot,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ target, v100, fine, tSCup;
        ! Move to Start position (lower sweep height)
        target := [[StartX,StartY,HeightSweepLower],rt.rot,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ target, v100, fine, tSCup;
        ! Move to End position (lower sweep height)
        target := [[EndX,EndY,HeightSweepLower],rt.rot,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ target, v100, fine, tSCup;
        ! Move to End position (default height)
        target := [[EndX,EndY,HeightDefault],rt.rot,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ target, v100, fine, tSCup;
        ! Horizontal Orientation
        rb := CJointT();
        align := [[rb.robax.rax_1, rb.robax.rax_2, rb.robax.rax_3, rb.robax.rax_4, rb.robax.rax_5, rb.robax.rax_6-Angle],rb.extax];
        MoveAbsJ align, v100, fine, tSCup;
        ! After matlab has finished calling this function X times, VacSol = VacRun = 0;
    ENDPROC
    
    PROC NormalizeDrop(num x, num y)
        VAR robtarget target;
        VAR jointtarget rb;
        VAR jointtarget align;
        target := [[x,y,HeightFace2+50],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ target, v100, fine, tSCup;
        target := [[x,y,HeightFace2],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ target, v100, fine, tSCup;
        SetVacRun 1;
        SetVacSol 1;
        target := [[x,y,HeightFace2+50],[0,0,1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        MoveJ target, v100, fine, tSCup;
        SetVacSol 0;
        SetVacRun 0;
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
    
!    PROC FricIDEventStart()
!    ENDPROC
    
ENDMODULE