% Team-Auto
% 10/7/2016
% this is the main file that includes all the functionality of the GUI



function FinalMain()
    
    mywindow = FinalGui();
    myhandles = guihandles(mywindow);
    
    checklist = 'GUI_checklist.m';
%     run(checklist);
    
    set(myhandles.ExitButton,'UserData',0)
    process_time=0;
    SocketFlag=0; % 0 is not connected 1 is connected
    robot_port=0;
%     robot_IP_address = '127.0.0.1';
      robot_IP_address = '192.168.125.1';

    data = ' ';
    ReadFlag=0;
    GetStatusFlag=1;
    global context;
    context.command=[];
    context.command{10,1}=[];
    context.q1=0;
    context.q2=0;
    context.q3=0;
    context.q4=0;
    context.q5=0;
    context.q6=0;
    context.px=300;
    context.py=0;
    context.pz=200;
    context.qu1=0;
    context.qu2=0;
    context.qu3=-1;
    context.qu4=0;
    context.vacrun=0;
    context.vacsol=0;
    context.constat=0;
    context.conrun=0;
    context.condir=0;
    
    context.reachability=1;
    context.singularity=1;
%     context.movement=0;

    % run('D:\robot-9.10\rvctools\startup_rvc.m')
%     L(1) = Link([0 0.29  0    pi/2 ]); L(1).offset = pi;
%     L(2) = Link([0 0     0.27 0    ]); L(2).offset = pi/2;
%     L(3) = Link([0 0     0.07 -pi/2]);
%     L(4) = Link([0 0.302 0    pi/2 ]); 
%     L(5) = Link([0 0     0    pi/2 ]); L(5).offset = pi;
%     L(6) = Link([0 0.137 0    0    ]);
% 
%     irb_120 = SerialLink(L, 'name', 'irb 120');
    
    % initialise coordinate variable (Click and Go)
%     coordinates = [];
    Px = [];
    Py = [];
    Pz = [];
    flag = 0;
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
    if exist('output_files/reachable.txt')
        delete('output_files/reachable.txt');
    end;
    
    while(1)
        pause(0.1-process_time);
%         tic
        % Receiving Socket Number, before any command could be pushed
        if(SocketFlag==0)
            set(myhandles.SocketStatus, 'String', 'Not Connected');
            robot_port = str2double(get(myhandles.SocketNumberEditText,'String'));
            robot_port2= str2double(get(myhandles.SocketNumber2,'String'));
