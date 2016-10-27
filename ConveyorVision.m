% Conveyor Robot Vision Code
% Function: Identifies the jengas, box and 4 position b1-b4.
% Input = Conveyor image. i.e. 'image1.jpg'
% 
% Requirements= c2g2.mat
%               CameraParamsRoboticsAtt2.mat
%               Peter Chorke's robot vision toolbox
% 
% Outputs = 2 global variables -> output, box
% 
% global output -> struct that consist all the position x,y,z in mm of the
% jengas, their orientations, and their faces
% 
% global output =   global.x= x position of the jengas
%                   global.y= y position of the jengas
%                   global.z= z position of the jengas
%                   global.a= Orientation of the jengas
%                   global.f= Face of the jengas
% 
% global box --> contains the box and position b1-b4 properties
% 
% global box =  global.x= x position of the box
%               global.y= y position of the box
%               global.z= z position of the box
%               global.a= Orientation of the box
%                                       
%               global.b# = [b# x position; %<-- a struct
%                            b# y position;
%                            b# z position;
%                            b# orientation;
%                            b# face;];

function ConveyorVision(image)
%     close all; clear;
%     image_file_path='C:\Users\jeffry\Documents\UNSW\SEMESTER_2_2016\MTRN4230\MATLAB\Assignment1\Training_Images\gte2.png';
    image_file_path=image;
    im = imread(image_file_path);
    data=load('CameraParamsRoboticsAtt2.mat');
    undistort=undistortImage(im,data.cameraParamsSecondAtt);
    im=undistort;
%     run('C:\Users\jeffry\Documents\UNSW\SEMESTER_2_2016\MTRN4230\vision-3.4\rvctools\startup_rvc.m')
    detect(im);

end
    % Your jenga detection.
function detect(im)
    global output;
    output.x=[];
    output.y=[];
    output.z=[];
    output.a=[];
    output.f=[];
%     output.theta=[];
    
    global box;
    box.x=[];
    box.y=[];
    box.z=[];
    box.a=[];
    box.b1=[];
    box.b2=[];
    box.b3=[];
    box.b4=[];
    box.box_height=32.1;
    
    % Do your image processing...
    im(:,1:567,:)=0;
    im(:,1162:end,:)=0;
    im(711:end,:,:)=0;
%     imshow(im)
    [JengaBW,RGB]=JengaMask(im);
    [BoxBW,~]=BoxMask(im);
%     imshow(RGB2)
    detectJenga(JengaBW,RGB);
    detectBox(BoxBW);
    
    convert_pixels_to_mm();
end
function detectBox(BW)
	global box;
    
    closed2 = iclose(BW, kcircle(5));

%     figure; idisp(closed2);
%     ib=iblobs(eroded,'boundary','class',0,'area',[500,15000]);
    ib=iblobs(closed2,'boundary','class',0,'touch',0,'area',[50000,100000]);
%     ib.plot_boundary('g');
%     ib.plot('*b')
    uc=ib.uc_;
    vc=ib.vc_;
    theta=ib.theta_;
    theta=theta2angle(theta);
    jenga_theta=theta+1/2*pi;
%     hold on;

    box.x=ib.uc_;
    box.y=ib.vc_;
    box.a=theta;
    
    constant=36;
    box.b1=[uc+constant*cos(theta);vc+constant*sin(theta);box.box_height;jenga_theta;1];
    box.b2=[uc+3*constant*cos(theta);vc+3*constant*sin(theta);box.box_height;jenga_theta;1];
    box.b3=[uc-constant*cos(theta);vc-constant*sin(theta);box.box_height;jenga_theta;1];
    box.b4=[uc-3*constant*cos(theta);vc-3*constant*sin(theta);box.box_height;jenga_theta;1];
%     plot(box.b1(1),box.b1(2),'*y');
%     plot(box.b2(1),box.b2(2),'*y');
%     plot(box.b3(1),box.b3(2),'*y');
%     plot(box.b4(1),box.b4(2),'*y');
    
end

function detectJenga(BW,RGB)
    global output;
    S = kcircle(2);
    closed2 = iclose(BW, S);%figure; idisp(closed2);
    clean = iopen(closed2, S);%figure; idisp(clean);
    eroded = imorph(clean, kcircle(2), 'min');%figure; idisp(eroded); 
    eroded=logical(eroded);
    ib=iblobs(eroded,'boundary','class',1,'area',[500,15000]);
    if (isempty(ib)==1)  
    else
        for ii=1:length(ib.uc)
            if(ib(ii).area<800)
                theta=ib(ii).theta_;
                uc=ib(ii).uc;
                vc=ib(ii).vc;
                angle=theta2angle(theta);
                label=3;
                output.x=[output.x uc];
                output.y=[output.y vc];
                output.a=[output.a angle];
                output.f=[output.f label];
