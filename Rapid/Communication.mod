MODULE Communication
	
    ! The socket connected to the client.
    VAR socketdev client_socket;
    
    ! The host and port that we will be listening for a connection on.
    !CONST string host := "192.168.2.1";
    CONST string host := "127.0.0.1";   ! Virtual
    CONST num port := 1025;
    
    PROC MainCommunication()
        
        VAR string received_str;
        VAR bool keep_listening := TRUE;
        
        ! Open socket
        ListenForAndAcceptConnection;
        
        ! While true loop to poll strings from Matlab.
        WHILE keep_listening DO
            
            ! Receive a string from the client.
            SocketReceive client_socket \Str:=received_str;
            
            TEST received_str
            CASE "Kelvin":
                SocketSend client_socket \Str:=("Kelvin is the Project Manager.\0A");
            CASE "Jeffry":
                SocketSend client_socket \Str:=("Jeffry is the Matlab Lead.\0A");
            CASE "Tyson":
                SocketSend client_socket \Str:=("Tyson is the Rapid Lead.\0A");
            CASE "Ankur":
                SocketSend client_socket \Str:=("Ankur is a Software Developer.\0A");
            CASE "Eugene":
                SocketSend client_socket \Str:=("Eugene is a Software Developer.\0A");
            CASE "Faris":
                SocketSend client_socket \Str:=("Faris is a Software Developer.\0A");               
            DEFAULT:
                ! Send the string back to the client, adding a line feed character.
                SocketSend client_socket \Str:=(received_str + "\0A");
            ENDTEST
            
            ! Clear received_str.
            received_str := "";
            
        ENDWHILE
        
        ! Close socket
        CloseConnection;
		
    ENDPROC

    PROC ListenForAndAcceptConnection()
        
        ! Create the socket to listen for a connection on.
        VAR socketdev welcome_socket;
        SocketCreate welcome_socket;
        
        ! Bind the socket to the host and port.
        SocketBind welcome_socket, host, port;
        
        ! Listen on the welcome socket.
        SocketListen welcome_socket;
        
        ! Accept a connection on the host and port.
        SocketAccept welcome_socket, client_socket;
        
        ! Close the welcome socket, as it is no longer needed.
        SocketClose welcome_socket;
        
    ENDPROC
    
    ! Close the connection to the client.
    PROC CloseConnection()
        SocketClose client_socket;
    ENDPROC
		
ENDMODULE