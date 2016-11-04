function SampleGuiMain()
    %MoveJointsAngle(123,123)
    %DI10_1 conveyor stats
    %D010_1 Vacuum
    %D010_2 Solenoid
    %D010_3 Conveyor on/off
    %D010_4 Conveyor Direction
    

    % CHANGE SPEED
    % KEYBOARD INPUT
    % IO STATUS
    % vacrun,vacsuck,conrun,condir,joint1-6, xyz, orientation;
    
    mywindow = SampleGui();

    myhandles = guihandles(mywindow);

    myhandles.videofeed = 0;

    set(myhandles.ExitButton,'UserData',0)
    checklist = 'GUI_checklist.m';
%-------------------------------------------------------------------------
    run(checklist);
%-------------------------------------------------------------------------
    process_time=0;
    SocketFlag=0; % 0 is not connected 1 is connected
    robot_port=0;
    robot_IP_address = '127.0.0.1';
    %     % The port that the robot will be listening on. This must be the same as in
    %     % your RAPID program.
    
    data = ' ';
    ReadFlag=0;
    GetStatusFlag=1;
    set(myhandles.ReceiveText, 'String', 'nothing is received' );
    global context;
    context.q1=0;
    context.q2=0;
    context.q3=0;
    context.q4=0;
    context.q5=0;
    context.q6=0;
    context.px=0;
    context.py=0;
    context.pz=0;
    context.qu1=0;
    context.qu2=0;
    context.qu3=-1;
    context.qu4=0;
    context.vacrun=0;
    context.vacsuck=0;
    context.conrun=0;
    context.condir=0;
    
    % initialise coordinate variable (Click and Go)
    coordinates = [];
    Px = [];
    Py = [];
    Pz = [];
    
    % Deleting all previous files from previous runs if any. (Click and Go)
    if exist('output_files/coordinates.txt')
        delete('output_files/coordinates.txt');
    end;
    
    if exist('output_files/i1pressed.txt')
        delete('output_files/i1pressed.txt');
    end;
    
    if exist('output_files/i2pressed.txt')
        delete('output_files/i2pressed.txt');
    end;
    
    while(1)
        pause(0.1-process_time);
        tic


        % Receiving Socket Number, before any command could be pushed
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
            set(myhandles.ExitButton,'Visible','on');
            set(myhandles.SocketStatus, 'String', 'Flag=1');
            
            % if there are click and go coordinates selected and saved 
            % under '/output_files/coordinates.txt'
            
                    % testing area 
            
            if(exist('output_files/i1pressed.txt') & ReadFlag==0)
                    delete('output_files/i1pressed.txt');


                    if exist('output_files/coordinates.txt')
                        fileID = fopen('output_files/coordinates.txt','r');
                        formatSpec = '%f';

                        coordinates = fscanf(fileID, formatSpec);
                        fclose(fileID);
                        Px = coordinates(1);
                        Py = coordinates(2);

                        % if coordinates are within the tables range Pz is 10cm
                        % above table, if the coordinates are within the conveyer
                        % range Pz is 10cm above the conveyer
                        Pz = checkPz(Px,Py,1);

                        delete('output_files/coordinates.txt');
                    end;

                    % switch coordinates for actual robot frame
                    [Px,Py] = getP(Px,Py);
                    tempX = Px;
                    tempY = Py;
                    Px = tempY;
                    Py = tempX;
                    Pz;

                    v=get(myhandles.SetSpeedPopUp,'Value');
                    %StringName=sprintf('MoveJoints %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,context.qu1,context.qu2,context.qu3,context.qu4,v);
                    %fwrite(socket, StringName);

                    fprintf('MoveJoints %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,context.qu1,context.qu2,context.qu3,context.qu4,v);

                    ReadFlag=1;
                    GetStatusFlag=0;
            end  

            if(exist('output_files/i2pressed.txt') & ReadFlag==0)
                    delete('output_files/i2pressed.txt');


                    if exist('output_files/coordinates.txt')
                        fileID = fopen('output_files/coordinates.txt','r');
                        formatSpec = '%f';

                        coordinates = fscanf(fileID, formatSpec);
                        fclose(fileID);
                        Px = coordinates(1);
                        Py = coordinates(2);

                        % if coordinates are within the tables range Pz is 10cm
                        % above table, if the coordinates are within the conveyer
                        % range Pz is 10cm above the conveyer
                        Pz = checkPz(Px,Py,2);

                        delete('output_files/coordinates.txt');
                    end;

                    [Px,Py] = getP2(Px,Py,Pz)
                    tempX = Px;
                    tempY = Py;
                    Px = tempY;
                    Py = tempX;
                    Pz

                    v=get(myhandles.SetSpeedPopUp,'Value');
                    %StringName=sprintf('MoveJoints %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,context.qu1,context.qu2,context.qu3,context.qu4,v);
                    %fwrite(socket, StringName);

                    fprintf('MoveJoints %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,context.qu1,context.qu2,context.qu3,context.qu4,v);

                    ReadFlag=1;
                    GetStatusFlag=0;
            end  

            
            if(get(myhandles.SendString,'UserData')==1 && ReadFlag==0)
                set(myhandles.SendString,'UserData',0)
                StringName=get(myhandles.SendStringEditText, 'String');
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %MOVE JOINTS ANGLE
            if((get(myhandles.SendPoseJPushButton,'UserData')==1) && ReadFlag==0)
                set(myhandles.SendPoseJPushButton,'UserData',0)
                q1=str2double(get(myhandles.Q1Text, 'String'));%Q1Text
                q2=str2double(get(myhandles.Q2Text, 'String'));
                q3=str2double(get(myhandles.Q3Text, 'String'));
                q4=str2double(get(myhandles.Q4Text, 'String'));
                q5=str2double(get(myhandles.Q5Text, 'String'));
                q6=str2double(get(myhandles.Q6Text, 'String'));
                v=get(myhandles.SetSpeedPopUp,'Value');
                StringName=sprintf('MoveJointsAngle %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            % MOVE POSE CIRCULAR
            if((get(myhandles.SendPoseLBPushButton,'UserData')==1) && ReadFlag==0)
                set(myhandles.SendPoseLBPushButton,'UserData',0)
                Px=str2double(get(myhandles.PxText, 'String'));%Q1Text
                Py=str2double(get(myhandles.PyText, 'String'));
                Pz=str2double(get(myhandles.PzText, 'String'));
                Qu1=str2double(get(myhandles.Qu1Text, 'String'));
                Qu2=str2double(get(myhandles.Qu2Text, 'String'));
                Qu3=str2double(get(myhandles.Qu3Text, 'String'));
                Qu4=str2double(get(myhandles.Qu4Text, 'String'));
                v=get(myhandles.SetSpeedPopUp,'Value');
                StringName=sprintf('MoveJoints %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,Qu1,Qu2,Qu3,Qu4,v);
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            % MOVE POSE LINEAR
            if((get(myhandles.SendPoseLAPushButton,'UserData')==1) && ReadFlag==0)
                set(myhandles.SendPoseLAPushButton,'UserData',0)
                Px=str2double(get(myhandles.PxText, 'String'));%Q1Text
                Py=str2double(get(myhandles.PyText, 'String'));
                Pz=str2double(get(myhandles.PzText, 'String'));
                Qu1=str2double(get(myhandles.Qu1Text, 'String'));
                Qu2=str2double(get(myhandles.Qu2Text, 'String'));
                Qu3=str2double(get(myhandles.Qu3Text, 'String'));
                Qu4=str2double(get(myhandles.Qu4Text, 'String'));
                v=get(myhandles.SetSpeedPopUp,'Value');
                StringName=sprintf('MoveLinear %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,Qu1,Qu2,Qu3,Qu4,v);
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %%
            %MANUAL JOGGING
            %CARTESIAN END EFFECTOR
            % x+
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
%                 StringName='x+';
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.px+(0.1*v);
                StringName=sprintf('MoveLinear %.2f %.2f %.2f %.2f %.2f %.2f %.2f, %d',d,context.py,context.pz,context.qu1,context.qu2,context.qu3,context.qu4,5);

                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            % x-
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
%                 StringName='x-';
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.px-(0.1*v);
                StringName=sprintf('MoveLinear %.2f %.2f %.2f %.2f %.2f %.2f %.2f, %d',d,context.py,context.pz,context.qu1,context.qu2,context.qu3,context.qu4,5);

                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            % y+
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'a')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
%                 StringName='y+';
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.py+(0.1*v);
                StringName=sprintf('MoveLinear %.2f %.2f %.2f %.2f %.2f %.2f %.2f, %d',context.px,d,context.pz,context.qu1,context.qu2,context.qu3,context.qu4,5);

                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            % y-
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'d')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
%                 StringName='y-';
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.py-(0.1*v);
                StringName=sprintf('MoveLinear %.2f %.2f %.2f %.2f %.2f %.2f %.2f, %d',context.px,d,context.pz,context.qu1,context.qu2,context.qu3,context.qu4,5);

                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            % z+
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'q')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
%                 StringName='z+';
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.pz+(0.1*v);
                StringName=sprintf('MoveLinear %.2f %.2f %.2f %.2f %.2f %.2f %.2f, %d',context.px,context.py,d,context.qu1,context.qu2,context.qu3,context.qu4,5);

                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            % z-
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'e')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
%                 StringName='z-';
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.pz-(0.1*v);
                StringName=sprintf('MoveLinear %.2f %.2f %.2f %.2f %.2f %.2f %.2f, %d',context.px,context.py,d,context.qu1,context.qu2,context.qu3,context.qu4,5);

                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %JOINT ANGLES JOGGING
            %Q1
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J1RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q1+(0.2*v);
                StringName=sprintf('MoveJointsAngle %.2f %.2f %.2f %.2f %.2f %.2f %.2f',d,context.q2,context.q3,context.q4,context.q5,context.q6,5);
%                 StringName='q1+';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J1RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q1-(0.2*v);
                StringName=sprintf('MoveJointsAngle %.2f %.2f %.2f %.2f %.2f %.2f %.2f',d,context.q2,context.q3,context.q4,context.q5,context.q6,5);
%                 StringName='q1-';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %Q2
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J2RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q2+(0.2*v);
                StringName=sprintf('MoveJointsAngle %.2f %.2f %.2f %.2f %.2f %.2f %.2f',context.q1,d,context.q3,context.q4,context.q5,context.q6,5);
%                 StringName='q2+';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J2RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q2-(0.2*v);
                StringName=sprintf('MoveJointsAngle %.2f %.2f %.2f %.2f %.2f %.2f %.2f',context.q1,d,context.q3,context.q4,context.q5,context.q6,5);
%                 StringName='q2-';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %Q3
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J3RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q3+(0.2*v);
                StringName=sprintf('MoveJointsAngle %.2f %.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,d,context.q4,context.q5,context.q6,5);
%                 StringName='q3+';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J3RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q3-(0.2*v);
                StringName=sprintf('MoveJointsAngle %.2f %.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,d,context.q4,context.q5,context.q6,5);
%                 StringName='q3-';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %Q4
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J4RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q4+(0.2*v);
                StringName=sprintf('MoveJointsAngle %.2f %.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,context.q3,d,context.q5,context.q6,5);
%                 StringName='q4+';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J4RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q4-(0.2*v);
                StringName=sprintf('MoveJointsAngle %.2f %.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,context.q3,d,context.q5,context.q6,5);
%                 StringName='q1-';
%                 StringName='q4-';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %Q5
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J5RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q5+(0.2*v);
                StringName=sprintf('MoveJointsAngle %.2f %.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,context.q3,context.q4,d,context.q6,5);
%                 StringName='q5+';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J5RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q5-(0.2*v);
                StringName=sprintf('MoveJointsAngle %.2f %.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,context.q3,context.q4,d,context.q6,5);
%                 StringName='q5-';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %Q6
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J6RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q6+(0.2*v);
                StringName=sprintf('MoveJointsAngle %.2f %.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,context.q3,context.q4,context.q5,d,5);
%                 StringName='q6+';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J6RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q6-(0.2*v);
                StringName=sprintf('MoveJointsAngle %.2f %.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,context.q3,context.q4,context.q5,d,5);
%                 StringName='q6-';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %% Control Input/output
%               ConveyorRadioButton
%               SolenoidRadioButton
%               VacuumRadioButton
%               ConveyorDirectionPushButton
%             conveyor off
            if(get(myhandles.ConveyorRadioButton,'UserData')==0 && ReadFlag==0)
                set(myhandles.ConveyorRadioButton,'UserData',3)
                StringName='SetConRun 0';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
%             conveyor on
            if(get(myhandles.ConveyorRadioButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.ConveyorRadioButton,'UserData',3)
                StringName='SetConRun 1';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
%             Vacuum off
            if(get(myhandles.VacuumRadioButton,'UserData')==0 && ReadFlag==0)
                set(myhandles.VacuumRadioButton,'UserData',3)
                StringName='SetVacRun 0';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
%             Vacuum on
            if(get(myhandles.VacuumRadioButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.VacuumRadioButton,'UserData',3)
                StringName='SetVacRun 1';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
%             Solenoid off
            if(get(myhandles.SolenoidRadioButton,'UserData')==0 && ReadFlag==0)
                set(myhandles.SolenoidRadioButton,'UserData',3)
                StringName='SetVacSuck 0';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
%             Solenoid on
            if(get(myhandles.SolenoidRadioButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.SolenoidRadioButton,'UserData',3)
                StringName='SetVacSuck 1';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
%             Conveyor Direction.
            if(get(myhandles.ConveyorDirectionPushButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.ConveyorDirectionPushButton,'UserData',0)
                if(get(myhandles.ConveyorDirectionText,'String')==0)
                    set(myhandles.ConveyorDirectionText,'String',1)
                    StringName='SetConDir 1';
                else
                    set(myhandles.ConveyorDirectionText,'String',0)
                    StringName='SetConDir 0';
                end
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %% Close
            %%
            if(get(myhandles.ExitButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.ExitButton,'UserData',0)
                StringName='CloseConnection';
                fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %% Get Status
            if(GetStatusFlag==1 && ReadFlag ==0)
                StringName='GetStatus';
                fwrite(socket, StringName);
                ReadFlag=1;
            end
            %%
            %READ OUTPUT FROM RAPID
            %print command
            if(ReadFlag==1 && GetStatusFlag==0)
                data = fgetl(socket);
                % Print the data that we got.
                fprintf(char(data));
                ReadFlag=0;
                set(myhandles.ReceiveText, 'String', char(data));
                fprintf('\n');
                if(strcmp(data,'CloseConnection')==1)
                    set(myhandles.SocketStatus, 'String', 'Socket Closed');
                    break;
                end  
                GetStatusFlag=1;
            elseif(ReadFlag==1 && GetStatusFlag==1)
                data = fgetl(socket);
%                 fprintf(char(data));
                decodestring_q(data);
                string_q=sprintf('q1=%.2f,q2=%.2f,q3=%.2f,q4=%.2f,q5=%.2f,q6=%.2f',context.q1,context.q2,context.q3,context.q4,context.q5,context.q6);
                set(myhandles.JointStatusText, 'String', string_q);
                ReadFlag=0;
            end

        end
        process_time = toc;
    end
    
    % Close the socket.
    fclose(socket);
end

function decodestring_q(s)
    global context;
    if( isempty(s)~=1)
        c =cell2mat(textscan(s,'%f'));
        context.q1=c(2);
        context.q2=c(3);
        context.q3=c(4);
        context.q4=c(5);
        context.q5=c(6);
        context.q6=c(7);
    end
end
function decodestring_p(s)
    global context;
    c =cell2mat(textscan(s,'%f'));
    context.px=c(2);
    context.py=c(3);
    context.pz=c(4);
    context.qu1=c(5);
    context.qu2=c(6);
    context.qu3=c(7);
    context.qu4=c(8);
end
function decodestring_io(s)
    global context;
    c =cell2mat(textscan(s,'%f'));
    context.vacrun=c(2);
    context.vacsuck=c(3);
    context.conrun=c(4);
    context.condir=c(5);
end
function decodestring_oth(s)
    global context;
    c =cell2mat(textscan(s,'%f'));
    context.reachability=c(2);
end
function r=IO_error_check(myhandles)
    global context;
%     context.vacrun=0;
%     context.vacsuck=0;
%     context.conrun=0;
%     context.condir=0;
    r=0;
    if(context.vacrun ~= get(myhandles.VacuumRadioButton,'Value'))
        r=1;
    end
    if(context.vacsuck ~= get(myhandles.SolenoidRadioButton,'Value'))
        r=1;
    end
    if(context.conrun ~= get(myhandles.ConveyorRadioButton,'Value'))
        r=1;
    end
    if(context.condir ~= get(myhandles.ConveyorDirectionText,'String'))
        r=1;
    end
end
