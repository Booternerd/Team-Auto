MODULE Communication
    
    ! The socket connected to the client.
    VAR socketdev ClientSocket;
    ! The host and port that we will be listening for a connection on.
    !CONST string Host := "192.168.125.1";
    CONST string Host := "127.0.0.1";   ! Virtual
    CONST num Port := 1025;
    
    PERS string Command;
    PERS num Param{17};
    PERS num NumParams;
    PERS bool UpdateFlag;
    PERS bool ControlFlag;
    PERS bool StatusFlag;
    
    VAR string StringIn;
    VAR String StringOut;
    VAR string ParamString{17};
    
    PROC MainCommunication()
        OpenConnection;
        WHILE TRUE DO
            StringOut := "";
            ! Receive a string from the client.
            SocketReceive ClientSocket \Str := StringIn;
            DecodeString;
            TEST Command
            CASE "GetStatus":
                IF NumParams = 0 THEN
                    UpdateFlag := FALSE;
                    StatusFlag := TRUE;
                    ! Waiting while loop
                    WHILE UpdateFlag = FALSE DO
                    ENDWHILE
                    CodeString;
                    SocketSend ClientSocket \Str := (StringOut+"\0A");
                ELSE
                    SocketSend ClientSocket \Str := ("Error: Incorrect Number of Parameters\0A");
                ENDIF
            CASE "MoveJointsAngle":
                CheckNumParams(7);
            CASE "MoveJoints":
                CheckNumParams(8);
            CASE "MoveLinear":
                CheckNumParams(8);
            CASE "SetVacRun":
                CheckNumParams(1);
            CASE "SetVacSuck":
                CheckNumParams(1);
            CASE "SetConRun":
                CheckNumParams(1);
            CASE "SetConDir":
                CheckNumParams(1);
            CASE "CloseConnection":
                SocketSend ClientSocket \Str := (Command+"\0A");
                CloseConnection;
            DEFAULT:
                SocketSend ClientSocket \Str := ("Error: Command Not Recognized\0A");
            ENDTEST
            
        ENDWHILE
    ENDPROC

    PROC OpenConnection()
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
    
    ! Close the connection to the client.
    PROC CloseConnection()
        SocketClose ClientSocket;        
    ENDPROC

    PROC DecodeString()
        VAR num StringLen; 
        VAR num SpacePos;
        VAR string ExtractedString; 
        VAR string RemainingString; 
        VAR bool KeepDecoding;
        VAR bool Temp;
        ! Reset parameter count to 0
        NumParams := 0;
        RemainingString := StringIn;
        ! Loop until no more white space found
        KeepDecoding := TRUE;
        WHILE KeepDecoding DO
            StringLen := StrLen(RemainingString);
            SpacePos := StrFind(RemainingString,1,STR_WHITE);
            ! Update ExtractedString and RemainingString
            IF SpacePos = StringLen+1 THEN
                ExtractedString := RemainingString;          
                IF NumParams = 0 THEN
                    Command := ExtractedString;
                ELSE
                    ParamString{NumParams} := ExtractedString;
                ENDIF
                KeepDecoding := FALSE;
            ELSE
                ExtractedString := StrPart(RemainingString,1,SpacePos-1);
                IF NumParams = 0 THEN
                    Command := ExtractedString;
                ELSE
                    ParamString{NumParams} := ExtractedString;
                ENDIF
                RemainingString := StrPart(RemainingString,SpacePos+1,StringLen-SpacePos);
                NumParams := NumParams+1;
            ENDIF    
        ENDWHILE
        ! Convert String to Value for parameters
        IF NumParams <> 0 THEN
            FOR i FROM 1 TO NumParams DO
                Temp := StrtoVal(ParamString{i},Param{i});
            ENDFOR
        ENDIF
    ENDPROC
    
    PROC CodeString()
        StringOut := "GetStatus";
        ! Convert Value to String for parameters
        IF NumParams <> 0 THEN
            FOR i FROM 1 TO NumParams DO
                ParamString{i} := ValtoStr(Param{i});
                StringOut := StringOut+STR_WHITE+ParamString{i};
            ENDFOR
        ENDIF
    ENDPROC   
    
    PROC CheckNumParams(num Value)
        IF NumParams = Value THEN
            ControlFlag := TRUE;
            SocketSend ClientSocket \Str := (Command+"\0A");
        ELSE
            SocketSend ClientSocket \Str := ("Error: Incorrect Number of Parameters\0A");
        ENDIF
    ENDPROC

ENDMODULE