%                 output.theta=[output.theta theta];
            elseif(ib(ii).area>1800 && (ib(ii).b/ib(ii).a)>0.4)
                crop=iroi(RGB,[ib(ii).umin-10 ib(ii).umax+10; ib(ii).vmin-10, ib(ii).vmax+10]);
                occluded_separation2(crop,ib(ii).umin-10,ib(ii).vmin-10);
            else
                theta=ib(ii).theta_;
                uc=ib(ii).uc;
                vc=ib(ii).vc;
                angle=theta2angle(theta);

                crop=iroi(RGB,[ib(ii).umin-10 ib(ii).umax+10; ib(ii).vmin-10, ib(ii).vmax+10]);
                size=side_analysis(crop,ib(ii).area,uc,vc,ib(ii).umin-10,ib(ii).vmin-10);
                if(size==1)
                    label=1;
                elseif(size>1 ||size==0)
                    label=2;
                end
                output.x=[output.x uc];
                output.y=[output.y vc];
                output.a=[output.a angle];
                output.f=[output.f label];
%                 output.theta=[output.theta theta];
            end
        end
    end

end
function convert_pixels_to_mm()
    global box;
    global output;
    load('c2g2.mat');   
    %% Jengas
    xt = xv + output.x*cos(CAng) + output.y*sin(CAng);
    yt = yv + output.y*cos(CAng) - output.x*sin(CAng);
    
    xt2 = xv + xoC*cos(CAng) + output.y.*sin(CAng);
    yt2 = yv + yoC*cos(CAng) - output.x.*sin(CAng);

    output.x = (xt - xt2).*xp2mmC;
    output.y = (yt - yt2).*yp2mmC;
    output.z = ones(1,length(output.x)).*32.1;
    %% box
    xt = xv + box.x*cos(CAng) + box.y*sin(CAng);
    yt = yv + box.y*cos(CAng) - box.x*sin(CAng);
    
    xt2 = xv + xoC*cos(CAng) + box.y.*sin(CAng);
    yt2 = yv + yoC*cos(CAng) - box.x.*sin(CAng);

    box.x = (xt - xt2).*xp2mmC;
    box.y = (yt - yt2).*yp2mmC;
    box.z = ones(1,length(box.x)).*box.box_height;
    %% b1
    xt = xv + box.b1(1)*cos(CAng) + box.b1(2)*sin(CAng);
    yt = yv + box.b1(2)*cos(CAng) - box.b1(1)*sin(CAng);
    
    xt2 = xv + xoC*cos(CAng) + box.b1(2).*sin(CAng);
    yt2 = yv + yoC*cos(CAng) - box.b1(1).*sin(CAng);

    box.b1(1) = (xt - xt2).*xp2mmC;
    box.b1(2) = (yt - yt2).*yp2mmC;
    %% b2
    xt = xv + box.b2(1)*cos(CAng) + box.b2(2)*sin(CAng);
    yt = yv + box.b2(2)*cos(CAng) - box.b2(1)*sin(CAng);
    
    xt2 = xv + xoC*cos(CAng) + box.b2(2).*sin(CAng);
    yt2 = yv + yoC*cos(CAng) - box.b2(1).*sin(CAng);

    box.b2(1) = (xt - xt2).*xp2mmC;
    box.b2(2) = (yt - yt2).*yp2mmC;
    %% b3
    xt = xv + box.b3(1)*cos(CAng) + box.b3(2)*sin(CAng);
    yt = yv + box.b3(2)*cos(CAng) - box.b3(1)*sin(CAng);
    
    xt2 = xv + xoC*cos(CAng) + box.b3(2).*sin(CAng);
    yt2 = yv + yoC*cos(CAng) - box.b3(1).*sin(CAng);

    box.b3(1) = (xt - xt2).*xp2mmC;
    box.b3(2) = (yt - yt2).*yp2mmC;
    %% b4
    xt = xv + box.b4(1)*cos(CAng) + box.b4(2)*sin(CAng);
    yt = yv + box.b4(2)*cos(CAng) - box.b4(1)*sin(CAng);
    
    xt2 = xv + xoC*cos(CAng) + box.b4(2).*sin(CAng);
    yt2 = yv + yoC*cos(CAng) - box.b4(1).*sin(CAng);

    box.b4(1) = (xt - xt2).*xp2mmC;
    box.b4(2) = (yt - yt2).*yp2mmC;
end

