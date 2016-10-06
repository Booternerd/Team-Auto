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
    PERS string ControlQueue{10};
    
    ! Declare global variables
    VAR string Message;
    VAR string Command;
    VAR num Params{10};
    VAR num ParamNum;
    VAR speeddata Speed;
    
    !---------------
    ! MAIN FUNCTION
    !---------------

    ! Inputs:  [None]
    ! Outputs: [None]
    ! Comment: Main routine for Control Module
    PROC ControlMain()
        ! Infinite loop
        WHILE TRUE DO
            ! While 'ControlQueue' has messages
            WHILE ControlIndex > 1 DO
                PopMessage;     ! Pop 'ControlQueue' to 'Message'
                DecodeMessage;  ! Decode 'Message' into 'Command' and 'Params{}'
                ! Check the 'Command'
                IF Command = "MA" THEN
                    UpdateSpeed(Params{7});
                    MoveJointsAngle [Params{1},Params{2},Params{3},Params{4},Params{5},Params{6}],Speed;
                ELSEIF Command = "MJ" THEN
                    UpdateSpeed(Params{8});
                    MoveJoints [Params{1},Params{2},Params{3}],[Params{4},Params{5},Params{6},Params{7}],Speed;
                ELSEIF Command = "ML" THEN
                    UpdateSpeed(Params{8});
                    MoveLinear [Params{1},Params{2},Params{3}],[Params{4},Params{5},Params{6},Params{7}],Speed;
                ELSEIF Command = "SetConRun" THEN
                    SetConRun Params{1};
                ELSEIF Command = "SetConDir" THEN
                    SetConDir Params{1};
                ELSEIF Command = "SetVacRun" THEN
                    SetVacRun Params{1};
                ELSEIF Command = "SetVacSol" THEN
                    SetVacSol Params{1};
                ENDIF
            ENDWHILE
        ! End infinite loop
        ENDWHILE
    ! End main routine
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
            Temp := StrtoVal(ParamStr{i},Params{i});
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