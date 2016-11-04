function varargout = SampleGui(varargin)
%SAMPLEGUI M-file for SampleGui.fig
%      SAMPLEGUI, by itself, creates a new SAMPLEGUI or raises the existing
%      singleton*.
%
%      H = SAMPLEGUI returns the handle to a new SAMPLEGUI or the handle to
%      the existing singleton*.
%
%      SAMPLEGUI('Property','Value',...) creates a new SAMPLEGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to SampleGui_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SAMPLEGUI('CALLBACK') and SAMPLEGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SAMPLEGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SampleGui

% Last Modified by GUIDE v2.5 06-Oct-2016 14:47:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SampleGui_OpeningFcn, ...
                   'gui_OutputFcn',  @SampleGui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SampleGui is made visible.
function SampleGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Camera calibration parameters (Click and Go) For testing undistorting
% video feed (Click and Go).
load('cameraParamsRoboticsAtt2.mat');
cameraParams = cameraParamsSecondAtt;

% Choose default command line output for SampleGui
handles.output = hObject;

% % % % % % % % % % % % % % Table camera
% % % % % % % % % % % % % axes(handles.camera1);
% % % % % % % % % % % % % handles.vid1 = videoinput('winvideo',1,'RGB_1600x1200');
% % % % % % % % % % % % % res = handles.vid1.VideoResolution;
% % % % % % % % % % % % % ban = handles.vid1.NumberOfBands;
% % % % % % % % % % % % % him = image( zeros(res(2), res(1), ban));
% % % % % % % % % % % % % handles.v1h = him;
% % % % % % % % % % % % % i1 = preview(handles.vid1, handles.v1h);
% % % % % % % % % % % % % set(i1,'ButtonDownFcn',@i1call);

% % % % % % % % % % % % % % Conveyer camera
% % % % % % % % % % % % % axes(handles.camera2);
% % % % % % % % % % % % % handles.vid2 = videoinput('winvideo',2,'RGB_1600x1200');
% % % % % % % % % % % % % res2 = handles.vid2.VideoResolution;
% % % % % % % % % % % % % ban2 = handles.vid2.NumberOfBands;
% % % % % % % % % % % % % him2 = image( zeros(res2(2), res2(1), ban2));
% % % % % % % % % % % % % handles.v2h = him2;
% % % % % % % % % % % % % i2 = preview(handles.vid2, handles.v2h);
% % % % % % % % % % % % % set(i2,'ButtonDownFcn',@i2call);

%-------------------------------------------------------------------------
%               TESTING WITH IMAGES OF TABLE & CONVEYER
%-------------------------------------------------------------------------
% image for first camera
axes(handles.camera1);
im = imread('undistortimage.png');
handles.vid1 = im;
i1 = imshow(im);
set(i1,'ButtonDownFcn',@i1call);

% image for second camera
axes(handles.camera2);
im = imread('undistortConimage.png');
handles.vid2 = im;
i2 = imshow(im);
set(i2,'ButtonDownFcn',@i2call);
%--------------------------------------------------------------------------

% Update handles structure
guidata(hObject, handles);
set(handles.ExitButton,'UserData',0)
set(handles.ConnectSocketPushButton,'UserData',0)
set(handles.SendString,'UserData',0)
set(handles.SocketNumberEditText,'string','');
set(handles.SendStringEditText,'string','');

set(handles.VacuumRadioButton,'Value',0);
set(handles.ConveyorRadioButton,'Value',0);
set(handles.SolenoidRadioButton,'Value',0);

set(handles.VacuumRadioButton,'UserData',3);
set(handles.ConveyorRadioButton,'UserData',3);
set(handles.SolenoidRadioButton,'UserData',3);

set(handles.ExitButton,'Visible','off');

