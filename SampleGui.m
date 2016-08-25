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

% Last Modified by GUIDE v2.5 25-Aug-2016 22:02:13

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

% Update handles structure
guidata(hObject, handles);
set(handles.ExitButton,'UserData',0)
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