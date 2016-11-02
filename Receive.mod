MODULE Receive
    
    ! Persistent variable declaration
    PERS num ControlIndex;
    PERS num StatusIndex;
    PERS num DummyIndex;
    PERS string ControlQueue{10};
    !PERS string DummyQueue{10};
    PERS string StatusQueue{10};
    PERS bool NotClose;
    PERS bool Reachability;
    
    ! Variable declaration
    ! The host and port that we will be listening for a connection on.
    CONST string Host := "192.168.125.1";
!    CONST string Host := "127.0.0.1";   ! Virtual
    CONST num Port := 1050;
    
    ! The socket connected to the client.
    VAR socketdev ClientSocket;
    VAR string ReceivedString;
    VAR string Type;    
    VAR string Message;
    
    VAR intnum int_move_stop; 
    
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
        ERROR
            IF ERRNO=ERR_SOCK_TIMEOUT THEN
                RETRY;
            ELSEIF ERRNO=ERR_SOCK_CLOSED THEN
                CloseConnection1;
                OpenConnection1;
            ENDIF
            TRYNEXT;
    ENDPROC
    
    TRAP trap_move_stop
        SetDO DO10_3, 0;
        SetDO DO10_4, 0;
        WaitDI DI10_1, 1;
    ENDTRAP
    
    ! Open connection to client
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
    
    ! Close connection to client.
    PROC CloseConnection1()
        SocketClose ClientSocket;
    ENDPROC
        
    PROC ExtractType()
        VAR num Length; 
        VAR num Position;
        Length := StrLen(ReceivedString);
        Position := StrFind(ReceivedString,1,STR_WHITE);
        Type := StrPart(ReceivedString,1,Position-1);
        Message := StrPart(ReceivedString,Position+1,Length-Position);
    ENDPROC
    
    PROC PushMessage(string Queue)
        IF Queue = "Control" AND ControlIndex < 10 THEN
            ControlQueue{ControlIndex} := Message;
            ControlIndex := ControlIndex + 1;
        ELSEIF Queue = "Status" AND StatusIndex < 10 THEN
            StatusQueue{StatusIndex} := Message;
            StatusIndex := StatusIndex + 1;
        ENDIF
    ENDPROC
    
    !PROC PushDummy()
    !    IF DummyIndex<10 THEN
    !        DummyQueue{DummyIndex} := ReceivedString;
    !        DummyIndex := DummyIndex + 1;
    !    ENDIF
    !ENDPROC

ENDMODULE