function snapshotVidoffline()

load('camera1ParamsLightsOn.mat');
cameraParams = camera1ParamsLightsOn;

close(

% Table camera

cam1 = videoinput('winvideo',1,'RGB24_1600x1200');
res = handles.vid1.VideoResolution;
ban = handles.vid1.NumberOfBands;
him = image( zeros(res(2), res(1), ban));


    rgbImage = getsnapshot(cam1);
    undisIm1 = undistortImage(rgbImage,cameraParams);
    handles.undisIm = undisIm1;
    si = numel(undisIm1);

% Get a snapshot of video feed and undistort the snapshot.




    % Passing the Image by concatenating into one file to send through the
    % button call_back in the next GUI
    
%     bigFile = cat(2,undisIm1,undisIm2);
    
% %     %handles.pushbutton14.UserData = bigFile;
% %     set(handles.EnableToPointToggle,'UserData',bigFile);
% %     
% %     % Opening the Click and Go GUI
% %     
% %     clickGoGui(hObject,eventdata,handles); 

%     string = 'loadbox';
    
    imshow(undisIm1);
    
end