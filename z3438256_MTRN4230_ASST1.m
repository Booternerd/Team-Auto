% An example of how your function will be called, and what it should
% output.
% image_file_path is the absolute path to the image that you should
% process. This should be used to read in the file.
% image_file_name is just the name of the image. This should be written to
% the output file.
% output_file_path is the absolute path to the file where you should output
% the name of the file as well as the chocolates that you have detected.
% program_folder is the folder that your function is running in.

function z3438256_MTRN4230_ASST1(image_file_path, image_file_name, ...
    output_file_path, program_folder)

    im = imread(image_file_path);
    
    jengas = detect_jengas(im);

    write_output_file(jengas, image_file_name, output_file_path);
end
    % Your jenga detection.
function c = detect_jengas(im)
    global output;
    output.x=[];
    output.y=[];
    output.a=[];
    output.f=[];
    output.r=[];
%     output.theta=[];
    % Do your image processing...
    im(1:220,:,:)=0;
%     im = imrotate(im,180);
%     im(end-220:end,:,:)=0;
    [BW,RGB]=ImageMask1(im);
    BW=imcomplement(BW);
    
    
    S = kcircle(3);
    closed2 = iclose(BW, S);
    clean = iopen(closed2, S);
    eroded = imorph(clean, kcircle(3), 'min');
    
    eroded=logical(eroded);
    gray=rgb2gray(RGB);
    gray(eroded)=0;
    
    BW1 = edge(gray,'Canny',[0.000 0.4]);
    morph=bwmorph(imcomplement(BW1),'remove');
    closed2= iclose(morph, kcircle(3));
    closed2(1:5,:)=0;
    closed2(end-5:end,:)=0;
    closed2(:,1:5)=0;
    closed2(:,end-5:end)=0;

%%=========================================================================    
    ib=iblobs(closed2,'boundary','class',0,'area',[500,15000]);
%     ib.display; 
    
    hold on
    [c,r]=circle(798,40,830);
    

    for i=1:length(ib.uc)
        if(ib(i).area<1800)
            crop=iroi(gray,[ib(i).umin-10 ib(i).umax+10; ib(i).vmin-10, ib(i).vmax+10]);
            blobs=top_analysis(crop);
            if(isempty(blobs)~=1)
                %  blobs.plot_boundary('g');ib.plot_box('y');ib.plot('*b');
                uc=ib(i).umin-10+ blobs.uc;
                vc=ib(i).vmin-10+ blobs.vc;
                theta= blobs.theta_;
                angle=theta2angle(theta);
                label=3;
            else
%                 ib.plot_boundary('g');ib.plot_box('y');ib.plot('*b');
                theta=ib(i).theta_;
                uc=ib(i).uc;
                vc=ib(i).vc;
                angle=theta2angle(theta);
                label=3;
            end
            reachability = inpolygon(uc,vc,c,r);
            output.x=[output.x uc];
            output.y=[output.y vc];
            output.a=[output.a angle];
            output.f=[output.f label];
            output.r=[output.r reachability];
%             output.theta=[output.theta theta];
%=========================================================================
        elseif(ib(i).area>5000 || (ib(i).b/ib(i).a)>0.4)
            crop=iroi(gray,[ib(i).umin-10 ib(i).umax+10; ib(i).vmin-10, ib(i).vmax+10]);
            occluded_separation2(crop,ib(i).umin-10,ib(i).vmin-10,c,r);
        else
%             ib.plot_boundary('g');ib.plot_box('y');ib.plot('*b');
            theta=ib(i).theta_;
            uc=ib(i).uc;
            vc=ib(i).vc;
            angle=theta2angle(theta);
            
            crop=iroi(gray,[ib(i).umin-10 ib(i).umax+10; ib(i).vmin-10, ib(i).vmax+10]);
            size=side_analysis(crop,ib(i).area,uc,vc,ib(i).umin-10,ib(i).vmin-10);
            if(size==1)
                label=1;
            elseif(size>1 ||size==0)
                label=2;
            end
            reachability = inpolygon(uc,vc,c,r);
            output.x=[output.x uc];
            output.y=[output.y vc];
            output.a=[output.a angle];
            output.f=[output.f label];
            output.r=[output.r reachability];
%             output.theta=[output.theta theta];
        end
    end

%%=========================================================================  
    
    mat=[output.x; 1200-output.y; output.a;output.f;output.r]';
