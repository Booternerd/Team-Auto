function SampleGuiMain()

    

    mywindow = SampleGui();
    myhandles = guihandles(mywindow);
    set(myhandles.ExitButton,'UserData',0)
    process_time=0;
    
% %   robot_IP_address = '192.168.2.1';
    robot_IP_address = '127.0.0.1';
%     % The port that the robot will be listening on. This must be the same as in
%     % your RAPID program.
    robot_port = 1028;
%     % Open a TCP connection to the robot.
    socket = tcpip(robot_IP_address, robot_port);
    set(socket, 'ReadAsyncMode', 'continuous');
    fopen(socket);
%     % Check if the connection is valid.
    if(~isequal(get(socket, 'Status'), 'open'))
        warning(['Could not open TCP connection to ', robot_IP_address, ' on port ', robot_port]);
        return;
    else
        display('asb');
        return;
    end
    data = 0;
    while(1)
        pause(0.1-process_time);
        tic
        % The robot's IP address.


        % UNCOMMENT THESE LINES TO RECEIVE STRING FROM RAPID
%         % Read a line from the socket. Note the line feed appended to the message in the RADID sample code.
%         fwrite(socket, 'Hello world!');
        data = fgetl(socket);
        % Print the data that we got.
        fprintf(char(data));
        
        
        if(data=='Hello world!\0A')
            set(myhandles.ReceiveText, 'String', char(data));
            
        else
            set(myhandles.ReceiveText, 'String', 'nothing is received' );
        
        end
        
        set(myhandles.SocketStatus, 'String', 'inside');
        if(get(myhandles.ExitButton,'UserData')==1)
            set(myhandles.ExitButton,'UserData',0)

            break;
        end
        if(get(myhandles.SendString,'UserData')==1)
            set(myhandles.SendString,'UserData',0)
            display('im here, uncomment the line below when socket is connected')
            
            fwrite(socket, 'Hello world!');
        end
        process_time = toc;
        
    end
    set(myhandles.SocketStatus, 'String', 'outside');
    % Close the socket.
    fclose(socket);
end