%             set(myhandles.SocketStatus, 'String', '');
            if(get(myhandles.ConnectSocketPushButton,'UserData')==1)
                set(myhandles.ConnectSocketPushButton,'UserData',0)
                set(myhandles.WarningText,'String',' ');
                % Open a TCP connection to the robot.
                socket = tcpip(robot_IP_address, robot_port);
                set(socket, 'ReadAsyncMode', 'continuous');
                fopen(socket);
                % Check if the connection is valid.
                if(~isequal(get(socket, 'Status'), 'open'))
                    warning(['Could not open TCP connection to ', robot_IP_address, ' on port ', robot_port]);
                    return;
                else
                    display('Socket1 is connected');
                end
                
                
                socket2 = tcpip(robot_IP_address, robot_port2);
                set(socket2, 'ReadAsyncMode', 'continuous');
                fopen(socket2);
                % Check if the connection is valid.
                if(~isequal(get(socket2, 'Status'), 'open'))
                    warning(['Could not open TCP connection to ', robot_IP_address, ' on port ', robot_port2]);
                    return;
                else
                    display('Socket2 is connected');
                end
                
                
                SocketFlag=1;
            end
            
        elseif(SocketFlag==1)
            % Socket is Connected

            set(myhandles.ExitButton,'Visible','on');
            set(myhandles.SocketStatus, 'String', 'Connected');
            
            %CLICK AND GO
            if exist('output_files/reachable.txt')
                fileID = fopen('output_files/reachable.txt','r');
                formatSpec = '%d';
                reachable = fscanf(fileID, formatSpec);
                fclose(fileID);
                if reachable == 0
                    set(myhandles.WarningText,'String','Warning: not reachable');
                    set(myhandles.ReachabilityStatusText,'String','No');
                else
                    set(myhandles.WarningText,'String',' ');
                end;
                delete('output_files/reachable.txt');
            end;
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
                
                pause(0.02)
                StringName=sprintf('C MJ %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,context.qu1,context.qu2,context.qu3,context.qu4,v);
                fwrite(socket, StringName);
%                 pause(0.02)
%                 StringName=sprintf('%.2f',Px);
%                 fwrite(socket, StringName);
                set(myhandles.ReachabilityStatusText,'String','Yes');
                SN=sprintf('Point and Click to x=%.2f,y=%.2f',Px,Py);
                PushCommand(SN)
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

                    [Px,Py] = getP2(Px,Py,Pz);
                    tempX = Px;
                    tempY = Py;
                    Px = tempY;
                    Py = tempX;
                    

                    v=get(myhandles.SetSpeedPopUp,'Value');
                    pause(0.02);
                    StringName=sprintf('C MJ %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,context.qu1,context.qu2,context.qu3,context.qu4,v);
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('%.2f',Px);
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    SN=sprintf('Point and Click to x=%.2f,y=%.2f',Px,Py);
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                    
            end  
            
            %MOVE JOINTS ANGLE
            if((get(myhandles.SendPoseJPushButton,'UserData')==1) && ReadFlag==0)
                set(myhandles.SendPoseJPushButton,'UserData',0)
                q1=str2double(get(myhandles.Q1Text, 'String'));%Q1Text
                q1=mod(q1+180, 360)-180;
                q2=str2double(get(myhandles.Q2Text, 'String'));
                q2=mod(q2+180, 360)-180;
                q3=str2double(get(myhandles.Q3Text, 'String'));
                q3=mod(q3+180, 360)-180;
                q4=str2double(get(myhandles.Q4Text, 'String'));
                q4=mod(q4+180, 360)-180;
                q5=str2double(get(myhandles.Q5Text, 'String'));
                q5=mod(q5+180, 360)-180;
                q6=str2double(get(myhandles.Q6Text, 'String'));
                v=get(myhandles.SetSpeedPopUp,'Value');
%                 pa
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'string','Warning: Joints are Out of Range')
                else
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('%.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6);
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Move to the specified joint angles');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
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
                if(Quarternion_check(Qu1,Qu2,Qu3,Qu4)==1)
                    set(myhandles.WarningText,'String','Warning: Quarternion is incorrect');
                else
                    v=get(myhandles.SetSpeedPopUp,'Value');
%                 q = Quaternion([Qu1 Qu2 Qu3 Qu4]); t = [Px/1000; Py/1000; Pz/1000];
%                 pos = rt2tr(q.R, t);
%                 [qi,fa,~] = irb_120.ikine(pos, 'pinv');
%                 if(fa==1)
%                     display('Warning: Movement is not reachable')
%                     set(myhandles.WarningText,'String','Warning: Movement is not reachable')
%                     set(myhandles.ReachabilityStatusText,'String','No');
%                 else
%                     m=irb_120.maniplty(qi,'all');
%                     if(m<0.02)
%                         display('Warning: Robot is near singularity')
%                         set(myhandles.WarningText,'string','Warning: Robot is near singularity')
%                     else
%                         q1=qi(1)*180/pi;
%                         q1=mod(q1+180, 360)-180;
%                         q2=qi(2)*180/pi;
%                         q2=mod(q2+180, 360)-180;
%                         q3=qi(3)*180/pi;
%                         q3=mod(q3+180, 360)-180;
%                         q4=qi(4)*180/pi;
%                         q4=mod(q4+180, 360)-180;
%                         q5=qi(5)*180/pi;
%                         q5=mod(q5+180, 360)-180;
%                         q6=qi(6)*180/pi;
%                         if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
%                             display('Warning: Joints are Out of Range')
%                             set(myhandles.WarningText,'string','Warning: Joints are Out of Range')
%                         else
                            pause(0.02);
                            StringName=sprintf('C MJ %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,Qu1,Qu2,Qu3,Qu4,v);
                            fwrite(socket, StringName);
%                             pause(0.02)
%                             StringName=sprintf('1 2 3');
%                             fwrite(socket, StringName);
                            set(myhandles.ReachabilityStatusText,'String','Yes');
                            set(myhandles.WarningText,'String',' ');
                            SN=sprintf('Move to the specified coordinates in Joint-based fashion');
                            PushCommand(SN)
                            ReadFlag=1;
                            GetStatusFlag=0;
                end
                
%                         end
%                     end
%                 end
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
                if(Quarternion_check(Qu1,Qu2,Qu3,Qu4)==1)
                    set(myhandles.WarningText,'String','Warning: Quarternion is incorrect');
                else
                    v=get(myhandles.SetSpeedPopUp,'Value');
%                 q = Quaternion([Qu1 Qu2 Qu3 Qu4]); t = [Px/1000; Py/1000; Pz/1000];
%                 pos = rt2tr(q.R, t);
%                 [qi,fa,~] = irb_120.ikine(pos, 'pinv');

%                 if(fa==1)
%                     display('Warning: Movement is not reachable')
%                     set(myhandles.WarningText,'String','Warning: Movement is not reachable')
%                     set(myhandles.ReachabilityStatusText,'String','No');
%                 else
%                     m=irb_120.maniplty(qi,'all');
%                     if(m<0.02)
%                         display('Warning: Robot is near singularity')
%                         set(myhandles.WarningText,'String','Warning: Robot is near singularity')
%                     else
%                         q1=qi(1)*180/pi;
%                         q1=mod(q1+180, 360)-180;
%                         q2=qi(2)*180/pi;
%                         q2=mod(q2+180, 360)-180;
%                         q3=qi(3)*180/pi;
%                         q3=mod(q3+180, 360)-180;
%                         q4=qi(4)*180/pi;
%                         q4=mod(q4+180, 360)-180;
%                         q5=qi(5)*180/pi;
%                         q5=mod(q5+180, 360)-180;
%                         q6=qi(6)*180/pi;
%                         if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
%                             display('Warning: Joints are Out of Range')
%                             set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
%                         else
                            pause(0.02);
                            StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,Qu1,Qu2,Qu3,Qu4,v);
                            fwrite(socket, StringName);
%                             pause(0.02)
%                             StringName=sprintf('1 2 3');
%                             fwrite(socket, StringName);
                            ReadFlag=1;
                            GetStatusFlag=0;
                            set(myhandles.ReachabilityStatusText,'String','Yes');
                            set(myhandles.WarningText,'String',' ');
                            SN=sprintf('Move to the specified coordinates in Cartesian-based fashion');
                            PushCommand(SN)
                end
                
%                         end
%                     end
%                 end
            end
            %%
            %MANUAL JOGGING
            %CARTESIAN END EFFECTOR
            % x+
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
%                 StringName='x+';
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.px+(10*v);
                pause(0.02);
%                 q = Quaternion([context.qu1 context.qu2 context.qu3 context.qu4]); t = [d/1000; context.py/1000; context.pz/1000];
%                 pos = rt2tr(q.R, t);
%                 [qi,fa,~] = irb_120.ikine(pos, 'pinv');
%                 if(fa==1)
%                     display('Warning: Movement is not reachable')
%                     set(myhandles.WarningText,'String','Warning: Movement is not reachable')
%                     set(myhandles.ReachabilityStatusText,'String','No');
%                 else
%                     m=irb_120.maniplty(qi,'all');
%                     if(m<0.02)
%                         display('Warning: Robot is near singularity')
%                         set(myhandles.WarningText,'String','Warning: Robot is near singularity')
%                     else
%                         q1=qi(1)*180/pi;
%                         q1=mod(q1+180, 360)-180;
%                         q2=qi(2)*180/pi;
%                         q2=mod(q2+180, 360)-180;
%                         q3=qi(3)*180/pi;
%                         q3=mod(q3+180, 360)-180;
%                         q4=qi(4)*180/pi;
%                         q4=mod(q4+180, 360)-180;
%                         q5=qi(5)*180/pi;
%                         q5=mod(q5+180, 360)-180;
%                         q6=qi(6)*180/pi;
%                         if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
%                             display('Warning: Joints are Out of Range')
%                             set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
%                         else
                            StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %d',d,context.py,context.pz,context.qu1,context.qu2,context.qu3,context.qu4,5); 
                            fwrite(socket, StringName);
                            pause(0.02)
%                             StringName=sprintf('%.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6);
%                             StringName=sprintf('1 2 3');
%                             fwrite(socket, StringName);
%                             set(myhandles.ReachabilityStatusText,'String','Yes');
                            set(myhandles.WarningText,'String',' ');
                            SN=sprintf('Jog in +x direction');
                            PushCommand(SN)
                            ReadFlag=1;
                            GetStatusFlag=0;
%                         end
%                     end
%                 end
            end
            % x-
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
%                 StringName='x-';
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.px-(10*v);
%                 q = Quaternion([context.qu1 context.qu2 context.qu3 context.qu4]); t = [d/1000; context.py/1000; context.pz/1000];
%                 pos = rt2tr(q.R, t);
%                 [qi,fa,~] = irb_120.ikine(pos, 'pinv');
%                 if(fa==1)
%                     display('Warning: Movement is not reachable')
%                     set(myhandles.WarningText,'String','Warning: Movement is not reachable')
%                     set(myhandles.ReachabilityStatusText,'String','No');
%                 else
%                     m=irb_120.maniplty(qi,'all');
%                     if(m<0.02)
%                         display('Warning: Robot is near singularity')
%                         set(myhandles.WarningText,'String','Warning: Robot is near singularity')
%                     else
%                         q1=qi(1)*180/pi;
%                         q1=mod(q1+180, 360)-180;
%                         q2=qi(2)*180/pi;
%                         q2=mod(q2+180, 360)-180;
%                         q3=qi(3)*180/pi;
%                         q3=mod(q3+180, 360)-180;
%                         q4=qi(4)*180/pi;
%                         q4=mod(q4+180, 360)-180;
%                         q5=qi(5)*180/pi;
%                         q5=mod(q5+180, 360)-180;
%                         q6=qi(6)*180/pi;
%                         if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
%                             display('Warning: Joints are Out of Range')
%                             set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
%                         else
                        pause(0.02)
                        StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %d',d,context.py,context.pz,context.qu1,context.qu2,context.qu3,context.qu4,5);
                        fwrite(socket, StringName);
%                         pause(0.02)
%                         StringName=sprintf('1 2 3');
%                         fwrite(socket, StringName);
                        set(myhandles.ReachabilityStatusText,'String','Yes');
                        set(myhandles.WarningText,'String',' ');
                        SN=sprintf('Jog in -x direction');
                        PushCommand(SN)
                        ReadFlag=1;
                        GetStatusFlag=0;
%                         end
%                     end
%                 end
            end
            % y+
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'a')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
%                 StringName='y+';
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.py+(10*v);
%                 q = Quaternion([context.qu1 context.qu2 context.qu3 context.qu4]); t = [context.px/1000; d/1000; context.pz/1000];
%                 pos = rt2tr(q.R, t);
%                 [qi,fa,~] = irb_120.ikine(pos, 'pinv');
%                 if(fa==1)
%                     display('Warning: Movement is not reachable')
%                     set(myhandles.WarningText,'String','Warning: Movement is not reachable')
%                     set(myhandles.ReachabilityStatusText,'String','No');
%                 else
%                     m=irb_120.maniplty(qi,'all');
%                     if(m<0.02)
%                         display('Warning: Robot is near singularity')
%                         set(myhandles.WarningText,'String','Warning: Robot is near singularity')
%                     else
%                         q1=qi(1)*180/pi;
%                         q1=mod(q1+180, 360)-180;
%                         q2=qi(2)*180/pi;
%                         q2=mod(q2+180, 360)-180;
%                         q3=qi(3)*180/pi;
%                         q3=mod(q3+180, 360)-180;
%                         q4=qi(4)*180/pi;
%                         q4=mod(q4+180, 360)-180;
%                         q5=qi(5)*180/pi;
%                         q5=mod(q5+180, 360)-180;
%                         q6=qi(6)*180/pi;
%                         if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
%                             display('Warning: Joints are Out of Range')
%                             set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
%                         else
                        pause(0.02)
                        StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %d',context.px,d,context.pz,context.qu1,context.qu2,context.qu3,context.qu4,5);
                        fwrite(socket, StringName);
%                         pause(0.02)
%                         StringName=sprintf('1 2 3');
%                         fwrite(socket, StringName);
                        set(myhandles.ReachabilityStatusText,'String','Yes');
                        set(myhandles.WarningText,'String',' ');
                        SN=sprintf('Jog in +y direction');
                        PushCommand(SN)
                        ReadFlag=1;
                        GetStatusFlag=0;
%                         end
%                     end
%                 end
            end
            % y-
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'d')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
%                 StringName='y-';
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.py-(10*v);
%                 q = Quaternion([context.qu1 context.qu2 context.qu3 context.qu4]); t = [context.px/1000; d/1000; context.pz/1000];
%                 pos = rt2tr(q.R, t);
%                 [qi,fa,~] = irb_120.ikine(pos, 'pinv');
%                 if(fa==1)
%                     display('Warning: Movement is not reachable')
%                     set(myhandles.WarningText,'String','Warning: Movement is not reachable')
%                     set(myhandles.ReachabilityStatusText,'String','No');
%                 else
%                     m=irb_120.maniplty(qi,'all');
%                     if(m<0.02)
%                         display('Warning: Robot is near singularity')
%                         set(myhandles.WarningText,'String','Warning: Robot is near singularity')
%                     else
%                         q1=qi(1)*180/pi;
%                         q1=mod(q1+180, 360)-180;
%                         q2=qi(2)*180/pi;
%                         q2=mod(q2+180, 360)-180;
%                         q3=qi(3)*180/pi;
%                         q3=mod(q3+180, 360)-180;
%                         q4=qi(4)*180/pi;
%                         q4=mod(q4+180, 360)-180;
%                         q5=qi(5)*180/pi;
%                         q5=mod(q5+180, 360)-180;
%                         q6=qi(6)*180/pi;
%                         if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
%                             display('Warning: Joints are Out of Range')
%                             set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
%                         else
                        pause(0.02)
                        StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %d',context.px,d,context.pz,context.qu1,context.qu2,context.qu3,context.qu4,5);

                        fwrite(socket, StringName);
%                         pause(0.02)
%                         StringName=sprintf('1 2 3');
%                         fwrite(socket, StringName);
                        set(myhandles.ReachabilityStatusText,'String','Yes');
                        set(myhandles.WarningText,'String',' ');
                        SN=sprintf('Jog in -y direction');
                        PushCommand(SN)
                        ReadFlag=1;
                        GetStatusFlag=0;
%                         end
%                     end
%                 end
            end
            % z+
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'q')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
%                 StringName='z+';
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.pz+(10*v);
%                 q = Quaternion([context.qu1 context.qu2 context.qu3 context.qu4]); t = [context.px/1000; context.py/1000; d/1000];
%                 pos = rt2tr(q.R, t);
%                 [qi,fa,~] = irb_120.ikine(pos, 'pinv');
%                 if(fa==1)
%                     display('Warning: Movement is not reachable')
%                     set(myhandles.WarningText,'String','Warning: Movement is not reachable')
%                     set(myhandles.ReachabilityStatusText,'String','No');
%                 else
%                     m=irb_120.maniplty(qi,'all');
%                     if(m<0.02)
%                         display('Warning: Robot is near singularity')
%                         set(myhandles.WarningText,'String','Warning: Robot is near singularity')
%                     else
%                         q1=qi(1)*180/pi;
%                         q1=mod(q1+180, 360)-180;
%                         q2=qi(2)*180/pi;
%                         q2=mod(q2+180, 360)-180;
%                         q3=qi(3)*180/pi;
%                         q3=mod(q3+180, 360)-180;
%                         q4=qi(4)*180/pi;
%                         q4=mod(q4+180, 360)-180;
%                         q5=qi(5)*180/pi;
%                         q5=mod(q5+180, 360)-180;
%                         q6=qi(6)*180/pi;
%                         if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
%                             display('Warning: Joints are Out of Range')
%                             set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
%                         else
                            pause(0.02)
                            StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %d',context.px,context.py,d,context.qu1,context.qu2,context.qu3,context.qu4,5);

                            fwrite(socket, StringName);
