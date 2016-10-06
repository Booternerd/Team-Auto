MODULE Status
    
    ! Persistent variable declaration
    PERS num StatusIndex;
    PERS string StatusQueue{10};
    PERS bool NotClose;
    
    ! Variable declaration
    ! The host and port that we will be listening for a connection on.
    !CONST string Host := "192.168.2.1";
    CONST string Host := "127.0.0.1";   ! Virtual
    CONST num Port := 1031;
    
    ! The socket connected to the client.
    VAR socketdev ClientSocket;
    
    VAR string Message;
    VAR string Param{10};
    VAR num ParamVal{10};
    VAR pose Poses;
    VAR robjoint Joints;
    VAR dionum IO{4};
    VAR string SendString;
    
    VAR intnum int_move_stop; 
    
    PROC StatusMain()
        ! Open the connection
        OpenConnection2;
        CONNECT int_move_stop WITH trap_move_stop;
        ISignalDO DOP, 1, int_move_stop;
        NotClose := TRUE;
        WHILE NotClose DO
            WHILE StatusIndex > 1 DO
                PopMessage;
                IF Message = "GetAll" THEN
                    UpdateString("Pose");
                    SocketSend ClientSocket \Str:=SendString;
                    UpdateString("Angles");
                    SocketSend ClientSocket \Str:=SendString;
                    UpdateString("IO");
                    SocketSend ClientSocket \Str:=SendString;
                ELSEIF Message = "GetPose" THEN
                    UpdateString("Pose");
                    SocketSend ClientSocket \Str:=SendString;
                ELSEIF Message = "GetAngles" THEN
                    UpdateString("Angles");
                    SocketSend ClientSocket \Str:=SendString;
                ELSEIF Message = "GetIO" THEN    
                    UpdateString("IO");
                    SocketSend ClientSocket \Str:=SendString;
                ELSEIF Message = "GetStatus" THEN
                    UpdateString("Status");
                    SocketSend ClientSocket \Str:=SendString;
                ENDIF
            ENDWHILE
        ENDWHILE   
        CloseConnection2;
    ENDPROC
    
    TRAP trap_move_stop
        SetDO DO10_3, 0;
        SetDO DO10_4, 0;
        WaitDI DI10_1, 1;
    ENDTRAP
    
    ! Open connection to client
    PROC OpenConnection2()
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
    PROC CloseConnection2()
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
        RETURN DOutput(DO10_1); 
    ENDFUNC
    
    FUNC dionum GetVacSol()
        RETURN DOutput(DO10_2); 
    ENDFUNC
    
    FUNC dionum GetConRun()
        RETURN DOutput(DO10_3); 
    ENDFUNC
    
    FUNC dionum GetConDir()
        RETURN DOutput(DO10_4); 
    ENDFUNC
    
    PROC PopMessage()
        Message := StatusQueue{1};
        StatusIndex := StatusIndex-1;
        FOR i FROM 1 TO 9 DO
            StatusQueue{i} := StatusQueue{i+1};
        ENDFOR
    ENDPROC
    
    PROC UpdateString(string Status)
        !SendString := Message;
        IF Status = "Pose" THEN
            SendString := "1";
            Poses := GetPose();
            ParamVal{1} := Poses.trans.x;
            ParamVal{2} := Poses.trans.y;
            ParamVal{3} := Poses.trans.z;
            ParamVal{4} := Poses.rot.q1;
            ParamVal{5} := Poses.rot.q2;
            ParamVal{6} := Poses.rot.q3;
            ParamVal{7} := Poses.rot.q4;
            FOR i FROM 1 TO 7 DO
                Param{i} := ValtoStr(ParamVal{i});
                SendString := SendString+STR_WHITE+Param{i};
            ENDFOR
        ELSEIF Status = "Angles" THEN
            SendString := "2";
            Joints := GetAngles();
            ParamVal{1} := Joints.rax_1;
            ParamVal{2} := Joints.rax_2;
            ParamVal{3} := Joints.rax_3;
            ParamVal{4} := Joints.rax_4;
            ParamVal{5} := Joints.rax_5;
            ParamVal{6} := Joints.rax_6;
            FOR i FROM 1 TO 6 DO
                Param{i} := ValtoStr(ParamVal{i});
                SendString := SendString+STR_WHITE+Param{i};
            ENDFOR
        ELSEIF Status = "IO" THEN
            SendString := "3";
            ParamVal{1} := GetVacRun();
            ParamVal{2} := GetVacSol();
            ParamVal{3} := GetConRun();
            ParamVal{4} := GetConDir();
            ParamVal{5} := DI10_1;
            FOR i FROM 1 TO 4 DO
                Param{i} := ValtoStr(ParamVal{i});
                SendString := SendString+STR_WHITE+Param{i};
            ENDFOR
        ENDIF
        !error=reach,socketerror,estop,close
        SendString := SendString+"\0A";
    ENDPROC
    
ENDMODULE