function [eyeOrientationX eyeOrientationY]  = geteyeOrientation(im,eyeBbox,isLeftEye, globalParams)
%this function will get eye orientation for given eye (in bbox) and image
%first it will crop the eye from the image according to bbox
%than it will find the number of pixel difference of the pupile from the left most primiter of the eye (X value
%and upper primiter of the eye (Y value)

%algorithm
%1) identify the sclera by doing edge analizeation, dilite the edge line, fill holes and choose max connected component
%2) saperate the pupile by eroding with a disk of size (sclera size/3)
%3) estimate a complete sclera elipse
%4) return orientation as number of pixels from eye bridge (or other side) and eyebrdige connection hiegth
%for now - return orientation of number of pixel of center of pupile from upper right corner (for left eye. upper left
%cornert for right eye)

%% algorithm (1st draft):
%step 0 - identify the sclera and pupile using segmentation, histogram (sclera should be whitest bunch of pixels) and
%turn to BW
%histogram methood doesnt work - color is too close to make saperation. choose edges instead
%step 1 - isolate pupile/iris using morphological actions /other actions
%step 2 - remove pupile from sclera to get only white sclera

%step 3 - get contour of sclera - substruct the eroded with disk one from the filled sclera

%think about reference the pupile center to another point in face

%step 4 - calculate middle of pupile from left most point of contour

%step 5 = calculate middle of pupile from upper most point of contour

%% for debug 
%eyeBbox = bbox(4,:); isLeftEye = 1
%sanityCheckPixles = 5; %if the center of pupile is closer to edge than this number return -999 ("not found")

sanityCheckPixles = globalParams.eyeOrientationSanityCheckPixles; %if the center of pupile is closer to edge than this number return -999 ("not found")
notValid = globalParams.cantFindOrientationValue;
pupileDetectionMethood = globalParams.pupileDetectionMethood;

%% get the eye only
eyeBboxRangeX = eyeBbox(1): eyeBbox(1)+eyeBbox(3);
eyeBboxRangeY = eyeBbox(2):eyeBbox(2)+eyeBbox(4);

eyeIm = im(eyeBboxRangeY,eyeBboxRangeX,:);
if globalParams.debugShowEyePhoto

    close all
    figure(1)
    imshow(eyeIm)

end
eyeImGray = rgb2gray(eyeIm);
[imX imY] = size(eyeImGray);

