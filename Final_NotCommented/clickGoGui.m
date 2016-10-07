function varargout = clickGoGui(varargin)
% CLICKGOGUI MATLAB code for clickGoGui.fig
%      CLICKGOGUI, by itself, creates a new CLICKGOGUI or raises the existing
%      singleton*.
%
%      H = CLICKGOGUI returns the handle to a new CLICKGOGUI or the handle to
%      the existing singleton*.
%
%      CLICKGOGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLICKGOGUI.M with the given input arguments.
%
%      CLICKGOGUI('Property','Value',...) creates a new CLICKGOGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before clickGoGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to clickGoGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help clickGoGui

% Last Modified by GUIDE v2.5 06-Oct-2016 17:09:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @clickGoGui_OpeningFcn, ...
                   'gui_OutputFcn',  @clickGoGui_OutputFcn, ...
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


% --- Executes just before clickGoGui is made visible.
function clickGoGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to clickGoGui (see VARARGIN)

% Choose default command line output for clickGoGui
handles.output = hObject;
handles.input1 = varargin{1};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes clickGoGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% imtot = handles.input1.UserData;
imtot = get(handles.input1,'UserData');

[Xres,Yres] = size(imtot);

% im1R = handles.input1.UserData(1:Xres, 1:(Yres/6));
% im2R = handles.input1.UserData(1:Xres, ((Yres/6)+1):(2*Yres/6));
% im1G = handles.input1.UserData(1:Xres, ((2*Yres/6)+1):(3*Yres/6));
% im2G = handles.input1.UserData(1:Xres, ((3*Yres/6)+1):(4*Yres/6));
% im1B = handles.input1.UserData(1:Xres, ((4*Yres/6)+1):(5*Yres/6));
% im2B = handles.input1.UserData(1:Xres, ((5*Yres/6)+1):(6*Yres/6));

im1R = imtot(1:Xres, 1:(Yres/6));
im2R = imtot(1:Xres, ((Yres/6)+1):(2*Yres/6));
im1G = imtot(1:Xres, ((2*Yres/6)+1):(3*Yres/6));
im2G = imtot(1:Xres, ((3*Yres/6)+1):(4*Yres/6));
im1B = imtot(1:Xres, ((4*Yres/6)+1):(5*Yres/6));
im2B = imtot(1:Xres, ((5*Yres/6)+1):(6*Yres/6));


im1(:,:,1) = im1R;
im1(:,:,2) = im1G;
im1(:,:,3) = im1B;

im2(:,:,1) = im2R;
im2(:,:,2) = im2G;
im2(:,:,3) = im2B;

% im1 = handles.input1.UserData(1:Xres, 1:(Yres/2));
% im2 = handles.input1.UserData(1:Xres, ((Yres/2)+1):end);

% im1 = handles.input1.UserData(1:480, 1:640);
% im2 = handles.input1.UserData(1:480, 641:1280);

axes(handles.axes1);
i1 = imshow(im1);
set(i1,'ButtonDownFcn',@i1call);

axes(handles.axes2);
i2 = imshow(im2);
set(i2,'ButtonDownFcn',@i2call);

set(handles.WarningText,'String',' ')

 
% set(myhandles,'toolbar','figure');
% set(myhandles,'menubar','figure');

% --- Outputs from this function are returned to the command line.
function varargout = clickGoGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function i1call ( objectHandle , eventData,handles)
   axesHandle  = get(objectHandle,'Parent');
   coordinates = get(axesHandle,'CurrentPoint');
   coordinates = coordinates(1,1:2);
   xCam1 = coordinates(1);
   yCam1 = coordinates(2);
   
%    res = [objectHandle.XData(2) objectHandle.YData(2)];
%    xmax = 524;
%    xmin = -531;
%    ymax = 780;
%    ymin = -20;
% 
%    columns = res(1);
%    rows = res(2);
%     
%    realWorldUnitsPerPixel_x = (xmax - xmin)/columns;
%    realWorldUnitsPerPixel_y = (ymax - ymin)/rows;
%    
%    realWorldX = xmin + realWorldUnitsPerPixel_x * xCam1;
%    realWorldY = ymin + realWorldUnitsPerPixel_y * yCam1;
%    realCord = [realWorldX, realWorldY];

   % reachability check here
   
   reachable = reachabilityCheck(xCam1,yCam1);

   if (reachable == 1)
       realCord = [xCam1,yCam1];

       fileID = fopen('output_files/coordinates.txt','w');
       fprintf(fileID,'%.6f %.6f\n',realCord);
       fclose(fileID);
       
       close('clickGoGui');

       fileID = fopen('output_files/i1pressed.txt','w');
       fclose(fileID);
       fileID = fopen('output_files/reachable.txt','w');
       fprintf(fileID,'%d\n',reachable);
       fclose(fileID);
   end;
   if (reachable == 0)
        fprintf('Coordinates selected unreachable\n');
        if exist('output_files/coordinates.txt')
            delete('output_files/coordinates.txt');
        end;
    
        if exist('output_files/i1pressed.txt')
            delete('output_files/i1pressed.txt');
        end;
    
        if exist('output_files/i2pressed.txt')
            delete('output_files/i2pressed.txt');
        end;
        fileID = fopen('output_files/reachable.txt','w');
        fprintf(fileID,'%d\n',reachable);
        fclose(fileID);
        close('clickGoGui');
   end;
   
   
   
   %// then here you can use coordinates as you want ...

function i2call ( objectHandle , eventData,handles )
   axesHandle  = get(objectHandle,'Parent');
   coordinates = get(axesHandle,'CurrentPoint');
   coordinates = coordinates(1,1:2);
   xCam2 = coordinates(1);
   yCam2 = coordinates(2);
   
   % reachability check here
   
   reachable = reachabilityCheck2(xCam2,yCam2);

   if (reachable == 1)
       realCord = [xCam2,yCam2];

       fileID = fopen('output_files/coordinates.txt','w');
       fprintf(fileID,'%.6f %.6f\n',realCord);
       fclose(fileID);
       
       close('clickGoGui');

       fileID = fopen('output_files/i2pressed.txt','w');
       fclose(fileID);
       fileID = fopen('output_files/reachable.txt','w');
       fprintf(fileID,'%d\n',reachable);
       fclose(fileID);
   end;
   if (reachable == 0)
        fprintf('Coordinates selected unreachable\n');
        if exist('output_files/coordinates.txt')
            delete('output_files/coordinates.txt');
        end;
    
        if exist('output_files/i1pressed.txt')
            delete('output_files/i1pressed.txt');
        end;
    
        if exist('output_files/i2pressed.txt')
            delete('output_files/i2pressed.txt');
        end;
        fileID = fopen('output_files/reachable.txt','w');
        fprintf(fileID,'%d\n',reachable);
        fclose(fileID);
        close('clickGoGui');
   end;
   %// then here you can use coordinates as you want ...


% % % --------------------------------------------------------------------
% % function Untitled_1_Callback(hObject, eventdata, handles)
% % % hObject    handle to Untitled_1 (see GCBO)
% % % eventdata  reserved - to be defined in a future version of MATLAB
% % % handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function WarningText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WarningText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close('clickGoGui');