%                             pause(0.02)
%                             StringName=sprintf('1 2 3');
%                             fwrite(socket, StringName);
                            set(myhandles.ReachabilityStatusText,'String','Yes');
                            set(myhandles.WarningText,'String',' ');
                            SN=sprintf('Jog in +z direction');
                            PushCommand(SN)
                            ReadFlag=1;
                            GetStatusFlag=0;
%                         end
%                     end
%                 end
            end
            % z-
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'e')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
%                 StringName='z-';
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.pz-(10*v);
%                 q = Quaternion([context.qu1 context.qu2 context.qu3 context.qu4]); t = [context.px/1000; context.py/1000; d/1000];
%                 pos = rt2tr(q.R, t);
%                 [qi,fa,~] = irb_120.ikine(pos, 'pinv');
%                 if(fa==1)
%                     display('Warning: Movement is not reachable')
%                     set(myhandles.WarningText,'String','Warning: Movement is not reachable')
%                     set(myhandles.ReachabilityStatusText,'String','No');
%                 else
%                     m=irb_120.maniplty(qi,'all');
%                     if(m<0.02)
%                         display('Warning: Robot is near singularity')
%                         set(myhandles.WarningText,'String','Warning: Robot is near singularity')
%                     else
%                         q1=qi(1)*180/pi;
%                         q1=mod(q1+180, 360)-180;
%                         q2=qi(2)*180/pi;
%                         q2=mod(q2+180, 360)-180;
%                         q3=qi(3)*180/pi;
%                         q3=mod(q3+180, 360)-180;
%                         q4=qi(4)*180/pi;
%                         q4=mod(q4+180, 360)-180;
%                         q5=qi(5)*180/pi;
%                         q5=mod(q5+180, 360)-180;
%                         q6=qi(6)*180/pi;
%                         if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
%                             display('Warning: Joints are Out of Range')
%                             set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
%                         else
                            pause(0.02)
                            StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %d',context.px,context.py,d,context.qu1,context.qu2,context.qu3,context.qu4,5);

                            fwrite(socket, StringName);
