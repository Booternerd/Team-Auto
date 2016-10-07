function varargout = GUI_checklist(varargin)
% GUI_CHECKLIST MATLAB code for GUI_checklist.fig
%      GUI_CHECKLIST, by itself, creates a new GUI_CHECKLIST or raises the existing
%      singleton*.
%
%      H = GUI_CHECKLIST returns the handle to a new GUI_CHECKLIST or the handle to
%      the existing singleton*.
%
%      GUI_CHECKLIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_CHECKLIST.M with the given input arguments.
%
%      GUI_CHECKLIST('Property','Value',...) creates a new GUI_CHECKLIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_checklist_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_checklist_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_checklist

% Last Modified by GUIDE v2.5 07-Oct-2016 10:59:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_checklist_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_checklist_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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




% --- Executes just before GUI_checklist is made visible.
function GUI_checklist_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_checklist (see VARARGIN)

% Choose default command line output for GUI_checklist
handles.guifig = gcf;
movegui(handles.guifig,'center');
guidata(handles.guifig,handles);

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);





% UIWAIT makes GUI_checklist wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_checklist_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure
varargout{1} = handles.output;


set(handles.guifig,'WindowStyle','Modal');




% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

s1 = get(handles.checkbox1,'Value');
s2 = get(handles.checkbox2,'Value');
s3 = get(handles.checkbox3,'Value');
s4 = get(handles.checkbox4,'Value');
s5 = get(handles.checkbox5,'Value');
s6 = get(handles.checkbox6,'value');

if s1*s2*s3*s4*s5*s6 == 1
    set(handles.pushbutton1,'Visible','On');
else
    set(handles.pushbutton1,'Visible','Off');
end

if s1 == 1
    set(handles.uipanel1,'BackgroundColor',[0.6000 1 0.6000]);
else
    set(handles.uipanel1,'BackgroundColor','r');
end;


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2

s1 = get(handles.checkbox1,'Value');
s2 = get(handles.checkbox2,'Value');
s3 = get(handles.checkbox3,'Value');
s4 = get(handles.checkbox4,'Value');
s5 = get(handles.checkbox5,'Value');
s6 = get(handles.checkbox6,'value');

if s1*s2*s3*s4*s5*s6 == 1
    set(handles.pushbutton1,'Visible','On');
else
    set(handles.pushbutton1,'Visible','Off');
end

if s2 == 1
    set(handles.uipanel2,'BackgroundColor',[0.6000 1 0.6000]);
else
    set(handles.uipanel2,'BackgroundColor','r');
end;

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3

s1 = get(handles.checkbox1,'Value');
s2 = get(handles.checkbox2,'Value');
s3 = get(handles.checkbox3,'Value');
s4 = get(handles.checkbox4,'Value');
s5 = get(handles.checkbox5,'Value');
s6 = get(handles.checkbox6,'value');

if s1*s2*s3*s4*s5*s6 == 1
    set(handles.pushbutton1,'Visible','On');
else
    set(handles.pushbutton1,'Visible','Off');
end

if s3 == 1
    set(handles.uipanel3,'BackgroundColor',[0.6000 1 0.6000]);
else
    set(handles.uipanel3,'BackgroundColor','r');
end;

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4

s1 = get(handles.checkbox1,'Value');
s2 = get(handles.checkbox2,'Value');
s3 = get(handles.checkbox3,'Value');
s4 = get(handles.checkbox4,'Value');
s5 = get(handles.checkbox5,'Value');
s6 = get(handles.checkbox6,'value');

if s1*s2*s3*s4*s5*s6 == 1
    set(handles.pushbutton1,'Visible','On');
else
    set(handles.pushbutton1,'Visible','Off');
end

if s4 == 1
    set(handles.uipanel4,'BackgroundColor',[0.6000 1 0.6000]);
else
    set(handles.uipanel4,'BackgroundColor','r');
end;




% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5

s1 = get(handles.checkbox1,'Value');
s2 = get(handles.checkbox2,'Value');
s3 = get(handles.checkbox3,'Value');
s4 = get(handles.checkbox4,'Value');
s5 = get(handles.checkbox5,'Value');
s6 = get(handles.checkbox6,'value');

if s1*s2*s3*s4*s5*s6 == 1
    set(handles.pushbutton1,'Visible','On');
else
    set(handles.pushbutton1,'Visible','Off');
end

if s5 == 1
    set(handles.uipanel5,'BackgroundColor',[0.6000 1 0.6000]);
else
    set(handles.uipanel5,'BackgroundColor','r');
end;

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6

s1 = get(handles.checkbox1,'Value');
s2 = get(handles.checkbox2,'Value');
s3 = get(handles.checkbox3,'Value');
s4 = get(handles.checkbox4,'Value');
s5 = get(handles.checkbox5,'Value');
s6 = get(handles.checkbox6,'value');

if s1*s2*s3*s4*s5*s6 == 1
    set(handles.pushbutton1,'Visible','On');
else
    set(handles.pushbutton1,'Visible','Off');
end

if s6 == 1
    set(handles.uipanel6,'BackgroundColor',[0.6000 1 0.6000]);
else
    set(handles.uipanel6,'BackgroundColor','r');
end;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%hObject
% eventdata
% handles

p1 = get(handles.pushbutton1,'Value');

%fprintf('Value = %d\n',p1);

if p1 == 1
    %set(handles.figure1,'Visible','Off');
    delete(handles.figure1);
else
    %set(handles.figure1,'Visible','On');
end;

    


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%delete(hObject);