function [BW,maskedRGBImage] = BoxMask(RGB)

    % Convert RGB image to chosen color space
    I = rgb2hsv(RGB);

    % Define thresholds for channel 1 based on histogram settings
    channel1Min = 0.003;
    channel1Max = 0.088;

    % Define thresholds for channel 2 based on histogram settings
    channel2Min = 0.292;
    channel2Max = 1.000;

    % Define thresholds for channel 3 based on histogram settings
    channel3Min = 0.000;
    channel3Max = 1.000;

    % Create mask based on chosen histogram thresholds
    BW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
        (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
        (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);

    % Initialize output masked image based on input image.
    maskedRGBImage = RGB;

    % Set background pixels where BW is false to zero.
    maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
function [BW,maskedRGBImage] = JengaMask(RGB)
    % Convert RGB image to chosen color space
    I = rgb2hsv(RGB);

    % Define thresholds for channel 1 based on histogram settings
    channel1Min = 0.068;
    channel1Max = 0.135;
%     channel1Min = 0.089;
%     channel1Max = 0.181;

    % Define thresholds for channel 2 based on histogram settings
    channel2Min = 0.232;
    channel2Max = 0.562;
%     channel2Min = 0.199;
%     channel2Max = 1.000;

    % Define thresholds for channel 3 based on histogram settings
%     channel3Min = 0.417;
%     channel3Max = 0.770;
    channel3Min = 0.000;
    channel3Max = 1.000;
    % Create mask based on chosen histogram thresholds
    BW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
        (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
        (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);

    % Initialize output masked image based on input image.
    maskedRGBImage = RGB;

    % Set background pixels where BW is false to zero.
    maskedRGBImage(repmat(~BW,[1 1 3])) = 0;
    
end

function ret=theta2angle(theta)
    angle=theta*-1;
%     plot([uc,uc+cos(theta).*100],[vc,vc+sin(theta).*100],'Color','r','LineWidth',2)
    if (angle>pi/2) %2
        angle= -(pi-abs(angle));
    elseif (angle<-pi/2) %3
        angle= (pi-abs(angle));
    end
    ret=angle;
end
function side=side_analysis(crop,area,x1,y1,xmin,ymin)

    gray=rgb2gray(crop);
    gray = imorph(gray, kcircle(3), 'min');
    gray=im2bw(gray);
    out=gray;
    ib2=iblobs((out),'boundary','area',[200,10000],'class',1,'touch',0);   
    if(length(ib2)==1)
        a=ib2.area;
        dif_Area=abs(a-area);
        x2=ib2.uc+xmin;
        y2=ib2.vc+ymin;
        dif_centroid=sqrt((x2-x1)^2+(y2-y1)^2);
        if(dif_Area>500 && dif_centroid>1.8)
            side=2;
        else
            side=1;
        end
    else  
        side=length(ib2);
    end
end

function occluded_separation2(im,umin,vmin)
    global output;
    gray=rgb2gray(im);
    gray = imorph(gray, kcircle(3), 'min');
    hy = fspecial('sobel');
    hx = hy';
    Iy = imfilter(double(gray), hy, 'replicate');
    Ix = imfilter(double(gray), hx, 'replicate');
    gradmag = sqrt(Ix.^2 + Iy.^2);  

    inline=gradmag;
    inline((gradmag>800 | gradmag<100))=0;
    inline(~(gradmag>800 | gradmag<100))=1;
    
    out=inline;

    blobs=iblobs((out),'boundary','area',[200,5000],'class',0,'touch',0);
%     flag_side=0;
    k=[];
    if(isempty(blobs)==1)
        return
    end
    for i=1:length(blobs.uc)
        for j=1:length(blobs.uc)
            if(j~=i && ismember(j,k)~=1)
                areadif=abs(blobs(i).area-blobs(j).area);
                ang1=theta2angle(blobs(i).theta_);
                ang2=theta2angle(blobs(j).theta_);
                thetadif=abs(ang2-ang1)*180/pi;
                if(areadif<150 && thetadif<10 && blobs(j).area<500)
                    k=[k i j];
                    [uc, vc]=middle_point(blobs(i).uc,blobs(i).vc,blobs(j).uc,blobs(j).vc);
                    uc=umin+ uc;
                    vc=vmin+ vc;
                    label=2;
                    angle=mean([ang1,ang2]);
                    
                    output.x=[output.x uc];
                    output.y=[output.y vc];
                    output.a=[output.a angle];
                    output.f=[output.f label];
%                     output.theta=[output.theta theta];
                end
            end
        end
    end
    for i=1:length(blobs.uc)
        if(ismember(i,k)~=1)
            if(blobs(i).area>1500)
                label=1;
            else
                label=3;
            end
            uc=umin+ blobs(i).uc;
            vc=vmin+ blobs(i).vc;
            theta= blobs(i).theta_;
            angle=theta2angle(theta);
            output.x=[output.x uc];
            output.y=[output.y vc];
            output.a=[output.a angle];
            output.f=[output.f label];
%             output.theta=[output.theta theta];
        end
    end 
end
function [x,y]=middle_point(x1,y1,x2,y2)
    x=(x1+x2)/2;
    y=(y1+y2)/2;
end