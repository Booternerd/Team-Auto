MODULE Communication
	
    ! The socket connected to the client.
    VAR socketdev client_socket;
    
    ! The host and port that we will be listening for a connection on.
    CONST string host := "192.168.2.1";
    CONST num port := 1025;
    
    PROC MainCommunication()
        
        VAR string received_str;
        
        ListenForAndAcceptConnection;
            
        ! Receive a string from the client.
        SocketReceive client_socket \Str:=received_str;
            
        ! Send the string back to the client, adding a line feed character.
        SocketSend client_socket \Str:=(received_str + "\0A");
        
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