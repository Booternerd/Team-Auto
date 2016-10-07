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
    !PERS bool KeepLooping;          ! Flag for looping infinitely
    PERS bool Reachability;         ! Flag for reachability status
    PERS bool NotClose;
    
    ! Declare global variables
    !CONST string Host := "192.168.2.1";
    CONST string Host := "127.0.0.1";   ! Virtual
    CONST num Port := 1025;     ! Connection port
    VAR socketdev ClientSocket; ! Socket connected to the client.
    VAR string StringIn;        ! String received over socket
    VAR string Type;            ! Message type ('S' for Status queue and 'C' for Control queue)
    VAR string Message;         ! Message containing Command and Params
    VAR intnum IntConStat;      ! Interrupt for ConStat
    
    ! The socket connected to the client.
    VAR string ReceivedString;
    VAR intnum int_move_stop; 
    
    !--------------
    ! MAIN ROUTINE
    !--------------
    
    ! Main function
    PROC ReceiveMain()
        ControlQueue:=["","","","","","","","","",""];
        !DummyQueue:=["","","","","","","","","",""];
        IDelete int_move_stop;
        CONNECT int_move_stop WITH trap_move_stop;
        ISignalDI DI10_1, 0, int_move_stop;
        ! Open the connection
        OpenConnection1;
        ! Set variables
        ControlIndex := 1;
        StatusIndex := 1;
        !DummyIndex := 1;
        NotClose := TRUE;
        ! Infinite loop
        WHILE NotClose DO
            ! Poll the socket for a string
            SocketReceive ClientSocket \Str := ReceivedString;
            ! Once string received, extract the instruction type
            ExtractType;
            ! If Set instruction, push message to Set queue
            IF Type = "C" THEN
                !SocketReceive ClientSocket \Str := ReceivedString;
                PushMessage("Control");
                !PushDummy;
            ! Else if Get instruction, push message to Get queue
            ELSEIF Type = "S" THEN
                PushMessage("Status");
            ELSEIF Type = "Pause" THEN
                StopMove;
!                StorePath;
            ELSEIF Type = "Start" THEN
!                RestoPath;
                StartMove;
            ! Else if Close instruction, close socket
            ELSEIF Type = "Close" THEN
                NotClose := FALSE;
            ENDIF
        ENDWHILE
        CloseConnection1;
        !----------------
        ! ERROR ROUTINES
        !----------------
        ERROR
            IF ERRNO=ERR_SOCK_TIMEOUT THEN
                RETRY;
            ELSEIF ERRNO=ERR_SOCK_CLOSED THEN
                CloseConnection1;
                OpenConnection1;
            ENDIF
            TRYNEXT;
    ENDPROC
    
    !---------------
    ! TRAP ROUTINES
    !---------------
    
    ! Input:   [None]
    ! Output:  [None]
    ! Comment: Triggers if ConStat cleared
    !          Reset conveyor and wait for ConStat input
    TRAP trap_move_stop
        SetDO DO10_3, 0;
        SetDO DO10_4, 0;
        WaitDI DI10_1, 1;
    ENDTRAP
    
    !-----------------
    ! SOCKET ROUTINES
    !-----------------
    
    ! Inputs:  [None]
    ! Outputs: [None]
    ! Comment: Open connection to client
    PROC OpenConnection1()
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
        ERROR
            IF ERRNO=ERR_SOCK_TIMEOUT THEN
                RETRY;
            ELSEIF ERRNO=ERR_SOCK_CLOSED THEN
                CloseConnection1;
                OpenConnection1;
            ENDIF
            TRYNEXT;
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
        Length := StrLen(ReceivedString);
        Position := StrFind(ReceivedString,1,STR_WHITE);
        Type := StrPart(ReceivedString,1,Position-1);
        Message := StrPart(ReceivedString,Position+1,Length-Position);
    ENDPROC

    !---------------------------------
    ! COMMUNICATION PROTOCOL ROUTINES
    !---------------------------------
    
    ! Inputs:  Character 'C' or 'S' for Control/Status
    ! Outputs: [None]
    ! Comment: Pushes Message to the Control/Status Module message queue
    PROC PushMessage(string Queue)
        IF Queue = "Control" AND ControlIndex < 10 THEN
            ! Add message to bottom of Control Message queue
            ControlQueue{ControlIndex} := Message;
	    ! Increment Status Messagequeue index
            ControlIndex := ControlIndex + 1;
        ELSEIF Queue = "Status" AND StatusIndex < 10 THEN
            ! Add message to bottom of Status Message queue
            StatusQueue{StatusIndex} := Message;
            ! Increment Status Message queue index
            StatusIndex := StatusIndex + 1;
        ENDIF
    ENDPROC
    
    !PROC PushDummy()
    !    IF DummyIndex<10 THEN
    !        DummyQueue{DummyIndex} := ReceivedString;
    !        DummyIndex := DummyIndex + 1;
    !    ENDIF
    !ENDPROC

!----------------------
! CHANGE LOG
!-----------------------
! Week 03 - Tyson Chan
!           <What you did>
! Week 03 - Faris Azhari
!           <What Faris Did>

! Week 04 - Tyson Chan
!           <What you did>
! Week 04 - Faris Azhari
!           <What Faris Did>

! Week 05 - Tyson Chan
!           <What you did>
! Week 05 - Faris Azhari
!           <What Faris Did>

! Week 06 - Tyson Chan
!           <What you did>
! Week 06 - Faris Azhari
!           <What Faris Did>
! Week 06 - Ankur Goel
!           Testing, added the correct IP to robot, Fixed looping bug - Works

! Week 07 - Tyson Chan
!           <What you did>
! Week 07 - Faris Azhari
!           <What Faris Did>
! Week 07 - Ankur Goel
!           Testing 

! Week 08 - Tyson Chan
!           <What you did>
! Week 08 - Faris Azhari
!           <What Faris Did>
! Week 08 - Ankur Goel
!           Testing, implemented multitasking - Works

! Week 09 - Tyson Chan
!           <What you did>
! Week 09 - Faris Azhari
!           <What Faris Did>
! Week 09 - Ankur Goel
!           Testing - Works

! Week 10 - Tyson Chan
!           <What you did>
! Week 10 - Faris Azhari
!           <What Faris Did>

ENDMODULE