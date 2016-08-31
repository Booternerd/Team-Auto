close all;
clear all;

% Table = 1
% Conveyor = 2
vid1 = videoinput('winvideo', 1, 'RGB24_1600x1200');
% vid2 = videoinput('winvideo', 2, 'RGB24_1600x1200');
figure(1);
preview(vid1);
% figure(2);
% preview(vid2);

for i=1:54
    pause;
    im{i} = getsnapshot(vid1);
    filename = cat(2, 'Image',num2str(i),'.png');
    imwrite(im{i}, filename)
    pause(1);
end