switch pupileDetectionMethood
    case 'Bw Morphological Actions'
        pupileBw = getPupilOnlyBwMorph(eyeImGray,globalParams);
        
        
    case 'filled edges and opening with disk'

        %% get edges 
        [~,threshold] = edge(eyeImGray,'sobel');
        fudgeFactor = 0.5;
        eyeEdges = edge(eyeImGray,'sobel',threshold * fudgeFactor);

        %{
        figure(2)
        imshow(eyeEdges);
        %}

        %% open the edge picture to get filled contour of the eye
        Disk3 = strel('disk',3);
        tempEdges = imdilate(eyeEdges,Disk3);
        tempEdges = imerode(tempEdges,Disk3);
        %fill the contour
        edgesFilled = imfill(tempEdges,'holes');

        %{
        figure(3)
        imshow(tempEdges)
        %}
        if globalParams.debugShowEyePhoto
            figure(31)
            imshow(edgesFilled)
        end

        %remove thinly connected elements
        Disk1 = strel('disk',1);
        edgesFilled = imopen(edgesFilled,Disk1);

        %{
        figure(32)
        imshow(edgesFilled)
        %}

        %remove connection to edges
        edgesFilled(1,:) = 0;
        edgesFilled(imX,:) = 0;
        edgesFilled(:,1) = 0;
        edgesFilled(:,imY) = 0;

        %{
        figure(33)
        imshow(edgesFilled)
        %}



        %% identify connected object and choose the one with the most area as the eye
        connectComp = bwconncomp(edgesFilled,4);
        %get largest object - the sclera&pupile
        numPixels = cellfun(@numel,connectComp.PixelIdxList);
        [biggest,idx] = max(numPixels);
        scleraPupileInd = connectComp.PixelIdxList{idx};

        %get the gray level of the choosen indexes
        scleraPupile = zeros(size(eyeImGray));
        scleraPupile(scleraPupileInd) = eyeImGray(scleraPupileInd);



        if globalParams.debugShowEyePhoto
            figure(4)
            imshow(scleraPupile,[])
        end

        %% saperate pupile from sclera

        %get sclera length
        scleraCol = sum(scleraPupile,1);
        scleraLen = find(scleraCol>0,1,'last') - find(scleraCol>0,1);


        irisRadi = floor((scleraLen/3 -1)/2); %pupile length is around one third of sclera. minus one is to be lower than that
        DiskIris = strel('disk',irisRadi);

        pupileOnly = imopen(scleraPupile,DiskIris);

        %{
        figure(5)
        imshow(pupileOnly,[])
        %}

        %alternate way - via imfindcircles
        %[centersDark, radiiDark] = imfindcircles(scleraPupile,[irisRadi-2 irisRadi+2],'ObjectPolarity','dark','Sensitivity',0.9);

        %% draw elipse over the sclera
        %{
        scleraPupileBw = im2bw(scleraPupile);
        imshow(scleraPupileBw)

        s = regionprops(scleraPupileBw,'Centroid','MajorAxisLength','MinorAxisLength','Orientation','PixelList');

        %for visualization
        PixList = s(1).PixelList;

        x = s(1).Centroid(1);
        y = s(1).Centroid(2);
        a = s(1).MajorAxisLength/2;
        b = s(1).MinorAxisLength/2;
        ori = s(1).Orientation;
        steps = 50;

        %#  @param x     X coordinate
        %#  @param y     Y coordinate
        %#  @param a     Semimajor axis
        %#  @param b     Semiminor axis
        %#  @param angle Angle of the ellipse (in degrees)

        beta = ori * (pi / 180);
        sinbeta = sin(beta);
        cosbeta = cos(beta);

        alpha = linspace(0, 360, steps)' .* (pi / 180);
        sinalpha = sin(alpha);
        cosalpha = cos(alpha);

        X = x + (a * cosalpha * cosbeta - b * sinalpha * sinbeta);
        Y = y + (-a * cosalpha * sinbeta + b * sinalpha * cosbeta);

        figure(5)
        imshow(scleraPupile)
        hold on
        plot(X,Y,'k','LineWidth',2)
        hold off

        %}

        %% estimate the real contur of sclera
        %for later phases in algor

        %% get the center of pupile

        pupileBw = im2bw(pupileOnly);

        if globalParams.debugShowEyePhoto

            figure(6)
            imshow(pupileBw)
        end
        %first methood - via region props
end %switch meathood of pupile detection

s = regionprops(pupileBw,'Centroid','Area');
if ~isempty(s)
    %choose max area region as the pupile
    [temp maxInd] = max(cat(1, s.Area));  %convert struct array to double array for Area
    
    pupileCenter = round(s(maxInd).Centroid);

    %2nd methood - via find circles
    %[centersDark, radiiDark] = imfindcircles(scleraPupile,[irisRadi-2 irisRadi+2],'Sensitivity',0.9);

    %% return orientation
    %number of pixels from upper right corner (imX,1) (for left eye)
    %or number of pixels from upper left corner (1,1) for right eye

    if isLeftEye
        eyeOrientationX = imX - pupileCenter(1);
    else
        eyeOrientationX = pupileCenter(1)-1;
    end
    eyeOrientationY = pupileCenter(2)-1;
    
    if pupileCenter(1) <= sanityCheckPixles | pupileCenter(1) >= imX - sanityCheckPixles ...
        | pupileCenter(2) <= sanityCheckPixles | pupileCenter(2) >imY - sanityCheckPixles  
        eyeOrientationX = notValid;
        eyeOrientationY = notValid;
    end

else %empty region props - return -999 to signal empty
    eyeOrientationX = notValid;
    eyeOrientationY = notValid;
end %if ~isempty(s)


    
     
    

