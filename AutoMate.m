function AutoMate(image_file,image_file2,str2)

%     imtot = image_file;
    
    % Get resolution of total image.
%     [Xres,Yres] = size(imtot);

    % Image when passed from main GUI to this sub GUI gets split into RGB
    % space. Therefore a total of 6 images are stored in imtot which alternate.
    
    %==========================================================================
    % Split images into respective spaces and in respect to image number.
    
%     im1R = imtot(1:Xres, 1:(Yres/6));
%     im2R = imtot(1:Xres, ((Yres/6)+1):(2*Yres/6));
%     im1G = imtot(1:Xres, ((2*Yres/6)+1):(3*Yres/6));
%     im2G = imtot(1:Xres, ((3*Yres/6)+1):(4*Yres/6));
%     im1B = imtot(1:Xres, ((4*Yres/6)+1):(5*Yres/6));
%     im2B = imtot(1:Xres, ((5*Yres/6)+1):(6*Yres/6));
    
    
    %==========================================================================
    
    % Now store the spaces into 2 different Images, that will make up the final
    % two images shown in this GUI
%     im1(:,:,1) = im1R;
%     im1(:,:,2) = im1G;
%     im1(:,:,3) = im1B;
%     
%     im2(:,:,1) = im2R;
%     im2(:,:,2) = im2G;
%     im2(:,:,3) = im2B;

%     im1 = imtot(1:Xres, 1:(Yres/2));
%     im2 = imtot(1:Xres, (Yres/2)+1:Yres);

    %Process the Image using CV
    
    %do for table and just one for now
    
    im1 = image_file;
    im2 = image_file2;
    
    figure(1); imshow(im1);
    

    [centroid,orientation,face,reach,no] = detect_jengas(im1);
    
    xCam1 = centroid(1);
    yCam1 = centroid(2);

    % reachability check here

    reachable = reachabilityCheck(xCam1,yCam1);
    
    if (reachable == 1)
        realCord = [xCam1,yCam1];
        
        blocks = [centroid; orientation; face; reach];
        
        save blocks.mat blocks;
        
%         fileID = fopen('output_files/blocks.txt','w');
%         for i = 1:no
%             fprintf(fileID,'%.6f %.6f %.6f %.6f %.6f\n',centroid(1,i),centroid(2,i),orientation(i),face(i),reach(i));
%         end;
%         fclose(fileID);
        
        % Store a txt file saying which image was selected, and if the coordinates
        % were reachable write value 1.
        fileID = fopen('output_files/automate_pressed.txt','w');
        fclose(fileID);
        
        % Write 1 to reachable txt file.
        fileID = fopen('output_files/reachable.txt','w');
        fprintf(fileID,'%d\n',reachable);
        fclose(fileID);
        
        %write out which button was pressed.
        str1 = 'output_files/';
        str3 = '.txt';
        
        string = strcat(str1,str2,str3);
        
        fileID = fopen(string,'w');
        fclose(fileID);
        
    end;
    
    
    % if unreachable delete anything that may already exist in the output
    % folder.
    if (reachable == 0)
        fprintf('Coordinates selected unreachable\n');
        if exist('output_files/coordinates.txt')
            delete('output_files/coordinates.txt');
        end;
        
        if exist('output_files/automate_pressed.txt')
            delete('output_files/automate_pressed.txt');
        end;
        
        if exist('output_files/orientation_face.txt')
            delete('output_files/orientation_face.txt');
        end;
        
        fileID = fopen('output_files/reachable.txt','w');
        fprintf(fileID,'%d\n',reachable);
        fclose(fileID);
    end;

    
end