set(handles.MotionType,'Value',1);
set(handles.uipanel5,'Visible','on');
set(handles.uipanel4,'Visible','off');
set(handles.uipanel6,'Visible','off');
set(handles.SetPoseTypePopup,'Value',1);
set(handles.SetSpeedPopUp,'Value',1);
set(handles.uipanel10,'Visible','on');
set(handles.uipanel11,'Visible','off');
set(handles.ConveyorDirectionText,'string',0);
set(handles.ConveyorDirectionPushButton,'UserData',0);
set(handles.EnableToPointToggle,'Visible','off');
set(handles.EnableToPointToggle,'Value',0);
set(handles.CartesianToggleButton,'Value',0);
set(handles.JointJoggingToggleButton,'Value',0);
set(handles.uipanel8,'Visible','off');
set(handles.JointJoggingToggleButton,'enable','on');
set(handles.CartesianToggleButton,'enable','on');
set(handles.J1RadioButton,'Value',1);
set(handles.MotionType,'enable','on');
set(handles.SendPoseLAPushButton,'UserData',0);
set(handles.SendPoseLBPushButton,'UserData',0);
set(handles.SendPoseJPushButton,'UserData',0);
set(handles.Q1Text, 'String','0');%Q1Text
set(handles.Q2Text, 'String','0');%Q2Text
set(handles.Q3Text, 'String','0');%Q3Text
set(handles.Q4Text, 'String','0');%Q4Text
set(handles.Q5Text, 'String','0');%Q5Text
set(handles.Q6Text, 'String','0');%Q6Text
set(handles.PxText, 'String','0');
set(handles.PyText, 'String','0');
set(handles.PzText, 'String','0');
set(handles.Qu1Text, 'String','0');
set(handles.Qu2Text, 'String','0');
set(handles.Qu3Text, 'String','0');
set(handles.Qu4Text, 'String','0');

% UIWAIT makes SampleGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SampleGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

%%########################################################################
% --- Executes on button press in SendString.
function SendString_Callback(hObject, eventdata, handles)
% hObject    handle to SendString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.SendString,'UserData',1)
% display('Send String Button is pressed')


function SocketStatus_Callback(hObject, eventdata, handles)
% hObject    handle to SocketStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SocketStatus as text
%        str2double(get(hObject,'String')) returns contents of SocketStatus as a double


% --- Executes during object creation, after setting all properties.
function SocketStatus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SocketStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ReceiveText_Callback(hObject, eventdata, handles)
% hObject    handle to ReceiveText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ReceiveText as text
%        str2double(get(hObject,'String')) returns contents of ReceiveText as a double


% --- Executes during object creation, after setting all properties.
function ReceiveText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ReceiveText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ExitButton.
function ExitButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 1
% get(hObject,'Value')
set(handles.ExitButton,'UserData',1)
display('goodbye')


% --- Executes on button press in ConnectSocketPushButton.
function ConnectSocketPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to ConnectSocketPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ConnectSocketPushButton,'UserData',1)
% display('ConnectSocket Button is pressed')


function SocketNumberEditText_Callback(hObject, eventdata, handles)
% hObject    handle to SocketNumberEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SocketNumberEditText as text
%        str2double(get(hObject,'String')) returns contents of SocketNumberEditText as a double
% str2double(get(hObject,'String'))
display('Port Number is Received');


% --- Executes during object creation, after setting all properties.
function SocketNumberEditText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SocketNumberEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SendStringEditText_Callback(hObject, eventdata, handles)
% hObject    handle to SendStringEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SendStringEditText as text
% %        str2double(get(hObject,'String')) returns contents of SendStringEditText as a double
% (get(hObject,'String'))
% display('String has been inputted. Pressed "Send String button" to send it to RAPID');

% --- Executes during object creation, after setting all properties.
function SendStringEditText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SendStringEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SendPoseLAPushButton.
function SendPoseLAPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to SendPoseLAPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.SendPoseLAPushButton,'UserData',1);
% fprintf('move Linear is pressed\n')


