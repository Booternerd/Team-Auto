function SampleGuiMain()

    

    mywindow = SampleGui();
    myhandles = guihandles(mywindow);
    set(myhandles.ExitButton,'UserData',0)
    process_time=0;
    SocketFlag=0; % 0 is not connected 1 is connected
    robot_port=0;
    robot_IP_address = '127.0.0.1';
    %     % The port that the robot will be listening on. This must be the same as in
    %     % your RAPID program.

    data = ' ';
    ReadFlag=0;
    set(myhandles.ReceiveText, 'String', 'nothing is received' );
    while(1)
        pause(0.1-process_time);
        tic
        % The robot's IP address.
        

        % UNCOMMENT THESE LINES TO RECEIVE STRING FROM RAPID
%         % Read a line from the socket. Note the line feed appended to the message in the RADID sample code.
%         fwrite(socket, 'Hello world!');
        if(SocketFlag==0)
            robot_port = str2double(get(myhandles.SocketNumberEditText,'String'));
            set(myhandles.SocketStatus, 'String', 'Flag=0');
            if(get(myhandles.ConnectSocketPushButton,'UserData')==1)
                set(myhandles.ConnectSocketPushButton,'UserData',0)
                % %   robot_IP_address = '192.168.2.1';
                % Open a TCP connection to the robot.
                socket = tcpip(robot_IP_address, robot_port);
                set(socket, 'ReadAsyncMode', 'continuous');
                fopen(socket);
                % Check if the connection is valid.
                if(~isequal(get(socket, 'Status'), 'open'))
                    warning(['Could not open TCP connection to ', robot_IP_address, ' on port ', robot_port]);
                    return;
                else
                    display('Socket is connected');
                end
                SocketFlag=1;
            end
            
        elseif(SocketFlag==1)
            % Socket is Connected

%             if(strcmp('Hello world!\0A',data)==1)
%                 set(myhandles.ReceiveText, 'String', char(data));
%             end

            set(myhandles.SocketStatus, 'String', 'Flag=1');
            

            if(get(myhandles.SendString,'UserData')==1)
                set(myhandles.SendString,'UserData',0)
                StringName=get(myhandles.SendStringEditText, 'String');
                fwrite(socket, StringName);
                ReadFlag=0;
%                 while(true)
%                         % Send a sample string to the server on the robot.
%                         fwrite(socket, 'Hello world!');
%                         % Read a line from the socket. Note the line feed appended to the message in the RADID sample code.
%                         data = fgetl(socket);
%                         % Print the data that we got.
%                         fprintf(char(data));
% 
%                         pause;
%                 end

            end
            if(ReadFlag==0)
                data = fgetl(socket);
                % Print the data that we got.
                fprintf(char(data));
                ReadFlag=1;
                set(myhandles.ReceiveText, 'String', char(data));
                if(strcmp(data,'close')==1)
                    disp('\n');
                    break;
                end  
            end

        end
        if(get(myhandles.ExitButton,'UserData')==1)
            set(myhandles.ExitButton,'UserData',0)

            break;
        end
        process_time = toc;
        
    end
    set(myhandles.SocketStatus, 'String', 'Socket Closed');
    % Close the socket.
    fclose(socket);
end