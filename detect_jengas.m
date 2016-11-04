function [centroid,orientation,face,reach,no] = detect_jengas(im,im2)

    imshow(im);
    figure(1);
    grayIm = rgb2gray(im);
%     grayIm = im;
    gradIm = imgradient(im2double(grayIm));

    threshold = 0.095;
    binIm = gradIm > threshold;
    
% Cut the image up

    
    binIm(1:246,1:1600) = 0;
    binIm(529,793:801) = 0;
    binIm(292:670,1) = 0;
    
% cut midde line up

    binIm(374,795:802) = 0;
    binIm(383,795:800) = 0;
    binIm(510,793:801) = 0;
    binIm(564,794:797) = 0;
    binIm(729,793:797) = 0;
    binIm(668,794:798) = 0;
  
    binIm = bwareaopen(binIm,700,8);

    inverse = ~binIm;
    
    binIm = imfill(binIm,'holes');
    
    overlayIm = binIm & ~inverse;
    
    overlayIm = bwareaopen(overlayIm,600);
    
    se = strel('disk',1);
    
    
    BW2 = bwmorph(overlayIm,'close');

    BW2 = bwmorph(BW2,'bridge');
    BW2 = bwmorph(BW2,'bridge');
    BW2 = bwmorph(BW2,'spur');
    
    
    BW2 = imfill(BW2,[1,1]);
    BW2 = ~BW2;

    %BW2 = bwareaopen(BW2,150);
    
    
    labeledIm = bwlabel(BW2,8);
    blobMeasurements = regionprops(labeledIm,BW2,'all');
    numberOfBlobs = size(blobMeasurements,1);
    
    boundaries = bwboundaries(BW2);
    numberOfBoundaries = size(boundaries,1);
    
    Deg_Rad = pi/180;
    
    
    hold on;
    for k = 1 : numberOfBoundaries
        thisBoundary = boundaries{k};
        plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
    end;

    area = [blobMeasurements.Area];
    
    ii = find(area<300)
    
    blobMeasurements(ii) = [];
    
    allBlobCentroids = [blobMeasurements.Centroid];
    centroidsX = allBlobCentroids(1:2:end-1);
    centroidsY = allBlobCentroids(2:2:end);
    allOrientations = [blobMeasurements.Orientation];
    
    jeng_Orientation = allOrientations * Deg_Rad;
    area = [blobMeasurements.Area]
    for k=1:numel(area)
        reachable(k) = reachabilityCheck(centroidsX(k),centroidsY(k));
    end;
    reachable;
    if (jeng_Orientation>pi)
        jeng_Orientation = pi-jeng_Orientation;
    end   
    
    % Extrema 
%     jeng_Extrema = blobMeasurements(k).Extrema;
%     Extrema_X = jeng_Extrema(:,1);
%     Extrema_X(numel(Extrema_X)+1) = Extrema_X(1);
%     Extrema_Y = jeng_Extrema(:,2);
%     Extrema_Y(numel(Extrema_Y)+1) = Extrema_Y(1);
    
    for k = 1:numel(area)
        faceID(k) = areaOfFace(blobMeasurements(k));
        region(k) = regionCheck(centroidsX(k), centroidsY(k));

        %[newCentroidX(k),newCentroidY(k)] = centroidManipulate(centroidsX(k),centroidsY(k),region(k),jeng_Orientation(k));
        
    end;

    centroids_Y = 1200-centroidsY;
    jeng_Centroid = [centroidsX;centroidsY];
    %jeng_Centroid = [centroidsX;centroidsY];

    hold on;
    
    plot(centroidsX,centroidsY,'+r');

    centroid = jeng_Centroid;
    orientation = jeng_Orientation;
    face = faceID;
    reach = reachable;
    no = numberOfBlobs;

    return;

end