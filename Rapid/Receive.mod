MODULE Receive
    
    ! Persistent variable declaration
    PERS num ControlIndex;
    PERS num StatusIndex;
    PERS string ControlQueue{10};
    PERS string StatusQueue{10};
    
    ! Variable declaration
    ! The host and port that we will be listening for a connection on.
    !CONST string Host := "192.168.2.1";
    CONST string Host := "127.0.0.1";   ! Virtual
    CONST num Port := 1025;
    
    ! The socket connected to the client.
    VAR socketdev ClientSocket;
    VAR string ReceivedString;
    VAR string Type;    
    
    ! Main function
    PROC ReceiveMain()
        ! Open the connection
        OpenConnection1;
        ! Set variables
        ControlIndex := 1;
        StatusIndex := 1;
        ! Infinite loop
        WHILE TRUE DO
            ! Poll the socket for a string
            SocketReceive ClientSocket \Str := ReceivedString;
            ! Once string received, extract the instruction type
            ExtractType;
            ! If Set instruction, push message to Set queue
            IF Type = "Control" THEN
                PushMessage("Control");
            ! Else if Get instruction, push message to Get queue
            ELSEIF Type = "Status" THEN
                PushMessage("Status");
            ELSEIF Type = "Pause" THEN
                StopMove;
            ELSEIF Type = "Start" THEN
                StartMove;
            ! Else if Close instruction, close socket
            ELSEIF Type = "Close" THEN
                CloseConnection1;
                ! Close all connections
            ENDIF
        ENDWHILE
    ENDPROC
    
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
    ENDPROC
    
    PROC PushMessage(string Queue)
        IF Queue = "Control" THEN
            ControlQueue{ControlIndex} := ReceivedString;
            ControlIndex := ControlIndex + 1;
        ELSEIF Queue = "Status" THEN
            StatusQueue{StatusIndex} := ReceivedString;
            StatusIndex := StatusIndex + 1;
        ENDIF
    ENDPROC

ENDMODULE