function varargout = cc(varargin)
% CC MATLAB code for cc.fig
%      CC, by itself, creates a new CC or raises the existing
%      singleton*.
%
%      H = CC returns the handle to a new CC or the handle to
%      the existing singleton*.
%
%      CC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CC.M with the given input arguments.
%
%      CC('Property','Value',...) creates a new CC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cc

% Last Modified by GUIDE v2.5 02-Sep-2016 12:39:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cc_OpeningFcn, ...
                   'gui_OutputFcn',  @cc_OutputFcn, ...
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


% --- Executes just before cc is made visible.
function cc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cc (see VARARGIN)

% Choose default command line output for cc
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cc wait for user response (see UIRESUME)
% uiwait(handles.figure1);
axes(handles.axes1);
im = imread('Image1.png');
i1 = imshow(im);
set(i1,'ButtonDownFcn',@i1call);
axes(handles.axes2);
im = imread('gte1.png');
i2 = imshow(im);
set(i2,'ButtonDownFcn',@i2call);

%set(handles.axes1,'WindowButtonDownFcn',@clickgo)

% --- Outputs from this function are returned to the command line.
function varargout = cc_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
handles.axes1
uiwait;


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on mouse press over axes background.
 function axes1_ButtonDownFcn(hObject, eventdata, handles, src)
% % hObject    handle to axes1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% pos= get(hObject,'CurrentPoint')
% 
% hObject
% handles
[x,y] = ginput(1)



function clickgo(hObject,~)

pos= get(hObject,'CurrentPoint')


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

bound = get(handles.axes1,'Position');


% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pos= get(hObject,'CurrentPoint')

function i1call ( objectHandle , eventData )
   axesHandle  = get(objectHandle,'Parent');
   coordinates = get(axesHandle,'CurrentPoint')
   coordinates = coordinates(1,1:2);
   %// then here you can use coordinates as you want ...

function i2call ( objectHandle , eventData )
   axesHandle  = get(objectHandle,'Parent');
   coordinates = get(axesHandle,'CurrentPoint')
   coordinates = coordinates(1,1:2);
   %// then here you can use coordinates as you want ...