%                             pause(0.02)
%                             StringName=sprintf('1 2 3');
%                             fwrite(socket, StringName);
                            set(myhandles.ReachabilityStatusText,'String','Yes');
                            set(myhandles.WarningText,'String',' ');
                            SN=sprintf('Jog in -z direction');
                            PushCommand(SN)
                            ReadFlag=1;
                            GetStatusFlag=0;
%                         end
%                     end
%                 end
            end
            %JOINT ANGLES JOGGING
            %Q1
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J1RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q1+(0.2*v);
                q1=d;%Q1Text
                q1=mod(q1+180, 360)-180;
                q2=context.q2;
                q2=mod(q2+180, 360)-180;
                q3=context.q3;
                q3=mod(q3+180, 360)-180;
                q4=context.q4;
                q4=mod(q4+180, 360)-180;
                q5=context.q5;
                q5=mod(q5+180, 360)-180;
                q6=context.q6;
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
                else
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
    %                 StringName='q1+';
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('1 2 3');
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in + joint angle 1 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J1RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q1-(0.2*v);
                q1=d;%Q1Text
                q1=mod(q1+180, 360)-180;
                q2=context.q2;
                q2=mod(q2+180, 360)-180;
                q3=context.q3;
                q3=mod(q3+180, 360)-180;
                q4=context.q4;
                q4=mod(q4+180, 360)-180;
                q5=context.q5;
                q5=mod(q5+180, 360)-180;
                q6=context.q6;
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
                else
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
    %                 StringName='q1-';
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('1 2 3');
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in - joint angle 1 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %Q2
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J2RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q2+(0.2*v);
                q1=context.q1;%Q1Text
                q1=mod(q1+180, 360)-180;
                q2=d;
                q2=mod(q2+180, 360)-180;
                q3=context.q3;
                q3=mod(q3+180, 360)-180;
                q4=context.q4;
                q4=mod(q4+180, 360)-180;
                q5=context.q5;
                q5=mod(q5+180, 360)-180;
                q6=context.q6;
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
                else
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
                    %                 StringName='q2+';
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('1 2 3');
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in + joint angle 2 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J2RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q2-(0.2*v);
                q1=context.q1;%Q1Text
                q1=mod(q1+180, 360)-180;
                q2=d;
                q2=mod(q2+180, 360)-180;
                q3=context.q3;
                q3=mod(q3+180, 360)-180;
                q4=context.q4;
                q4=mod(q4+180, 360)-180;
                q5=context.q5;
                q5=mod(q5+180, 360)-180;
                q6=context.q6;
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
                else
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
    %                 StringName='q2-';
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('1 2 3');
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in - joint angle 2 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %Q3
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J3RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q3+(0.2*v);
                q1=context.q1;%Q1Text
                q1=mod(q1+180, 360)-180;
                q2=context.q2;
                q2=mod(q2+180, 360)-180;
                q3=d;
                q3=mod(q3+180, 360)-180;
                q4=context.q4;
                q4=mod(q4+180, 360)-180;
                q5=context.q5;
                q5=mod(q5+180, 360)-180;
                q6=context.q6;
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
                else
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
                    %                 StringName='q3+';
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('1 2 3');
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in + joint angle 3 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J3RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q3-(0.2*v);
                q1=context.q1;%Q1Text
                q1=mod(q1+180, 360)-180;
                q2=context.q2;
                q2=mod(q2+180, 360)-180;
                q3=d;
                q3=mod(q3+180, 360)-180;
                q4=context.q4;
                q4=mod(q4+180, 360)-180;
                q5=context.q5;
                q5=mod(q5+180, 360)-180;
                q6=context.q6;
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
                else
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
                    %                 StringName='q3-';
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('1 2 3');
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in - joint angle 3 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %Q4
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J4RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q4+(0.2*v);
                q1=context.q1;%Q1Text
                q1=mod(q1+180, 360)-180;
                q2=context.q2;
                q2=mod(q2+180, 360)-180;
                q3=context.q3;
                q3=mod(q3+180, 360)-180;
                q4=d;
                q4=mod(q4+180, 360)-180;
                q5=context.q5;
                q5=mod(q5+180, 360)-180;
                q6=context.q6;
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
                else
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
    %                 StringName='q4+';
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('1 2 3');
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in + joint angle 4 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J4RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q4-(0.2*v);
                q1=context.q1;%Q1Text
                q1=mod(q1+180, 360)-180;
                q2=context.q2;
                q2=mod(q2+180, 360)-180;
                q3=context.q3;
                q3=mod(q3+180, 360)-180;
                q4=d;
                q4=mod(q4+180, 360)-180;
                q5=context.q5;
                q5=mod(q5+180, 360)-180;
                q6=context.q6;
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
                else               
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
    %                 StringName='q4-';
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('1 2 3');
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in - joint angle 4 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %Q5
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J5RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q5+(0.2*v);
                q1=context.q1;%Q1Text
                q1=mod(q1+180, 360)-180;
                q2=context.q2;
                q2=mod(q2+180, 360)-180;
                q3=context.q3;
                q3=mod(q3+180, 360)-180;
                q4=context.q4;
                q4=mod(q4+180, 360)-180;
                q5=d;
                q5=mod(q5+180, 360)-180;
                q6=context.q6;
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
                else
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
    %                 StringName='q5+';
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('1 2 3');
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in + joint angle 5 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J5RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q5-(0.2*v);
                q1=context.q1;%Q1Text
                q1=mod(q1+180, 360)-180;
                q2=context.q2;
                q2=mod(q2+180, 360)-180;
                q3=context.q3;
                q3=mod(q3+180, 360)-180;
                q4=context.q4;
                q4=mod(q4+180, 360)-180;
                q5=d;
                q5=mod(q5+180, 360)-180;
                q6=context.q6;
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
                else
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
                    %                 StringName='q5-';
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('1 2 3');
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in - joint angle 5 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %Q6
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J6RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q6+(0.2*v);
                q1=context.q1;%Q1Text
                q1=mod(q1+180, 360)-180;
                q2=context.q2;
                q2=mod(q2+180, 360)-180;
                q3=context.q3;
                q3=mod(q3+180, 360)-180;
                q4=context.q4;
                q4=mod(q4+180, 360)-180;
                q5=context.q5;
                q5=mod(q5+180, 360)-180;
                q6=d;
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
                else
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
                    %                 StringName='q6+';
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('1 2 3');
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in + joint angle 6 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            if(get(myhandles.JointJoggingToggleButton,'Value')==1 && get(myhandles.J6RadioButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.q6-(0.2*v);
                q1=context.q1;%Q1Text
                q1=mod(q1+180, 360)-180;
                q2=context.q2;
                q2=mod(q2+180, 360)-180;
                q3=context.q3;
                q3=mod(q3+180, 360)-180;
                q4=context.q4;
                q4=mod(q4+180, 360)-180;
                q5=context.q5;
                q5=mod(q5+180, 360)-180;
                q6=d;
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'String','Warning: Joints are Out of Range')
                else
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
                    %                 StringName='q6-';
                    fwrite(socket, StringName);
%                     pause(0.02)
%                     StringName=sprintf('1 2 3');
%                     fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in - joint angle 6 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %% Control Input/output
%               ConveyorRadioButton
%               SolenoidRadioButton
%               VacuumRadioButton
%               ConveyorDirectionPushButton
%             conveyor off
            if(get(myhandles.ConveyorRadioButton,'UserData')==0 && ReadFlag==0)
                set(myhandles.ConveyorRadioButton,'UserData',3)
                pause(0.01);
                StringName='C SetConRun 0';
                fwrite(socket, StringName);
%                 pause(0.01);
%                 StringName=sprintf('%.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,context.q3,context.q4,context.q5,context.q6);
%                 fwrite(socket, StringName);
                SN=sprintf('Turn Conveyor off');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
%             conveyor on
            if(get(myhandles.ConveyorRadioButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.ConveyorRadioButton,'UserData',3)
                StringName='C SetConRun 1';
                pause(0.01);
                fwrite(socket, StringName);
%                 pause(0.01);
%                 StringName=sprintf('%.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,context.q3,context.q4,context.q5,context.q6);
%                 fwrite(socket, StringName);
                SN=sprintf('Turn Conveyor on');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
%             Vacuum off
            if(get(myhandles.VacuumRadioButton,'UserData')==0 && ReadFlag==0)
                set(myhandles.VacuumRadioButton,'UserData',3)
                pause(0.01);
                StringName='C SetVacRun 0';
                fwrite(socket, StringName);
%                 pause(0.01);
%                 StringName=sprintf('%.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,context.q3,context.q4,context.q5,context.q6);
%                 fwrite(socket, StringName);
                SN=sprintf('Turn Vacuum off');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
%             Vacuum on
            if(get(myhandles.VacuumRadioButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.VacuumRadioButton,'UserData',3)
                pause(0.01);
                StringName='C SetVacRun 1';
                fwrite(socket, StringName);
%                 pause(0.01);
%                 StringName=sprintf('%.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,context.q3,context.q4,context.q5,context.q6);
%                 fwrite(socket, StringName);
                SN=sprintf('Turn Vacuum on');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
%             Solenoid off
            if(get(myhandles.SolenoidRadioButton,'UserData')==0 && ReadFlag==0)
                set(myhandles.SolenoidRadioButton,'UserData',3)
                pause(0.01);
                StringName='C SetVacSol 0';
                fwrite(socket, StringName);
%                 pause(0.01);
%                 StringName=sprintf('%.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,context.q3,context.q4,context.q5,context.q6);
%                 fwrite(socket, StringName);
                SN=sprintf('Turn Solenoid off');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
%             Solenoid on
            if(get(myhandles.SolenoidRadioButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.SolenoidRadioButton,'UserData',3)
                pause(0.01);
                StringName='C SetVacSol 1';
                fwrite(socket, StringName);
%                 pause(0.01);
%                 StringName=sprintf('%.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,context.q3,context.q4,context.q5,context.q6);
%                 fwrite(socket, StringName);
                SN=sprintf('Turn Solenoid on');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
%             Conveyor Direction.
            if(get(myhandles.ConveyorDirectionPushButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.ConveyorDirectionPushButton,'UserData',0)
                pause(0.01);
                if(get(myhandles.ConveyorDirectionText,'UserData')==0)
                    set(myhandles.ConveyorDirectionText,'String','1')
                    set(myhandles.ConveyorDirectionText,'UserData',1)
                    StringName='C SetConDir 1';
                    SN=sprintf('Change conveyor directon into 1');
                    PushCommand(SN)
                else
                    set(myhandles.ConveyorDirectionText,'String','0')
                    set(myhandles.ConveyorDirectionText,'UserData',0)
                    StringName='C SetConDir 0';
                    SN=sprintf('Change conveyor directon into 0');
                    PushCommand(SN)
                end
                fwrite(socket, StringName);
%                 pause(0.01);
%                 StringName=sprintf('%.2f %.2f %.2f %.2f %.2f %.2f',context.q1,context.q2,context.q3,context.q4,context.q5,context.q6);
%                 fwrite(socket, StringName);
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %% Pause
            if(get(myhandles.PauseToggle,'UserData')==1 && ReadFlag==0)
                set(myhandles.PauseToggle, 'UserData',3);
                set(myhandles.PauseToggle, 'String','Resume');
                set(myhandles.VacuumRadioButton, 'Enable','off');
                set(myhandles.SolenoidRadioButton, 'Enable','off');
                set(myhandles.ConveyorRadioButton, 'Enable','off');
                set(myhandles.ConveyorDirectionPushButton, 'Enable','off');
                
                set(myhandles.uipanel5, 'Visible','off');
                set(myhandles.uipanel4, 'Visible','off');
                set(myhandles.uipanel6, 'Visible','off');
                
                pause(0.02);
                StringName='Pause 0';
                fwrite(socket, StringName);
                set(myhandles.WarningText,'String',' ');
                SN=sprintf('Pause Movement');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %% Resume
            if(get(myhandles.PauseToggle,'UserData')==0 && ReadFlag==0)
                set(myhandles.PauseToggle, 'UserData',3);
                set(myhandles.PauseToggle, 'String','Pause');
                set(myhandles.VacuumRadioButton, 'Enable','on');
                set(myhandles.SolenoidRadioButton, 'Enable','on');
                set(myhandles.ConveyorRadioButton, 'Enable','on');
                set(myhandles.ConveyorDirectionPushButton, 'Enable','on');
                if(get(myhandles.MotionType,'Value')==1)
                    set(myhandles.uipanel5, 'Visible','on');
                elseif(get(myhandles.MotionType,'Value')==2)
                    set(myhandles.uipanel4, 'Visible','on');
                else
                    set(myhandles.uipanel6, 'Visible','on');
                end
                    
                pause(0.02);
                StringName='Start 0';
                fwrite(socket, StringName);
                set(myhandles.WarningText,'String',' ');
                SN=sprintf('Resume Movement');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
%             set(handles.ResumeButton,'Visible','off')
            %% Close
            %%
            if(get(myhandles.ExitButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.ExitButton,'UserData',0)
                StringName='Close 1';
                fwrite(socket, StringName);
                SN=sprintf('Close Connection and Exit Program');
                PushCommand(SN)
                set(myhandles.listbox1,'String',context.command);
                break;
            end
            %% Get Status
            if(GetStatusFlag==1 && ReadFlag ==0)
                pause(0.02);
                StringName='S GetAll';
                fwrite(socket, StringName);
                ReadFlag=1;
            end
            %%
            if toc>3 && flag==1
                % Estop is Triggered
                % Socket is Broken
                fclose(socket);
                fclose(socket2);
                set(myhandles.WarningText,'String','Warning: Socket/E-Stop Error');
                SocketFlag=0;
                flag=0;
            end
            %READ OUTPUT FROM RAPID
            if(ReadFlag==1 && GetStatusFlag==0 &&SocketFlag==1)
                set(myhandles.listbox1,'String',context.command);
                ReadFlag=0;
                GetStatusFlag=1;
            elseif(ReadFlag==1 && GetStatusFlag==1 &&SocketFlag==1)
                pause(0.02);
%                 tic
                data = fgetl(socket2);
                flag = 1;
                tic;

                
                    decodestring_p(data);
                    string_p=sprintf('Px=%.2fmm,Py=%.2fmm,Pz=%.2fmm,qu1=%.2f,qu2=%.2f,qu3=%.2f,qu4=%.2f',context.px,context.py,context.pz,context.qu1,context.qu2,context.qu3,context.qu4);
                    set(myhandles.MotionStatusText, 'String', string_p);
                    pause(0.02);
                    data = fgetl(socket2);
                    decodestring_q(data);
                    string_q=sprintf('q1=%.2f,q2=%.2f,q3=%.2f,q4=%.2f,q5=%.2f,q6=%.2f',context.q1,context.q2,context.q3,context.q4,context.q5,context.q6);
                    set(myhandles.JointStatusText, 'String', string_q);
                    pause(0.02);
                    data = fgetl(socket2);
                    decodestring_io(data);
                    IO_error_check(myhandles)
                    check_constat(myhandles)
                    string_con=sprintf('%.0f',context.constat);
                    set(myhandles.ConveyorStatusText, 'String', string_con);
                    ReadFlag=0;
                    pause(0.02);
                    %!!! UNCOMMENT HERE TO READ THE 4TH BATCH
                    data = fgetl(socket2);
                    decodestring_oth(data);
                    if(context.reachability==0)
                        set(myhandles.WarningText,'String','Warning: Not reachable');
                        set(myhandles.ReachabilityStatusText,'String','No');
                    else
                        set(myhandles.WarningText,'String',' ');
                        set(myhandles.ReachabilityStatusText,'String','Yes');
                    end
                    pause(0.02);
                
            end

        end
%         process_time = toc;
    end
    
    % Close the socket.
    pause(0.5);
    fclose(socket);
    fclose(socket2);
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
    if( isempty(s)~=1)
        c =cell2mat(textscan(s,'%f'));
        context.px=c(2);
        context.py=c(3);
        context.pz=c(4);
        context.qu1=c(5);
        context.qu2=c(6);
        context.qu3=c(7);
        context.qu4=c(8);
    end
end
function decodestring_io(s)
    global context;
    if( isempty(s)~=1)
        c =cell2mat(textscan(s,'%f'));
        context.vacrun=c(2);
        context.vacsuck=c(3);
        context.conrun=c(4);
        context.condir=c(5);
        context.constat=c(6);
    end
end
function decodestring_oth(s)
    global context;
    if( isempty(s)~=1)
        c =cell2mat(textscan(s,'%f'));
        context.reachability=c(2);
        % COMMENT HERE
%         context.singularity=c(3);
    end
end
function IO_error_check(myhandles)
    global context;
%     context.vacrun=0;
%     context.vacsuck=0;
%     context.conrun=0;
%     context.condir=0;
    if(context.vacrun ~= get(myhandles.VacuumRadioButton,'Value'))
        set(myhandles.VacuumRadioButton,'Value',context.vacrun)
    end
    if(context.vacsuck ~= get(myhandles.SolenoidRadioButton,'Value'))
        set(myhandles.SolenoidRadioButton,'Value',context.vacsuck)
    end
    if(context.conrun ~= get(myhandles.ConveyorRadioButton,'Value'))
        set(myhandles.ConveyorRadioButton,'Value',context.conrun)
    end
    if(context.condir ~= get(myhandles.ConveyorDirectionText,'String'))
        if(context.condir==1)
            set(myhandles.ConveyorDirectionText,'String','1')
            set(myhandles.ConveyorDirectionText,'UserData',context.condir)
        else
            set(myhandles.ConveyorDirectionText,'String','0')
            set(myhandles.ConveyorDirectionText,'UserData',context.condir)
        end
    end
end
function check_constat(myhandles)
    global context;
    if(context.conrun==1 &&  context.constat==0)
        set(myhandles.WarningText,'String','Warning: Conveyor Status Problem');
        checklist = 'GUI_checklist.m';
        run(checklist);
        set(myhandles.VacuumRadioButton,'Value',0)
        set(myhandles.SolenoidRadioButton,'Value',0)
        set(myhandles.ConveyorRadioButton,'Value',0)
        set(myhandles.ConveyorDirectionText,'String','0')
        set(myhandles.ConveyorDirectionText,'UserData',context.condir)
        
    end
    
end
function r=Check_RoM(q1,q2,q3,q4,q5,q6)
    c=0;
    if(q1<-165 || q1>165)
        c=1;
    end
    if(q2<-110 || q2>110)
        c=1;
    end
    if(q3<-110 || q3>70)
        c=1;
    end
    if(q4<-160 || q4>160)
        c=1;
    end
    if(q5<-120 || q5>120)
        c=1;
    end
    if(q6<-400 || q6>400)
        c=1;
    end
    r=c;
end
function PushCommand(s)
    global context;
    if( isempty(s)~=1)
        
        context.command(10)=context.command(9);
        context.command(9)=context.command(8);
        context.command(8)=context.command(7);
        context.command(7)=context.command(6);
        context.command(6)=context.command(5);
        context.command(5)=context.command(4);
        context.command(4)=context.command(3);
        context.command(3)=context.command(2);
        context.command(2)=context.command(1);
        context.command(1)=cellstr(s);
    end
end
function e=Quarternion_check(q1,q2,q3,q4)
    if( abs(sqrt(q1^2+q2^2+q3^2+q4^2)-1)<0.05)
        e=0;
    else
        e=1;
    end
end
% =========================================================================
% Changelog
% =========================================================================
% week 4:-
% week 5:-