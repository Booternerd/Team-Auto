function snapshotVid(handles)

load('camera1ParamsLightsOn.mat');
cameraParams = camera1ParamsLightsOn;

     
     rgbImage = imread('rgbImage1.png');
     delete('rgbImage1.png');

% Get a snapshot of video feed and undistort the snapshot.

    undisIm1 = undistortImage(rgbImage,cameraParams);
    handles.undisIm = undisIm1;
    si = numel(undisIm1);

    
    rgbImage2 = 1;
    undisIm2 = undistortImage(rgbImage2,cameraParams);
    handles.undisIm2 = undisIm2;
    si2 = numel(undisIm2);

    % Passing the Image by concatenating into one file to send through the
    % button call_back in the next GUI
    
%     bigFile = cat(2,undisIm1,undisIm2);
    
% %     %handles.pushbutton14.UserData = bigFile;
% %     set(handles.EnableToPointToggle,'UserData',bigFile);
% %     
% %     % Opening the Click and Go GUI
% %     
% %     clickGoGui(hObject,eventdata,handles); 

    string = 'loadbox';
    

    AutoMate(undisIm1,undisIm2,string);
    
end