% --- Executes on button press in VacuumRadioButton.
function VacuumRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to VacuumRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VacuumRadioButton

value=get(handles.VacuumRadioButton,'Value');
if(value==0)
    set(handles.VacuumRadioButton,'Userdata',0);
else
    set(handles.VacuumRadioButton,'Userdata',1);
end
% fprintf('Vacuum: %d\n', value)


% --- Executes on button press in ConveyorRadioButton.
function ConveyorRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to ConveyorRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ConveyorRadioButton
value=get(handles.ConveyorRadioButton,'Value');
if(value==0)
    set(handles.ConveyorRadioButton,'Userdata',0);
else
    set(handles.ConveyorRadioButton,'Userdata',1);
end
% fprintf('Conveyor: %d\n', value)

% --- Executes on button press in ConveyorDirectionPushButton.
function ConveyorDirectionPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to ConveyorDirectionPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.ConveyorDirectionPushButton,'UserData',1)


function ConveyorStatusText_Callback(hObject, eventdata, handles)
% hObject    handle to ConveyorStatusText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ConveyorStatusText as text
%        str2double(get(hObject,'String')) returns contents of ConveyorStatusText as a double


% --- Executes during object creation, after setting all properties.
function ConveyorStatusText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConveyorStatusText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ConveyorDirectionText_Callback(hObject, eventdata, handles)
% hObject    handle to ConveyorDirectionText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ConveyorDirectionText as text
%        str2double(get(hObject,'String')) returns contents of ConveyorDirectionText as a double


% --- Executes during object creation, after setting all properties.
function ConveyorDirectionText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConveyorDirectionText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Q1Text_Callback(hObject, eventdata, handles)
% hObject    handle to Q1Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Q1Text as text
%        str2double(get(hObject,'String')) returns contents of Q1Text as a double


% --- Executes during object creation, after setting all properties.
function Q1Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Q1Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PxText_Callback(hObject, eventdata, handles)
% hObject    handle to PxText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PxText as text
%        str2double(get(hObject,'String')) returns contents of PxText as a double


% --- Executes during object creation, after setting all properties.
function PxText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PxText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PyText_Callback(hObject, eventdata, handles)
% hObject    handle to PyText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PyText as text
%        str2double(get(hObject,'String')) returns contents of PyText as a double


% --- Executes during object creation, after setting all properties.
function PyText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PyText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PzText_Callback(hObject, eventdata, handles)
% hObject    handle to PzText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PzText as text
%        str2double(get(hObject,'String')) returns contents of PzText as a double


% --- Executes during object creation, after setting all properties.
function PzText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PzText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SendPoseJPushButton.
function SendPoseJPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to SendPoseJPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.SendPoseJPushButton,'UserData',1);
% fprintf('move joints is pressed\n')


function Q2Text_Callback(hObject, eventdata, handles)
% hObject    handle to Q2Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
1
% Hints: get(hObject,'String') returns contents of Q2Text as text
%        str2double(get(hObject,'String')) returns contents of Q2Text as a double


% --- Executes during object creation, after setting all properties.
function Q2Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Q2Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Q3Text_Callback(hObject, eventdata, handles)
% hObject    handle to Q3Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Q3Text as text
%        str2double(get(hObject,'String')) returns contents of Q3Text as a double


% --- Executes during object creation, after setting all properties.
function Q3Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Q3Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Q4Text_Callback(hObject, eventdata, handles)
% hObject    handle to Q4Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Q4Text as text
%        str2double(get(hObject,'String')) returns contents of Q4Text as a double


% --- Executes during object creation, after setting all properties.
function Q4Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Q4Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Q5Text_Callback(hObject, eventdata, handles)
% hObject    handle to Q5Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Q5Text as text
%        str2double(get(hObject,'String')) returns contents of Q5Text as a double


% --- Executes during object creation, after setting all properties.
function Q5Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Q5Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Q6Text_Callback(hObject, eventdata, handles)
% hObject    handle to Q6Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Q6Text as text
%        str2double(get(hObject,'String')) returns contents of Q6Text as a double


