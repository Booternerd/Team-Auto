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

% Last Modified by GUIDE v2.5 01-Sep-2016 13:09:55

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

% Choose default command line output for SampleGui
handles.output = hObject;

axes(handles.camera1);
handles.vid1 = videoinput('winvideo', 1, 'RGB24_1600x1200');
res = handles.vid1.VideoResolution;
ban = handles.vid1.NumberOfBands;
him = image( zeros(res(2), res(1), ban));
handles.v1h = him;
preview(handles.vid1, handles.v1h);
axes(handles.camera2);
handles.vid2 = videoinput('winvideo', 2, 'RGB24_1600x1200');
res = handles.vid2.VideoResolution;
ban = handles.vid2.NumberOfBands;
him = image( zeros(res(2), res(1), ban));
handles.v2h = him;
preview(handles.vid2, handles.v2h);

% set(handles.vid1,'TimerPeriod', 0.05, ...
%       'TimerFcn',['if(~isempty(gco)),'...
%       'handles=guidata(gcf);'...                                 
%       'image(getsnapshot(handles.video));'...  
%       'set(handles.cameraAxes,''ytick'',[],''xtick'',[]),'...
%       'else ' 'delete(imaqfind);' 'end']);
% triggerconfig(handles.vid1, 'manual');
% triggerconfig(handles.vid2, 'manual');
% handles.vid1.FramesPerTrigger = Inf;
% start(handles.vid1);
% trigger(handles.vid1);
% Update handles structure
guidata(hObject, handles);
set(handles.ExitButton,'UserData',0)
set(handles.ConnectSocketPushButton,'UserData',0)
set(handles.SendString,'UserData',0)
set(handles.SocketNumberEditText,'string','');
set(handles.SendStringEditText,'string','');
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
delete(imaqfind);

%%########################################################################
% --- Executes on button press in SendString.
function SendString_Callback(hObject, eventdata, handles)
% hObject    handle to SendString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.SendString,'UserData',1)
display('Send String Button is pressed')


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
display('ConnectSocket Button is pressed')


function SocketNumberEditText_Callback(hObject, eventdata, handles)
% hObject    handle to SocketNumberEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SocketNumberEditText as text
%        str2double(get(hObject,'String')) returns contents of SocketNumberEditText as a double
str2double(get(hObject,'String'))
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
display('String has been inputted. Pressed "Send String button" to send it to RAPID');

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


% --- Executes on button press in VacuumRadioButton.
function VacuumRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to VacuumRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VacuumRadioButton


% --- Executes on button press in ConveyorRadioButton.
function ConveyorRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to ConveyorRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ConveyorRadioButton


% --- Executes on button press in ConveyorDirectionPushButton.
function ConveyorDirectionPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to ConveyorDirectionPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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



function Q2Text_Callback(hObject, eventdata, handles)
% hObject    handle to Q2Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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


% --- Executes on button press in JoggingRadioButton.
function JoggingRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to JoggingRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of JoggingRadioButton


% --- Executes on selection change in MotionType.
function MotionType_Callback(hObject, eventdata, handles)
% hObject    handle to MotionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MotionType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MotionType


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


% --- Executes on button press in JoggingToggleButton.
function JoggingToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to JoggingToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of JoggingToggleButton


% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton3


% --- Executes on button press in SolenoidRadioButton.
function SolenoidRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to SolenoidRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SolenoidRadioButton


% --- Executes on button press in CartesianToggleButton.
function CartesianToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to CartesianToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CartesianToggleButton


% --- Executes on button press in JointJoggingToggleButton.
function JointJoggingToggleButton_Callback(hObject, eventdata, handles)
% hObject    handle to JointJoggingToggleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of JointJoggingToggleButton


% --- Executes on button press in J1RadioButton.
function J1RadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to J1RadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of J1RadioButton


% --- Executes on button press in radiobutton6.
function radiobutton6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton6


% --- Executes on button press in J2RadioButton.
function J2RadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to J2RadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of J2RadioButton


% --- Executes on button press in J3RadioButton.
function J3RadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to J3RadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of J3RadioButton


% --- Executes on button press in J6RadioButton.
function J6RadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to J6RadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of J6RadioButton


% --- Executes on button press in J5RadioButton.
function J5RadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to J5RadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of J5RadioButton


% --- Executes on button press in J4RadioButton.
function J4RadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to J4RadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of J4RadioButton


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
