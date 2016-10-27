% Main functionality of the FinalGUI.m

% =========================================================================
% MTRN4230 Robotics
% Team Auto (Group 5)
% 10/7/2016
% compile and test!
% =========================================================================
% Changelog is in the end of the program

function FinalMain()
    % main GUI Initialisation     
    mywindow = FinalGui();
    myhandles = guihandles(mywindow);
    % Open the Starting Checklist GUI and disabled the FinalGui.m
    checklist = 'GUI_checklist.m';
    run(checklist);
    set(myhandles.ExitButton,'UserData',0);
    process_time=0;
    
    % Socket and Robot IP address initialisation
    SocketFlag=0; % 0 is not connected 1 is connected
    % this is the home simulation IP address
    % robot_IP_address = '127.0.0.1';
 	% this is the Real Robot IP address
    robot_IP_address = '192.168.125.1';
    data = ' ';
    
    %====================
    % Variables Declaration
    %====================
    ReadFlag=0;
    GetStatusFlag=1;
    global context;
    global output;
    global box;
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

    Px = [];
    Py = [];
    Pz = [];
    flag = 0;
    
    %====================
    % Click and Go Initialisation
    %====================
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
    
        %% COPY THIS JEFF ============================
    if exist('output_files/stack_blocks.txt');
        delete('output_files/stack_blocks.txt');
    end;
    
    if exist('output_files/build_stacked.txt');
        delete('output_files/build_stacked.txt');
    end;
    
    if exist('output_files/build_scattered.txt');
        delete('output_files/build_scattered.txt');
    end;
    %% ====      TO THIS JEFF   ==================
   
    
    %====================
    % Main Loop Routine
    % Description:  this is where all the communication between Matlab and
    %               Rapid Occurs
    %====================
    while(1)
        pause(0.1-process_time);
        %====================
        % TCP Connection Routine
        %====================
        % Receiving Socket Number, before any command could be pushed
        if(SocketFlag==0)
            set(myhandles.SocketStatus, 'String', 'Not Connected');
            % Reading the Port Value from the TextBox value      
            robot_port = str2double(get(myhandles.SocketNumberEditText,'String'));
            robot_port2= str2double(get(myhandles.SocketNumber2,'String'));
            if(get(myhandles.ConnectSocketPushButton,'UserData')==1)
                set(myhandles.ConnectSocketPushButton,'UserData',0)
                set(myhandles.WarningText,'String',' ');
                % Open a TCP connection to the robot via port 1.
                socket = tcpip(robot_IP_address, robot_port);
                set(socket, 'ReadAsyncMode', 'continuous');
                fopen(socket);
                % Check if the connection to port 1 is valid.
                if(~isequal(get(socket, 'Status'), 'open'))
                    warning(['Could not open TCP connection to ', robot_IP_address, ' on port ', robot_port]);
                    return;
                else
                    display('Socket1 is connected');
                end
                
                % Open a TCP connection to the robot via port 2.
                socket2 = tcpip(robot_IP_address, robot_port2);
                set(socket2, 'ReadAsyncMode', 'continuous');
                fopen(socket2);
                % Check if the connection to port 2 is valid.
                if(~isequal(get(socket2, 'Status'), 'open'))
                    warning(['Could not open TCP connection to ', robot_IP_address, ' on port ', robot_port2]);
                    return;
                else
                    display('Socket2 is connected');
                end
                SocketFlag=1;
            end
            
        elseif(SocketFlag==1)
            %====================
            % Main Communication Routine
            %====================
            % If Socket is Connected succesfully, all the control and
            % status functionalities are enabled

            set(myhandles.ExitButton,'Visible','on');
            set(myhandles.SocketStatus, 'String', 'Connected');
            
            % FARIS' CODE
            %====================
            % UNLOAD JENGAS FROM BOX ROUTINE
            %====================
            if(get(myhandles.AutoMateSelect,'UserData')==2 && ReadFlag==0)
                set(myhandles.AutoMateSelect,'UserData',0);
                %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                % Edit Here
                
                %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                SN=sprintf('Unload Jengas from box routine');
                PushCommand(SN)
                pause(0.02)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            % FARIS' CODE
            %====================
            % Order Fulfilling. put jengas to b1-b4 positions
            %====================
            if(get(myhandles.AutoMateSelect,'UserData')==3 && ReadFlag==0)
                set(myhandles.AutoMateSelect,'UserData',0);
                %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                % Edit Here
                % example:
                % get(myhandles.b1,'UserData') <---- READ the value from
                % the textbox b1
                
                
                
                
                %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                
                SN=sprintf('Order Fulfilling');
                PushCommand(SN)
                pause(0.02)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            % END Here
            %====================
            % CLICK AND GO Routine
            %====================
            % open the .txt file
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
            % write the coordinates if the it is in the table area
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
                Pz=Pz+10;
                v=get(myhandles.SetSpeedPopUp,'Value');
                
                pause(0.02)
                StringName=sprintf('C MJ %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,context.qu1,context.qu2,context.qu3,context.qu4,v);
                fwrite(socket, StringName);
                set(myhandles.ReachabilityStatusText,'String','Yes');
                SN=sprintf('Point and Click to x=%.2f,y=%.2f',Px,Py);
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end  
            % write the coordinates if the it is in the conveyor area
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
                Pz=Pz+10;
                v=get(myhandles.SetSpeedPopUp,'Value');
                pause(0.02);
                StringName=sprintf('C MJ %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,context.qu1,context.qu2,context.qu3,context.qu4,v);
                fwrite(socket, StringName);
                set(myhandles.ReachabilityStatusText,'String','Yes');
                SN=sprintf('Point and Click to x=%.2f,y=%.2f',Px,Py);
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;  
            end  
            
            
            %% EUGENE'S PART
            %% STACK TO 4 PILES COPY THIS JEFF =============================
            
            %Automate
            
            if(exist('output_files/stack_blocks.txt') & ReadFlag==0)
                delete('output_files/stack_blocks.txt');
                if exist('blocks.mat')
                     load('blocks.mat');
                    Px = blocks(1,1:end);
                    Py = blocks(2,1:end);
                    orie = blocks(3,1:end);
                    face = blocks(4,1:end);
                    reach = blocks(5,1:end);
                    
                    % if coordinates are within the tables range Pz is 10cm
                    % above table, if the coordinates are within the conveyer
                    % range Pz is 10cm above the conveyer
%                     Pz = checkPz(Px,Py,1);

                    delete('blocks.mat');
                    %                     delete('output_files/coordinates.txt');
                end;

                % switch coordinates for actual robot frame
                [Px,Py] = getP(Px,Py);
                tempX = Px;
                tempY = Py;
                Px = tempY
                Py = tempX
                if face == 1
                    Pz = 151.82;
                elseif face == 2
                    Pz = 161.87;
                elseif face ==3
                    Pz = 218.19;
                end

                v=get(myhandles.SetSpeedPopUp,'Value');
                
                % FARIS 4 PILES
                xp = 300;
                yp = 300;
                Pzz = 154.82;
                for i=1:numel(Py)
                    Pxx = Px(i);
                    Pyy = Py(i);
               
                    StringName=sprintf('C MF %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Pxx,Pyy,151.82,rad2deg(orie(i)),xp,yp,Pzz,v);
                    Pzz = Pzz + 14.5;
                    fwrite(socket, StringName);
                    pause(1);
                end
                
%                 pause(0.02)
%                 StringName=sprintf('%.2f',Px);
%                 fwrite(socket, StringName);
                set(myhandles.ReachabilityStatusText,'String','Yes');
                SN=sprintf('Point and Click to x=%.2f,y=%.2f',Px,Py);
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            
            %% BUILD TOWER FROM STACKED
            
            
            %Automate
            
            if(exist('output_files/build_stacked.txt') & ReadFlag==0)
                delete('output_files/build_stacked.txt');
                if exist('blocks.mat')
                     load('blocks.mat');
                    Px = blocks(1,1:end);
                    Py = blocks(2,1:end);
                    orie = blocks(3,1:end);
                    face = blocks(4,1:end);
                    reach = blocks(5,1:end);
                    
                    % if coordinates are within the tables range Pz is 10cm
                    % above table, if the coordinates are within the conveyer
                    % range Pz is 10cm above the conveyer
%                     Pz = checkPz(Px,Py,1);

                    delete('blocks.mat');
                    %                     delete('output_files/coordinates.txt');
                end;

                % switch coordinates for actual robot frame
                [Px,Py] = getP(Px,Py);
                tempX = Px;
                tempY = Py;
                Px = tempY
                Py = tempX
                if face == 1
                    Pz = 151.82;
                elseif face == 2
                    Pz = 161.87;
                elseif face ==3
                    Pz = 218.19;
                end

                v=get(myhandles.SetSpeedPopUp,'Value');
                % FARIS BUILD TOWER FROM STACKED
                
                xp = 300;
                yp = 300;
                Pzz = 154.82;
                for i=1:numel(Py)
                    Pxx = Px(i);
                    Pyy = Py(i);
               
                    StringName=sprintf('C MF %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Pxx,Pyy,151.82,rad2deg(orie(i)),xp,yp,Pzz,v);
                    Pzz = Pzz + 14.5;
                    fwrite(socket, StringName);
                    pause(1);
                end
                
%                 pause(0.02)
%                 StringName=sprintf('%.2f',Px);
%                 fwrite(socket, StringName);
                set(myhandles.ReachabilityStatusText,'String','Yes');
                SN=sprintf('Point and Click to x=%.2f,y=%.2f',Px,Py);
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            
            %% BUILD TOWER FROM SCATTERED
            
    
            
            if(exist('output_files/build_scattered.txt') & ReadFlag==0)
                delete('output_files/build_scattered.txt');
                if exist('blocks.mat')
                     load('blocks.mat');
                    Px = blocks(1,1:end);
                    Py = blocks(2,1:end);
                    orie = blocks(3,1:end);
                    face = blocks(4,1:end);
                    reach = blocks(5,1:end);
                    
                    % if coordinates are within the tables range Pz is 10cm
                    % above table, if the coordinates are within the conveyer
                    % range Pz is 10cm above the conveyer
%                     Pz = checkPz(Px,Py,1);

                    delete('blocks.mat');
                    %                     delete('output_files/coordinates.txt');
                end;

                % switch coordinates for actual robot frame
                [Px,Py] = getP(Px,Py);
                tempX = Px;
                tempY = Py;
                Px = tempY
                Py = tempX
                if face == 1
                    Pz = 151.82;
                elseif face == 2
                    Pz = 161.87;
                elseif face ==3
                    Pz = 218.19;
                end

                v=get(myhandles.SetSpeedPopUp,'Value');
                
                % FARIS BUILD TOWER FROM SCATTERED
                
                xp = 300;
                yp = 300;
                Pzz = 154.82;
                for i=1:numel(Py)
                    Pxx = Px(i);
                    Pyy = Py(i);
               
                    StringName=sprintf('C MF %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Pxx,Pyy,151.82,rad2deg(orie(i)),xp,yp,Pzz,v);
                    Pzz = Pzz + 14.5;
                    fwrite(socket, StringName);
                    pause(1);
                end
                
%                 pause(0.02)
%                 StringName=sprintf('%.2f',Px);
%                 fwrite(socket, StringName);
                set(myhandles.ReachabilityStatusText,'String','Yes');
                SN=sprintf('Point and Click to x=%.2f,y=%.2f',Px,Py);
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            
            %% ========== TO THIS JEFF ================================================================
            
            %-- END HERE
            %% 
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            %====================
            % Set Move Joints angle Routine
            %====================
            if((get(myhandles.SendPoseJPushButton,'UserData')==1) && ReadFlag==0)
                % mod the joints angle read
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
                % check if the joints are within the range of motion
                if(Check_RoM(q1,q2,q3,q4,q5,q6)==1)
                    display('Warning: Joints are Out of Range')
                    set(myhandles.WarningText,'string','Warning: Joints are Out of Range')
                else
                    pause(0.02)
                    StringName=sprintf('C MA %.2f %.2f %.2f %.2f %.2f %.2f %.2f',q1,q2,q3,q4,q5,q6,v);
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Move to the specified joint angles');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            
            %====================
            % Set the coordinates and orientation in Cartesian Routine
            % Joint-Based
            %====================
            if((get(myhandles.SendPoseLBPushButton,'UserData')==1) && ReadFlag==0)
                set(myhandles.SendPoseLBPushButton,'UserData',0)
                Px=str2double(get(myhandles.PxText, 'String'));%Q1Text
                Py=str2double(get(myhandles.PyText, 'String'));
                Pz=str2double(get(myhandles.PzText, 'String'));
                Qu1=str2double(get(myhandles.Qu1Text, 'String'));
                Qu2=str2double(get(myhandles.Qu2Text, 'String'));
                Qu3=str2double(get(myhandles.Qu3Text, 'String'));
                Qu4=str2double(get(myhandles.Qu4Text, 'String'));
                % Check if the quarternion is wrong or not
                if(Quarternion_check(Qu1,Qu2,Qu3,Qu4)==1)
                    set(myhandles.WarningText,'String','Warning: Quarternion is incorrect');
                else
                    v=get(myhandles.SetSpeedPopUp,'Value');
                    pause(0.02);
                    StringName=sprintf('C MJ %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,Qu1,Qu2,Qu3,Qu4,v);
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Move to the specified coordinates in Joint-based fashion');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %====================
            % Set the coordinates and orientation in Cartesian Routine
            % Linear-Based
            %====================
            if((get(myhandles.SendPoseLAPushButton,'UserData')==1) && ReadFlag==0)
                set(myhandles.SendPoseLAPushButton,'UserData',0)
                Px=str2double(get(myhandles.PxText, 'String'));%Q1Text
                Py=str2double(get(myhandles.PyText, 'String'));
                Pz=str2double(get(myhandles.PzText, 'String'));
                Qu1=str2double(get(myhandles.Qu1Text, 'String'));
                Qu2=str2double(get(myhandles.Qu2Text, 'String'));
                Qu3=str2double(get(myhandles.Qu3Text, 'String'));
                Qu4=str2double(get(myhandles.Qu4Text, 'String'));
                % Check if the quarternion is wrong or not
                if(Quarternion_check(Qu1,Qu2,Qu3,Qu4)==1)
                    set(myhandles.WarningText,'String','Warning: Quarternion is incorrect');
                else
                    v=get(myhandles.SetSpeedPopUp,'Value');
                    pause(0.02);
                    StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Px,Py,Pz,Qu1,Qu2,Qu3,Qu4,v);
                    fwrite(socket, StringName);
                    ReadFlag=1;
                    GetStatusFlag=0;
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Move to the specified coordinates in Cartesian-based fashion');
                    PushCommand(SN)
                end
            end
            %%
            %====================
            % Manual Jogging Routine
            %====================
            
            %====================
            % The Cartesian End Effector Jogging
            %====================
            
            %====================
            % x+ Movement by pressing 'w' key
            %====================
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'w')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.px+(10*v);
                pause(0.02);
                StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %d',d,context.py,context.pz,context.qu1,context.qu2,context.qu3,context.qu4,5); 
                fwrite(socket, StringName);
                pause(0.02)
                set(myhandles.WarningText,'String',' ');
                SN=sprintf('Jog in +x direction');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %====================
            % x- Movement by pressing 's' key
            %====================
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'s')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.px-(10*v);
                pause(0.02)
                StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %d',d,context.py,context.pz,context.qu1,context.qu2,context.qu3,context.qu4,5);
                fwrite(socket, StringName);
                set(myhandles.ReachabilityStatusText,'String','Yes');
                set(myhandles.WarningText,'String',' ');
                SN=sprintf('Jog in -x direction');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %====================
            % y+ Movement by pressing 'a' key
            %====================
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'a')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.py+(10*v);
                pause(0.02)
                StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %d',context.px,d,context.pz,context.qu1,context.qu2,context.qu3,context.qu4,5);
                fwrite(socket, StringName);
                set(myhandles.ReachabilityStatusText,'String','Yes');
                set(myhandles.WarningText,'String',' ');
                SN=sprintf('Jog in +y direction');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %====================
            % y- Movement by pressing 'd' key
            %====================
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'d')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.py-(10*v);
                pause(0.02)
                StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %d',context.px,d,context.pz,context.qu1,context.qu2,context.qu3,context.qu4,5);
                fwrite(socket, StringName);
                set(myhandles.ReachabilityStatusText,'String','Yes');
                set(myhandles.WarningText,'String',' ');
                SN=sprintf('Jog in -y direction');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %====================
            % z+ Movement by pressing 'q' key
            %====================
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'q')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.pz+(10*v);
                pause(0.02)
                StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %d',context.px,context.py,d,context.qu1,context.qu2,context.qu3,context.qu4,5);

                fwrite(socket, StringName);
                set(myhandles.ReachabilityStatusText,'String','Yes');
                set(myhandles.WarningText,'String',' ');
                SN=sprintf('Jog in +z direction');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %====================
            % z- Movement by pressing 'e' key
            %====================
            if(get(myhandles.CartesianToggleButton,'Value')==1 && strcmp(get(mywindow,'CurrentCharacter'),'e')==1 &&ReadFlag==0)
                set(mywindow,'CurrentCharacter',' ')
                v=get(myhandles.SetSpeedPopUp,'Value');
                d=context.pz-(10*v);
                pause(0.02)
                StringName=sprintf('C ML %.2f %.2f %.2f %.2f %.2f %.2f %.2f %d',context.px,context.py,d,context.qu1,context.qu2,context.qu3,context.qu4,5);

                fwrite(socket, StringName);
                set(myhandles.ReachabilityStatusText,'String','Yes');
                set(myhandles.WarningText,'String',' ');
                SN=sprintf('Jog in -z direction');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            
            %====================
            % Joint Jogging Routine
            %====================
            
            %====================
            % joint 1 + Movement by pressing 'w' key
            %====================
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
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in + joint angle 1 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            
            %====================
            % joint 1 - Movement by pressing 's' key
            %====================
            
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
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in - joint angle 1 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %====================
            % joint 2 + Movement by pressing 'w' key
            %====================
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
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in + joint angle 2 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %====================
            % joint 2 - Movement by pressing 's' key
            %====================
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
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in - joint angle 2 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %====================
            % joint 3 + Movement by pressing 'w' key
            %====================
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
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in + joint angle 3 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            
            %====================
            % joint 3 - Movement by pressing 's' key
            %====================
            
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
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in - joint angle 3 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %====================
            % joint 4 + Movement by pressing 'w' key
            %====================
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
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in + joint angle 4 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %====================
            % joint 4 - Movement by pressing 's' key
            %====================
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
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in - joint angle 4 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %====================
            % joint 5 + Movement by pressing 'w' key
            %====================
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
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in + joint angle 5 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %====================
            % joint 5 - Movement by pressing 's' key
            %====================
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
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in - joint angle 5 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %====================
            % joint 6 + Movement by pressing 'w' key
            %====================
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
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in + joint angle 6 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %====================
            % joint 6 - Movement by pressing 's' key
            %====================
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
                    fwrite(socket, StringName);
                    set(myhandles.ReachabilityStatusText,'String','Yes');
                    set(myhandles.WarningText,'String',' ');
                    SN=sprintf('Jog in - joint angle 6 direction');
                    PushCommand(SN)
                    ReadFlag=1;
                    GetStatusFlag=0;
                end
            end
            %%
            %====================
            % Control Input/Output Routine
            %====================

            %====================
            % Conveyor Off Routine
            %====================
            if(get(myhandles.ConveyorRadioButton,'UserData')==0 && ReadFlag==0)
                set(myhandles.ConveyorRadioButton,'UserData',3)
                pause(0.01);
                StringName='C SetConRun 0';
                fwrite(socket, StringName);
                SN=sprintf('Turn Conveyor off');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %====================
            % Conveyor On Routine
            %====================
            if(get(myhandles.ConveyorRadioButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.ConveyorRadioButton,'UserData',3)
                StringName='C SetConRun 1';
                pause(0.01);
                fwrite(socket, StringName);
                SN=sprintf('Turn Conveyor on');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %====================
            % Vacuum Off Routine
            %====================
            if(get(myhandles.VacuumRadioButton,'UserData')==0 && ReadFlag==0)
                set(myhandles.VacuumRadioButton,'UserData',3)
                pause(0.01);
                StringName='C SetVacRun 0';
                fwrite(socket, StringName);
                SN=sprintf('Turn Vacuum off');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %====================
            % Vacuum on Routine
            %====================
            if(get(myhandles.VacuumRadioButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.VacuumRadioButton,'UserData',3)
                pause(0.01);
                StringName='C SetVacRun 1';
                fwrite(socket, StringName);
                SN=sprintf('Turn Vacuum on');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %====================
            % Solenoid off Routine
            %====================
            if(get(myhandles.SolenoidRadioButton,'UserData')==0 && ReadFlag==0)
                set(myhandles.SolenoidRadioButton,'UserData',3)
                pause(0.01);
                StringName='C SetVacSol 0';
                fwrite(socket, StringName);
                SN=sprintf('Turn Solenoid off');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %====================
            % Solenoid on Routine
            %====================
            if(get(myhandles.SolenoidRadioButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.SolenoidRadioButton,'UserData',3)
                pause(0.01);
                StringName='C SetVacSol 1';
                fwrite(socket, StringName);
                SN=sprintf('Turn Solenoid on');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %====================
            % Conveyor Direction Routine
            %====================
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
                ReadFlag=1;
                GetStatusFlag=0;
            end
            %%
            %====================
            % Pause Movement Routine
            %====================
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
            %====================
            % Restart Movement Routine
            %====================
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
            %%
            %% Stop FARIS == COPY THIS JEFF ==============================
            if(get(myhandles.stopPushButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.stopPushButtonToggle, 'UserData',3);
                set(myhandles.VacuumRadioButton, 'Enable','off');
                set(myhandles.SolenoidRadioButton, 'Enable','off');
                set(myhandles.ConveyorRadioButton, 'Enable','off');
                set(myhandles.ConveyorDirectionPushButton, 'Enable','off');
                
                set(myhandles.uipanel5, 'Visible','off');
                set(myhandles.uipanel4, 'Visible','off');
                set(myhandles.uipanel6, 'Visible','off');
                
                pause(0.02);
                StringName='Stop 0';
                fwrite(socket, StringName);
                set(myhandles.WarningText,'String',' ');
                SN=sprintf('Stop Movement');
                PushCommand(SN)
                ReadFlag=1;
                GetStatusFlag=0;
            end
            
            %% ==================  TO THIS JEFF  ==========================
%
            %%
            %====================
            % Close/ Exit Routine
            % This will break from the main loop and close the connection
            %====================
            if(get(myhandles.ExitButton,'UserData')==1 && ReadFlag==0)
                set(myhandles.ExitButton,'UserData',0)
                StringName='Close 1';
                fwrite(socket, StringName);
                SN=sprintf('Close Connection and Exit Program');
                PushCommand(SN)
                set(myhandles.listbox1,'String',context.command);
                break;
            end
            %%
            %====================
            % Send Status Command Routine
            %====================
            if(GetStatusFlag==1 && ReadFlag ==0)
                pause(0.02);
                StringName='S GetAll';
                fwrite(socket, StringName);
                ReadFlag=1;
            end
            %%
            %====================
            % Socket Error Check Routine
            % If the connection between the status strings takes longer
            % than 3 seconds, It will try to close the connection and ask
            % the user to connect to the socket again
            %====================
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
            %====================
            % Reading Output Routine
            % If it is a control command, it will store the command in the
            % command history.
            % if it is the Send Status command, it will read 4 batches of
            % strings which contains of all the status.
            %====================
            if(ReadFlag==1 && GetStatusFlag==0 &&SocketFlag==1)
                set(myhandles.listbox1,'String',context.command);
                ReadFlag=0;
                GetStatusFlag=1;
            elseif(ReadFlag==1 && GetStatusFlag==1 &&SocketFlag==1)
                pause(0.02);
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
    end  
    % Close the socket.
    pause(0.5);
    fclose(socket);
    fclose(socket2);
end

function decodestring_q(s)
    %====================
    % Joint angles Strings Decoding Routine
    %====================
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
    %====================
    % Pose and Orientation Strings Decoding Routine
    %====================
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
    %====================
    % I/O status Decoding Routine
    %====================
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
    %====================
    % Error Strings Decoding Routine
    %====================
    global context;
    if( isempty(s)~=1)
        c =cell2mat(textscan(s,'%f'));
        context.reachability=c(2);
    end
end
function IO_error_check(myhandles)
    %====================
    % I/O error check routine
    % if there is a mismatch with the button and the I/O, it will change
    % the radio buttons to match the I/O status
    %====================
    global context;
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
    %====================
    % Conveyor Status Error Check Routine
    %====================
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
    %====================
    % Range of Motion Error Check
    %====================
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
    %====================
    % Command History Routine
    % it will push the newest command in the first index, and remove the
    % last command.
    %====================
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
    %====================
    % Quarternion Error Check Routine
    % If the square root of the sum of square of the quarternion is not
    % equal to 1, it will give an error
    %====================
    if( abs(sqrt(q1^2+q2^2+q3^2+q4^2)-1)<0.05)
        e=0;
    else
        e=1;
    end
end


% =========================================================================
% Changelog
% =========================================================================
% week 4: -GUI Structure made (Jeffry Lay)
% week 5: -Adding TCP Connection Routine (Jeffry and Tyson Chan)
% week 6: -Adding set type of movement routine (Jeffry)
%         -Camera Calibration Routine (Eugene Park)
% week 7: -Jogging routine made (Jeffry)
% week 8: -I/O status (Jeffry)
%         -Point and Click Routine (Eugene)
% week 9: -Error Check Routine (Jeffry, Ankur Goel and Faris Azhari)
% week 10: - Final Testing (Everyone)
%          - Minor Change (Jeffry)