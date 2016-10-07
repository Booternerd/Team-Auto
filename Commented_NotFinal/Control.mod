MODULE Control
    
!=====================
! CONTROL MODULE
! MTRN4230 ROBOTICS
! TEAM AUTO (GROUP 5)
!=====================

! Description: Controls robot motion and I/O

    !----------------------
    ! VARIABLE DECLARATION
    !----------------------

    ! Declare multitasking variables
    PERS string ControlQueue{10};   ! Control Module string message queue
    PERS num ControlIndex;          ! Index for Control Module message queue
    PERS bool KeepLooping;          ! Flag for looping infinitely
    PERS bool Reachability;         ! Flag for reachability status
    
    ! Declare global variables
    VAR string Message;     ! Stores message popped from queue
    VAR string Command;     ! Stores Command (function name)
    VAR num Param{8};       ! Array of function parameters
    VAR speeddata Speed;    ! Speed setting

    !---------------
    ! MAIN ROUTINE
    !---------------
    
    PROC ControlMain()
        ! Initialize multitasking variables
        ControlQueue:=["","","","","","","","","",""];
        ControlIndex := 1;
        Reachability := TRUE;
        KeepLooping := TRUE;
        ! Infinite loop
        WHILE KeepLooping DO
            ! While there are items in the Control Module message queue
            WHILE ControlIndex > 1 DO
                ! Pop top item from Control Module message queue
                PopMessage;
                ! Decode Message into Command and Params{}
                DecodeMessage;
                ! If MoveAngle instruction
                IF Command = "MA" THEN
                    UpdateSpeed(Param{7});
                    MoveAngle [Param{1},Param{2},Param{3},Param{4},Param{5},Param{6}],Speed;
                ! If MoveJoint instruction
                ELSEIF Command = "MJ" THEN
                    UpdateSpeed(Param{8});
                    MoveJoint [Param{1},Param{2},Param{3}],[Param{4},Param{5},Param{6},Param{7}],Speed;
                ! If MoveLinear instruction
                ELSEIF Command = "ML" THEN
                    UpdateSpeed(Param{8});
                    MoveLinear [Param{1},Param{2},Param{3}],[Param{4},Param{5},Param{6},Param{7}],Speed;
                ! If SetConRun instructino
                ELSEIF Command = "SetConRun" THEN
                    SetConRun Param{1};
                ! If SetConDir instruction
                ELSEIF Command = "SetConDir" THEN
                    SetConDir Param{1};
                ! If SetVacRun instruction
                ELSEIF Command = "SetVacRun" THEN
                    SetVacRun Param{1};
                ! If SetVacSol instruction
                ELSEIF Command = "SetVacSol" THEN
                    SetVacSol Param{1};
                ENDIF
            ENDWHILE
        ENDWHILE
        !----------------
        ! ERROR ROUTINES
        !----------------
        ERROR
            ! If the robot stops moving
            IF ERRNO = ERR_PATH_STOP THEN
                ! Cease motion and clear stored path/path
                StopMove;
                ClearPath;
                StorePath;
                RestoPath;
                StartMove;
            ENDIF
            ! Stop motion and clear path
            StopMove;
            ClearPath;
            StartMove;
            TRYNEXT;
    ENDPROC
    
    !-----------------------
    ! MULTITASKING ROUTINES
    !-----------------------
    
    ! Inputs:  [None]
    ! Outputs: [None]
    ! Comment: Pops Message from ControlQueue
    PROC PopMessage()
        ! Set Message to first item in ControlQueue
        Message := ControlQueue{1};
        ! Decrement ControlIndex
        ControlIndex := ControlIndex-1;
        ! Shift all items in the queue
        FOR i FROM 1 TO 9 DO
            ControlQueue{i} := ControlQueue{i+1};
        ENDFOR
    ENDPROC
    
    !---------------------------------
    ! COMMUNICATION PROTOCOL ROUTINES
    !---------------------------------
    
    ! Inputs:  [None]
    ! Outputs: [None]
    ! Comment: Decodes Message into Command and Params{}
    PROC DecodeMessage()
        VAR num Length; 
        VAR num Position;
        VAR num ParamNum;
        VAR string Remainder;
        VAR string ParamStr{10};
        VAR bool KeepDecoding;
        VAR bool Temp;
        Length := StrLen(Message);
        Position := StrFind(Message,1,STR_WHITE);
        ! Command = before first space
        Command := StrPart(Message,1,Position-1);
        ! Remainder = after first space
        Remainder := StrPart(Message,Position+1,Length-Position);
        ParamNum := 0;
        KeepDecoding := TRUE;
        ! Keep decoding until entire string processed
        WHILE KeepDecoding DO
            Length := StrLen(Remainder);
            Position := StrFind(Remainder,1,STR_WHITE);
            ParamNum := ParamNum+1;
            ! If end of string reached
            IF Position = Length+1 THEN      
                ParamStr{ParamNum} := Remainder;
                KeepDecoding := FALSE;
            ! Else keep splitting parameters and updating remaining
            ELSE
                ParamStr{ParamNum} := StrPart(Remainder,1,Position-1);
                Remainder := StrPart(Remainder,Position+1,Length-Position);
            ENDIF
        ENDWHILE
        ! Convert all parameters from strings to values
        FOR i FROM 1 TO ParamNum DO
            Temp := StrtoVal(ParamStr{i},Param{i});
        ENDFOR
    ENDPROC
    
    ! Inputs:  Integer (1-5) corresponding to different speeds
    ! Outputs: [None]
    ! Comment: Update global Speed parameter
    PROC UpdateSpeed(num Value)
        ! Very low
        IF Value = 1 THEN
            Speed := v50;
        ! Low
        ELSEIF Value = 2 THEN
            Speed := v100;
        ! Medium
        ELSEIF Value = 3 THEN
            Speed := v150;
        ! High
        ELSEIF Value = 4 THEN
            Speed := v200;
        ! Very high
        ELSEIF Value = 5 THEN
            Speed := vmax;
        ENDIF
    ENDPROC
    
    !-------------------------
    ! MOTION CONTROL ROUTINES
    !-------------------------
    
    ! Inputs:  robjoint, angles of each joint in degrees i.e. [10,10,10,10,10,10]
    !          speeddata, speed setting for motion
    ! Outputs: [None]
    ! Comment: Moves the robot based on the angles of each joints
    PROC MoveAngle(robjoint angles, speeddata speed)
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
    
    ! Inputs:  'p'~position of end effector in mm i.e [Xpos, Ypos, Zpos]
    !          'o'~orientation of end effector in quaternion i.e. [1, 0, 0, 0]
    ! Outputs: [None]
    ! Comment:  Moves the end effector based on pose by moving the joint
    PROC MoveJoint(pos p, orient o, speeddata speed)
        VAR errnum myerrnum;
        VAR jointtarget jointpos;
        VAR robtarget target;
        target := [p,o,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
        jointpos := CalcJointT(target, tSCup, \ErrorNumber:=myerrnum);
        IF myerrnum = 1135 OR myerrnum = ERR_ROBLIMIT THEN
            !ERR_ROBLIMIT
            TPWrite "Joint can not be reached. =P";
            Reachability := False;
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
            Reachability := False;
            StopMove;
            ClearPath;
            StartMove;
            TRYNEXT;
    ENDPROC
    
    ! Inputs:  'p'~position of end effector in mm i.e [Xpos, Ypos, Zpos]
    !          'o'~orientation of end effector in quaternion i.e. [1, 0, 0, 0]
    ! Outputs: [None]
    ! Comment:  Moves the end effector based on pose linearly
    PROC MoveLinear(pos p, orient o, speeddata speed)
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
            Reachability := False;
            StopMove;
            ClearPath;
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
    
    !----------------------
    ! I/O CONTROL ROUTINES
    !----------------------
    
    ! Inputs:  Value (0 = off, 1 = on)
    ! Outputs: [None]
    ! Comment: Turns VacRun on and off
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
    
    ! Inputs:  Value (0 = off, 1 = on)
    ! Outputs: [None]
    ! Comment: Turns the VacSol on and off
    PROC SetVacSol(num Value)
        ! Turn VacSol On
        IF Value = 1 THEN
            IF DOutput(DO10_1) = 1 THEN          ! If VacRun On
                SetDO DO10_2, 1;            ! VacSuck = 1           
            ELSEIF DOutput(DO10_1) = 0 THEN      ! If VacRun Off         
                SetDO DO10_2, 0;            ! VacSuck = 0
            ENDIF
        ! Turn VacSuck Off
        ELSEIF Value = 0 THEN
            SetDO DO10_2, 0;            ! VacSuck = 0 
        ENDIF   
    ENDPROC
    
    ! Inputs:  Value (0 = off, 1 = on)
    ! Outputs: [None]
    ! Comment: Turns the ConRun on and off
    PROC SetConRun(num Value)
        ! Turn ConRun On
        IF Value = 1 THEN
            ! Check ConStat
            IF DInput(DI10_1) = 1 THEN
                SetDO DO10_3, 1;
            ELSE
                SetDO DO10_3, 0;
            ENDIF
        ! Turn ConRun Off
        ELSEIF Value = 0 THEN
            SetDO DO10_3, 0;
        ENDIF
    ENDPROC
    
    ! Inputs:  Value (0 = off, 1 = on)
    ! Outputs: [None]
    ! Comment: Turns the ConDir on and off
    PROC SetConDir(num Value)
        ! Turn ConDir On
        IF Value = 1 THEN
            SetDO DO10_4, 1;
        ! Turn ConDir Off
        ELSEIF Value = 0 THEN
            SetDO DO10_4, 0;
        ENDIF
    ENDPROC
    
ENDMODULE