% --- Executes during object creation, after setting all properties.
function Q6Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Q6Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MotionStatusText_Callback(hObject, eventdata, handles)
% hObject    handle to MotionStatusText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MotionStatusText as text
%        str2double(get(hObject,'String')) returns contents of MotionStatusText as a double


% --- Executes during object creation, after setting all properties.
function MotionStatusText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MotionStatusText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SendPoseLBPushButton.
function SendPoseLBPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to SendPoseLBPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.SendPoseLBPushButton,'UserData',1);
% fprintf('move circular is pressed\n')

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Qu1Text_Callback(hObject, eventdata, handles)
% hObject    handle to Qu1Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Qu1Text as text
%        str2double(get(hObject,'String')) returns contents of Qu1Text as a double


% --- Executes during object creation, after setting all properties.
function Qu1Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Qu1Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Qu2Text_Callback(hObject, eventdata, handles)
% hObject    handle to Qu2Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Qu2Text as text
%        str2double(get(hObject,'String')) returns contents of Qu2Text as a double


% --- Executes during object creation, after setting all properties.
function Qu2Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Qu2Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Qu3Text_Callback(hObject, eventdata, handles)
% hObject    handle to Qu3Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Qu3Text as text
%        str2double(get(hObject,'String')) returns contents of Qu3Text as a double


% --- Executes during object creation, after setting all properties.
function Qu3Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Qu3Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Qu4Text_Callback(hObject, eventdata, handles)
% hObject    handle to Qu4Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Qu4Text as text
%        str2double(get(hObject,'String')) returns contents of Qu4Text as a double


% --- Executes during object creation, after setting all properties.
function Qu4Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Qu4Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function JointStatusText_Callback(hObject, eventdata, handles)
% hObject    handle to JointStatusText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of JointStatusText as text
%        str2double(get(hObject,'String')) returns contents of JointStatusText as a double


% --- Executes during object creation, after setting all properties.
function JointStatusText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to JointStatusText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MotionType.
function MotionType_Callback(hObject, eventdata, handles)
% hObject    handle to MotionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MotionType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MotionType

value=get(handles.MotionType,'Value');
switch value 
  case 1
%       fprintf('motion type: Manual\n')
      set(handles.uipanel5,'Visible','on');
      set(handles.uipanel4,'Visible','off');
      set(handles.uipanel6,'Visible','off');
  case 2
%       fprintf('motion type: Set\n')
      set(handles.uipanel5,'Visible','off');
      set(handles.uipanel4,'Visible','on');
      set(handles.uipanel6,'Visible','off');
  case 3      
%       fprintf('motion type: Click and go\n')
      set(handles.uipanel5,'Visible','off');
      set(handles.uipanel4,'Visible','off');
      set(handles.uipanel6,'Visible','on');
      
end 