%     figure(2)
%     idisp(closed2)
%     for i=1:length(mat)
%         plot([output.x(i),output.x(i)+cos(output.theta(i)).*100],...
%             [output.y(i),output.y(i)+sin(output.theta(i)).*100],'Color','r','LineWidth',2);
%         plot(output.x(i),output.y(i),'*g');
%     end
%==========================================================================    
    % You may store your results in matrix as shown below.
    %    X    Y    Theta Face 	1 = Reachable
    %                               0 = Not reachable
    c = mat;

     % This is an example of how to write the results to file.
     % This will only work if you store your jengas exactly as above.
     % Please ensure that you output your detected jengas correctly. A
     % script will be made available so that you can run the comparison
     % yourselves, to test that it is working.
end
function write_output_file(jengas, image_file_name, output_file_path)

    fid = fopen(output_file_path, 'w');

    fprintf(fid, 'image_file_name:\n');
    fprintf(fid, '%s\n', image_file_name);
    fprintf(fid, 'rectangles:\n');
    fprintf(fid, ...
            [repmat('%f ', 1, size(jengas, 2)), '\n'], jengas');

    % Please ensure that you close any files that you open. If you fail to do
    % so, there may be a noticeable decrease in the speed of your processing.
    fclose(fid);
end

function [BW,maskedRGBImage] = ImageMask1(RGB)

    % Convert RGB image to chosen color space
    I = rgb2hsv(RGB);

    % Define thresholds for channel 1 based on histogram settings
    channel1Min = 0.00;
    channel1Max = 1.000;

    % Define thresholds for channel 2 based on histogram settings
    channel2Min = 0.274;
    channel2Max = 1.000;

    % Define thresholds for channel 3 based on histogram settings
    channel3Min = 0.198;
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

function [c,r]=circle(x,y,r)
    %x and y are the coordinates of the center of the circle
    %r is the radius of the circle
    ang=(17*pi/180):0.01:pi-(17*pi/180); 
    xp=r*cos(ang);
    yp=r*sin(ang);
    c=x+xp;
    r=y+yp;
%     plot([x+xp(1) x+xp(end)],[y+yp(1) y+yp(end)],'-c')
%     plot(x+xp,y+yp,'-c');
end

function ib=top_analysis(crop)
    gray=crop;
    out = edge(gray,'Canny',[0.000 0.05]);
    out=idilate((out),kcircle(1));
    for i=1:2:360 
        out = imclose((out),strel('line', 4, i));
    end;
    ib2=iblobs((out),'boundary','area',[30,2000],'class',0,'touch', 0);
%     ib2.display;
    if(isempty(ib2)==1)
        ib=[];
        return
    end
    ib=ib2(1);
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
    gray=crop;
    out = edge(gray,'Canny',[0.000 0.07]);
    out=idilate((out),kcircle(1));
    for i=1:2:360 
        out = imclose((out),strel('line', 7, i));
    end;
%     figure;imshow(out);
    ib2=iblobs((out),'boundary','area',[200,10000],'class',0,'touch',0);   
    if(isempty(ib2)==1)
        side=3;
        return
    end
    if(length(ib2)==1)
%         ib2.plot_boundary('g');ib2.plot_box('y');ib2.plot('*b');
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

function occluded_separation2(im,umin,vmin,c,r)
    global output;
    gray=im;
%     figure;imshow(gray)
    hy = fspecial('sobel');
    hx = hy';
    Iy = imfilter(double(gray), hy, 'replicate');
    Ix = imfilter(double(gray), hx, 'replicate');
    gradmag = sqrt(Ix.^2 + Iy.^2);  
%     figure;imshow(gradmag,[]), title('Gradient magnitude (gradmag)')        
    inline=gradmag;
    inline((gradmag>20 | gradmag<0))=0;
    
    inline = (inline - min(inline(:))) / (max(inline(:)) - min(inline(:)));
    inline2 = im2uint8(inline);    
    out=inline2;%figure;imshow(out);
    out = ierode(out,kcircle(1));
    out = imclose(out,kcircle(3));
    out=im2bw(out,0.1);
    out = edge(out,'Canny',[0.000 0.5]);
    out=idilate((out),kcircle(1));%figure, imshow(out);hold on;
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
%                     theta=mean([blobs(i).theta_,blobs(j).theta_]);
                    angle=mean([ang1,ang2]);
                    reachability = inpolygon(uc,vc,c,r);
                    output.x=[output.x uc];
                    output.y=[output.y vc];
                    output.a=[output.a angle];
                    output.f=[output.f label];
                    output.r=[output.r reachability];
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
            reachability = inpolygon(uc,vc,c,r);
            output.x=[output.x uc];
            output.y=[output.y vc];
            output.a=[output.a angle];
            output.f=[output.f label];
            output.r=[output.r reachability];
%             output.theta=[output.theta theta];
        end
    end 
end
function [x,y]=middle_point(x1,y1,x2,y2)
    x=(x1+x2)/2;
    y=(y1+y2)/2;
end