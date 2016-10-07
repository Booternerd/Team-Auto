MODULE Receive

!=====================
! RECEIVE MODULE
! MTRN4230 ROBOTICS
! TEAM AUTO (GROUP 5)
!=====================

! Description: Polls for strings from Matlab over a socket.

    !----------------------
    ! VARIABLE DECLARATION
    !----------------------

    ! Declare multitasking variables
    PERS string ControlQueue{10};   ! Control Module string message queue
    PERS string StatusQueue{10};    ! Status Module string message queue
    PERS num ControlIndex;          ! Index for Control Module message queue
    PERS num StatusIndex;           ! Index for Status Module message queue
    PERS bool KeepLooping;          ! Flag for looping infinitely
    PERS bool Reachability;         ! Flag for reachability status
    
    ! Declare global variables
    !CONST string Host := "192.168.2.1";
    CONST string Host := "127.0.0.1";   ! Virtual
    CONST num Port := 1025;     ! Connection port
    VAR socketdev ClientSocket; ! Socket connected to the client.
    VAR string StringIn;        ! String received over socket
    VAR string Type;            ! Message type ('S' for Status queue and 'C' for Control queue)
    VAR string Message;         ! Message containing Command and Params
    VAR intnum IntConStat;      ! Interrupt for ConStat
    
    !--------------
    ! MAIN ROUTINE
    !--------------
    
    PROC ReceiveMain()
        ! Initialize multitasking variables
        ControlQueue := ["","","","","","","","","",""];
        StatusQueue := ["","","","","","","","","",""];
        ControlIndex := 1;
        StatusIndex := 1;
        KeepLooping := TRUE;
        Reachability := TRUE;
        ! Connecting interrupt with trap routine
        IDelete IntConStat;
        CONNECT IntConStat WITH TrapConStat;
        ISignalDI DI10_1, 0, IntConStat;        ! Interrupt when ConStat is clear
        ! Open socket connection
        OpenReceiveConnection;
        ! Infinite loop
        WHILE KeepLooping DO
            ! Poll the socket for a string
            SocketReceive ClientSocket \Str := StringIn;
            ! Extract instruction type
            ExtractType;
            ! If Control instruction 
            IF Type = "C" THEN
                SocketReceive ClientSocket \Str := StringIn;  ! COMMENT OUT
                ! Push to Control Module message queue
                PushMessage(Type);
            ! If Status instruction
            ELSEIF Type = "S" THEN
                ! Push to Status Module message queue
                PushMessage(Type);
            ! If Pause motion instruction
            ELSEIF Type = "Pause" THEN
                StopMove;
            ! If Start motion instruction
            ELSEIF Type = "Start" THEN
                StartMove;
            ! If Close socket instruction
            ELSEIF Type = "Close" THEN
                KeepLooping := FALSE;
            ENDIF
        ! End infinite loop
        ENDWHILE
        ! Close socket connection
        CloseReceiveConnection;
        !----------------
        ! ERROR ROUTINES
        !----------------
        ERROR
            ! If socket timeout error
            IF ERRNO = ERR_SOCK_TIMEOUT THEN
                ! Rerun line with error
                RETRY;  
            ! If socket closed error
            ELSEIF ERRNO = ERR_SOCK_CLOSED THEN
                ! Reconnect socket
                CloseReceiveConnection;
                OpenReceiveConnection;
                ! Rerun line with error
                RETRY;
            ENDIF
            ! Else run line after error
            TRYNEXT;
    ENDPROC
    
    !---------------
    ! TRAP ROUTINES
    !---------------
    
    ! Input:   [None]
    ! Output:  [None]
    ! Comment: Triggers if ConStat cleared
    !          Reset conveyor and wait for ConStat input
    TRAP TrapConStat
        ! Reset ConRun and ConDir
        SetDO DO10_3, 0;  
        SetDO DO10_4, 0; 
        ! Wait for ConStat to be set
        WaitDI DI10_1, 1;
    ENDTRAP
    
    !-----------------
    ! SOCKET ROUTINES
    !-----------------
    
    ! Inputs:  [None]
    ! Outputs: [None]
    ! Comment: Open connection to client
    PROC OpenReceiveConnection()
        ! Create the socket to listen for a connection on.
        VAR socketdev WelcomeSocket;
        SocketCreate WelcomeSocket;
        ! Bind the socket to the Host and Port.
        SocketBind WelcomeSocket, Host, Port;
        ! Listen on the welcome socket.
        SocketListen WelcomeSocket;
        ! Accept a connection on the host and port.
        SocketAccept WelcomeSocket, ClientSocket;
        ! Close the welcome socket, as it is no longer needed.
        SocketClose WelcomeSocket;
    ENDPROC
    
    ! Inputs:  [None]
    ! Outputs: [None]
    ! Comment: Close connection to client
    PROC CloseReceiveConnection()
        SocketClose ClientSocket;
    ENDPROC

    !-----------------------
    ! MULTITASKING ROUTINES
    !-----------------------
    
    ! Inputs:  [None]
    ! Outputs: [None]
    ! Comment: Extracts the instruction type and message
    PROC ExtractType()
        VAR num Length; 
        VAR num Position;
        Length := StrLen(StringIn);
        Position := StrFind(StringIn,1,STR_WHITE);
        ! Type = before first space
        Type := StrPart(StringIn,1,Position-1);
        ! Message = after first space
        Message := StrPart(StringIn,Position+1,Length-Position);    
    ENDPROC
    
    !---------------------------------
    ! COMMUNICATION PROTOCOL ROUTINES
    !---------------------------------
    
    ! Inputs:  Character 'C' or 'S' for Control/Status
    ! Outputs: [None]
    ! Comment: Pushes Message to the Control/Status Module message queue
    PROC PushMessage(string Char)
        IF Char = "C" AND ControlIndex < 10 THEN
            ! Add message to bottom of Control Message queue
            ControlQueue{ControlIndex} := Message;  
            ! Increment Status Messagequeue index
            ControlIndex := ControlIndex + 1;       
        ELSEIF Char = "S" AND StatusIndex < 10 THEN
            ! Add message to bottom of Status Message queue
            StatusQueue{StatusIndex} := Message;    
            ! Increment Status Message queue index
            StatusIndex := StatusIndex + 1;         
        ENDIF
    ENDPROC
    
!----------------------
! CHANGE LOG
!-----------------------
! Week 03 - Tyson Chan
!           <What you did>
! Week 03 - Faris Azhari
!           <What Faris Did>
! Week 03 - Ankur Goel

ENDMODULE