MODULE Control
    
!===================
! MTRN4230 Robotics
! Team Auto
! Control Module
!===================

! Description: For controlling robot motion and setting I/O (vacuum and conveyor)
    
    !----------------------
    ! VARIABLE DECLARATION
    !----------------------
    
    ! Declare multitasking variables
    PERS num ControlIndex;
    PERS num DummyIndex;
    PERS string ControlQueue{10};
    PERS string DummyQueue{10};
    PERS bool NotClose;
    PERS bool Reachable;
    
    ! Declare global variables
    VAR string Message;
    VAR string DummyMessage;
    VAR string Command;
    VAR num Param{10};
    VAR num ParamNum;
    VAR num Dummy{10};
    VAR num DummyNum;
    VAR speeddata Speed;
    
    !---------------
    ! MAIN FUNCTION
    !---------------

    ! Inputs:  [None]
    ! Outputs: [None]
    ! Comment: Main routine for Control Module
    ! Main function
    PROC ControlMain()
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
    
    !------------------------
    ! MULTITASKING FUNCTIONS
    !------------------------
    
    ! Inputs:  
    ! Outputs: 
    ! Comment: 
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
    
    !----------------------------------
    ! COMMUNICATION PROTOCOL FUNCTIONS
    !----------------------------------
    
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
    
    !------------------
    ! MOTION FUNCTIONS
    !------------------
    
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
            Reachable := FALSE;
            TPWrite "Joint can not be reached. =P";
        ELSE
            Reachable := TRUE;
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
            Reachable := FALSE;
            TPWrite "Joint can not be reached. =P";
        ELSE
            Reachable := TRUE;
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
        
        Reachable := TRUE;
        jointpos2 := CalcJointT(jointpos3, tSCup, \ErrorNumber:=myerrnum);
        
        IF myerrnum = 1135 OR myerrnum = ERR_ROBLIMIT THEN
            !ERR_ROBLIMIT
            TPWrite "Joint can not be reached. =P";
        ELSE
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
    
    FUNC dionum getRP(pose P)
        VAR dionum r;
        VAR errnum myerrnum;
        VAR jointtarget jointpos2;
        VAR robtarget jointpos3;
        
        jointpos3 := [P.trans,P.rot,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        jointpos2 := CalcJointT(jointpos3, tSCup, \ErrorNumber:=myerrnum);
        
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
    
    !-----------------------
    ! I/O SETTING FUNCTIONS
    !-----------------------
    
    ! Input:  
    ! Output:
    ! Comment: 
    PROC SetVacRun(num Value)
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
    
    ! Inputs:  Number variable 'Value' (0-1)
    ! Outputs: [None]
    ! Comment: Enables and disables conveyor
    PROC SetConRun(num Value)
        IF Value = 1 THEN           ! If 'Value' is 1
            IF DI10_1 = 1 THEN          ! If 'ConStat' set
                SetDO DO10_3, 1;            ! Set 'ConRun' (on)
            ELSE                        ! Else if 'Constat' cleared
                SetDO DO10_3, 0;            ! Clear 'ConRun' (off)
            ENDIF
        ELSEIF Value = 0 THEN       ! Else if 'Value' is 0
            SetDO DO10_3, 0;            ! Clear 'ConRun' (off)
        ENDIF
    ENDPROC
    
    ! Inputs:  Number variable 'Value' (0-1)
    ! Outputs: [None]
    ! Comment: Sets conveyor direction
    PROC SetConDir(num Value)
        IF Value = 1 THEN           ! If 'Value' is 1
            SetDO DO10_4, 1;            ! Set 'ConDir' (forward)
        ELSEIF Value = 0 THEN       ! Else if 'Value' is 0
            SetDO DO10_4, 0;            ! Clear 'ConDir' (backward)
        ENDIF
    ENDPROC

!------------------------------------
! CHANGE LOG
!------------------------------------
! 22/08/1994: Tyson Chan
!             <Insert Changes Made>
! dd/MM/yyyy: Ankur Goel
!             <Insert Other Changes>
!------------------------------------

ENDMODULE