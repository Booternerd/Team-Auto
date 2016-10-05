MODULE Status
    
    ! Persistent variable declaration
    PERS num StatusIndex;
    PERS string StatusQueue{10};
    
    ! Variable declaration
    ! The host and port that we will be listening for a connection on.
    !CONST string Host := "192.168.2.1";
    CONST string Host := "127.0.0.1";   ! Virtual
    CONST num Port := 1026;
    
    ! The socket connected to the client.
    VAR socketdev ClientSocket;
    
    VAR string Message;
    VAR string Param{10};
    VAR dionum IO{4};
    VAR string SendString;
    
    PROC StatusMain()
        ! Open the connection
        !OpenConnection;
        StatusQueue{1} := "GetIO";
        StatusIndex := 2;
        WHILE TRUE DO
            WHILE StatusIndex > 1 DO
                PopMessage;
                IF Message = "GetAll" THEN
                    
                ELSEIF Message = "GetAngles" THEN
                    
                ELSEIF Message = "GetPose" THEN
                    
                ELSEIF Message = "GetIO" THEN    
                    IO{1} := GetVacRun();
                    IO{2} := GetVacSol();
                    IO{3} := GetConRun();
                    IO{4} := GetConDir();
                    FOR i FROM 1 TO 4 DO
                        Param{i} := ValtoStr(IO{i});
                    ENDFOR
                    SendString := (Message+STR_WHITE+Param{1}+STR_WHITE+Param{2}+STR_WHITE+Param{3}+STR_WHITE+Param{4}+"\0A");
                ELSEIF Message = "GetStatus" THEN
                    
                ELSEIF Message = "Close" THEN
                    CloseConnection;
                ENDIF
            ENDWHILE
        ENDWHILE        
    ENDPROC
    
    ! Open connection to client
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
    
    ! Close connection to client.
    PROC CloseConnection()
        SocketClose ClientSocket;
    ENDPROC
    
    FUNC pose GetPose()
        ! Return: current pose of end effector 
        ! usage : VAR pose rPos := get_Pose();
        !       : rPos.trans~give pos in mm
        !       : rpos.rot~orientation in quaternion
        VAR robtarget rb;
        rb := CRobT(\Tool:=tsCup);
        RETURN [rb.trans, rb.rot]; 
    ENDFUNC
    
    FUNC robjoint GetAngles()
        ! Return: current angle of all joints in degrees 
        ! usage : VAR robjoint rAng := get_Angles();
        VAR jointtarget rb;
        rb := CJointT();
        RETURN rb.robax; 
    ENDFUNC
    
    FUNC dionum GetVacRun()
        RETURN DO10_1; 
    ENDFUNC
    
    FUNC dionum GetVacSol()
        RETURN DO10_2; 
    ENDFUNC
    
    FUNC dionum GetConRun()
        RETURN DO10_3; 
    ENDFUNC
    
    FUNC dionum GetConDir()
        RETURN DO10_4; 
    ENDFUNC
    
    PROC PopMessage()
        Message := StatusQueue{1};
        StatusIndex := StatusIndex-1;
        FOR i FROM 1 TO 9 DO
            StatusQueue{i} := StatusQueue{i+1};
        ENDFOR
    ENDPROC
    
ENDMODULE