% --- Executes during object creation, after setting all properties.
function MotionType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MotionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in EnableToPointToggle.
function EnableToPointToggle_Callback(hObject, eventdata, handles)
% hObject    handle to EnableToPointToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % % switch value 
% % %   case 0
% % %       fprintf('Point and Clicked Disabled\n')
% % %   case 1
% % %       fprintf('Point and Clicked Enabled\n')
% % %       load('cameraParamsRoboticsAtt2.mat');
% % % 
% % %       cameraParams = cameraParamsSecondAtt;
% % % 
% % % 
% % %       clickngo = get(handles.EnableToPointToggle,'Value');
% % % 
% % % 
% % %       if clickngo == 1
% % %         
% % % % WITH CAMERA
% % % % % % % % % %     rgbImage = getsnapshot(handles.vid1);
% % % % % % % % % %     undisIm1 = undistortImage(rgbImage,cameraParams);
% % % % % % % % % %     handles.undisIm = undisIm1;
% % % % % % % % % %     si = numel(undisIm1);
% % % 
% % % % % % % % % %     rgbImage2 = getsnapshot(handles.vid2);
% % % % % % % % % %     undisIm2 = undistortImage(rgbImage2,cameraParams);
% % % % % % % % % %     handles.undisIm2 = undisIm2;
% % % % % % % % % %     si2 = numel(undisIm2);
% % % 
% % %         rgbImage1 = handles.vid1;
% % %         undisIm1 = undistortImage(rgbImage1,cameraParams);
% % % 
% % %         rgbImage2 = handles.vid2;
% % %         undisIm2 = undistortImage(rgbImage2,cameraParams);
% % % 
% % % 
% % %         bigFile = cat(2,undisIm1,undisIm2);
% % % 
% % %         handles.EnableToPointToggle.UserData = bigFile;
% % % 
% % %         clickGoGui(hObject,eventdata,handles);
% % % 
% % %         mywindow2 = clickGoGui(hObject,eventdata,handles);
% % %         myhandles2 = guihandles(mywindow2);
% % %       end;


% Hint: get(hObject,'Value') returns toggle state of EnableToPointToggle


% --- Executes on button press in SolenoidRadioButton.
function SolenoidRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to SolenoidRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SolenoidRadioButton
value=get(handles.SolenoidRadioButton,'Value');
if(value==0)
    set(handles.SolenoidRadioButton,'Userdata',0);
else
    set(handles.SolenoidRadioButton,'Userdata',1);
end
% fprintf('Solenoid: %d\n', value)

% --- Executes on button press in CartesianToggleButton.
function CartesianToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to CartesianToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value=get(handles.CartesianToggleButton,'Value');
switch value 
  case 0
%       fprintf('Cartesian Jogging is disabled\n')
      set(handles.JointJoggingToggleButton,'enable','on');
      set(handles.MotionType,'enable','on');
  case 1
%       fprintf('Cartesian Jogging is enabled\n')
      set(handles.uipanel8,'Visible','off');
      set(handles.JointJoggingToggleButton,'enable','off');
      set(handles.MotionType,'enable','off');
      
      
end
% Hint: get(hObject,'Value') returns toggle state of CartesianToggleButton


% --- Executes on button press in JointJoggingToggleButton.
function JointJoggingToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to JointJoggingToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value=get(handles.JointJoggingToggleButton,'Value');
switch value 
  case 0
%       fprintf('Joint Jogging Disabled\n')
      set(handles.uipanel8,'Visible','off');
      set(handles.CartesianToggleButton,'enable','on');
      set(handles.MotionType,'enable','on');
  case 1
%       fprintf('Joint Jogging Enabled\n')
      set(handles.uipanel8,'Visible','on');
      set(handles.CartesianToggleButton,'enable','off');
      set(handles.MotionType,'enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of JointJoggingToggleButton


% --- Executes on button press in J1RadioButton.
function J1RadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to J1RadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j1=get(handles.J1RadioButton,'Value');
j2=get(handles.J2RadioButton,'Value');
j3=get(handles.J3RadioButton,'Value');
j4=get(handles.J4RadioButton,'Value');
j5=get(handles.J5RadioButton,'Value');
j6=get(handles.J6RadioButton,'Value');

fprintf('J1= %d\n',j1)
fprintf('J2= %d\n',j2)
fprintf('J3= %d\n',j3)
fprintf('J4= %d\n',j4)
fprintf('J5= %d\n',j5)
fprintf('J6= %d\n',j6)
% Hint: get(hObject,'Value') returns toggle state of J1RadioButton


% --- Executes on button press in J2RadioButton.
function J2RadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to J2RadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j1=get(handles.J1RadioButton,'Value');
j2=get(handles.J2RadioButton,'Value');
j3=get(handles.J3RadioButton,'Value');
j4=get(handles.J4RadioButton,'Value');
j5=get(handles.J5RadioButton,'Value');
j6=get(handles.J6RadioButton,'Value');

fprintf('J1= %d\n',j1)
fprintf('J2= %d\n',j2)
fprintf('J3= %d\n',j3)
fprintf('J4= %d\n',j4)
fprintf('J5= %d\n',j5)
fprintf('J6= %d\n',j6)
% Hint: get(hObject,'Value') returns toggle state of J2RadioButton


% --- Executes on button press in J3RadioButton.
function J3RadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to J3RadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j1=get(handles.J1RadioButton,'Value');
j2=get(handles.J2RadioButton,'Value');
j3=get(handles.J3RadioButton,'Value');
j4=get(handles.J4RadioButton,'Value');
j5=get(handles.J5RadioButton,'Value');
j6=get(handles.J6RadioButton,'Value');

fprintf('J1= %d\n',j1)
fprintf('J2= %d\n',j2)
fprintf('J3= %d\n',j3)
fprintf('J4= %d\n',j4)
fprintf('J5= %d\n',j5)
fprintf('J6= %d\n',j6)
% Hint: get(hObject,'Value') returns toggle state of J3RadioButton


% --- Executes on button press in J6RadioButton.
function J6RadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to J6RadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j1=get(handles.J1RadioButton,'Value');
j2=get(handles.J2RadioButton,'Value');
j3=get(handles.J3RadioButton,'Value');
j4=get(handles.J4RadioButton,'Value');
j5=get(handles.J5RadioButton,'Value');
j6=get(handles.J6RadioButton,'Value');

fprintf('J1= %d\n',j1)
fprintf('J2= %d\n',j2)
fprintf('J3= %d\n',j3)
fprintf('J4= %d\n',j4)
fprintf('J5= %d\n',j5)
fprintf('J6= %d\n',j6)
% Hint: get(hObject,'Value') returns toggle state of J6RadioButton


% --- Executes on button press in J5RadioButton.
function J5RadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to J5RadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j1=get(handles.J1RadioButton,'Value');
j2=get(handles.J2RadioButton,'Value');
j3=get(handles.J3RadioButton,'Value');
j4=get(handles.J4RadioButton,'Value');
j5=get(handles.J5RadioButton,'Value');
j6=get(handles.J6RadioButton,'Value');

fprintf('J1= %d\n',j1)
fprintf('J2= %d\n',j2)
fprintf('J3= %d\n',j3)
fprintf('J4= %d\n',j4)
fprintf('J5= %d\n',j5)
fprintf('J6= %d\n',j6)
% Hint: get(hObject,'Value') returns toggle state of J5RadioButton


% --- Executes on button press in J4RadioButton.
function J4RadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to J4RadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
j1=get(handles.J1RadioButton,'Value');
j2=get(handles.J2RadioButton,'Value');
j3=get(handles.J3RadioButton,'Value');
j4=get(handles.J4RadioButton,'Value');
j5=get(handles.J5RadioButton,'Value');
j6=get(handles.J6RadioButton,'Value');

fprintf('J1= %d\n',j1)
fprintf('J2= %d\n',j2)
fprintf('J3= %d\n',j3)
fprintf('J4= %d\n',j4)
fprintf('J5= %d\n',j5)
fprintf('J6= %d\n',j6)
% Hint: get(hObject,'Value') returns toggle state of J4RadioButton


% --- Executes on selection change in SetPoseTypePopup.
function SetPoseTypePopup_Callback(hObject, eventdata, handles)
% hObject    handle to SetPoseTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value=get(handles.SetPoseTypePopup,'Value');
switch value 
  case 1
      fprintf('Type end effector location\n')
      set(handles.uipanel10,'Visible','on');
      set(handles.uipanel11,'Visible','off');
  case 2
      fprintf('Type joints angle\n')
      set(handles.uipanel10,'Visible','off');
      set(handles.uipanel11,'Visible','on');      
end 
% Hints: contents = cellstr(get(hObject,'String')) returns SetPoseTypePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SetPoseTypePopup


% --- Executes during object creation, after setting all properties.
function SetPoseTypePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetPoseTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SetSpeedPopUp.
function SetSpeedPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to SetSpeedPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SetSpeedPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SetSpeedPopUp


% --- Executes during object creation, after setting all properties.
function SetSpeedPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SetSpeedPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function camera1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camera1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate camera1


% --- Executes during object creation, after setting all properties.
function camera2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camera2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate camera2

function i1call ( objectHandle , eventData,handles)
% % %    axesHandle  = get(objectHandle,'Parent');
% % %    coordinates = get(axesHandle,'CurrentPoint')
% % %    coordinates = coordinates(1,1:2);
% % %    xCam1 = coordinates(1);
% % %    yCam1 = coordinates(2);
% % %    
% % %    res = [objectHandle.XData(2) objectHandle.YData(2)];
% % %    xmax = 524;
% % %    xmin = -531;
% % %    ymax = 780;
% % %    ymin = -20;
% % % 
% % %    columns = res(1);
% % %    rows = res(2);
% % %     
% % %    realWorldUnitsPerPixel_x = (xmax - xmin)/columns;
% % %    realWorldUnitsPerPixel_y = (ymax - ymin)/rows;
% % %    
% % %    realWorldX = xmin + realWorldUnitsPerPixel_x * xCam1;
% % %    realWorldY = ymin + realWorldUnitsPerPixel_y * yCam1;
% % %    

   
   
   %// then here you can use coordinates as you want ...

function i2call ( objectHandle , eventData )
% % %    axesHandle  = get(objectHandle,'Parent');
% % %    coordinates = get(axesHandle,'CurrentPoint')
% % %    coordinates = coordinates(1,1:2);
% % %    xCam2 = coordinates(1)
% % %    yCam2 = coordinates(2)
   %// then here you can use coordinates as you want ...

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Loading camera params for the snapshotted videofeed (Click and Go)
load('cameraParamsRoboticsAtt2.mat');
cameraParams = cameraParamsSecondAtt;

% When 'Enable To Point' Button is pressed grab screenshot of both video
% feeds, then send into the Click and Go GUI

clickngo = get(handles.pushbutton14,'Value');

if clickngo == 1
       
    fprintf('Point and Clicked Enabled\n');
    
% WITH CAMERA
% % % % % % %     rgbImage = getsnapshot(handles.vid1);
% % % % % % %     undisIm1 = undistortImage(rgbImage,cameraParams);
% % % % % % %     handles.undisIm = undisIm1;
% % % % % % %     si = numel(undisIm1);

% % % % % % %     rgbImage2 = getsnapshot(handles.vid2);
% % % % % % %     undisIm2 = undistortImage(rgbImage2,cameraParams);
% % % % % % %     handles.undisIm2 = undisIm2;
% % % % % % %     si2 = numel(undisIm2);

    % Testing with still camera shots of robot table and conveyer area
    
    rgbImage1 = handles.vid1;
    undisIm1 = undistortImage(rgbImage1,cameraParams);
    
    rgbImage2 = handles.vid2;
    undisIm2 = undistortImage(rgbImage2,cameraParams);

    % Passing the Image by concatenating into one file to send through the
    % button call_back in the next GUI
    
    bigFile = cat(2,undisIm1,undisIm2);
    
    %handles.pushbutton14.UserData = bigFile;
    set(handles.pushbutton14,'UserData',bigFile);
    
    % Opening the Click and Go GUI
    
    clickGoGui(hObject,eventdata,handles);

    % Attempting to grab handles from Click and Go GUI (unsuccessful)
    
    mywindow2 = clickGoGui(hObject,eventdata,handles);
    myhandles2 = guihandles(mywindow2);
    
    
end;
    
