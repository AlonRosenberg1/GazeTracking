function [pupileOnly, center] = getPupilOnlyBwMorph(eyeIm,globalParams)
%this function will return an image of only the pupile in the input eye image

bwThreshold = globalParams.pupileDetectorBwThreshold;
bwThreshold = 0.25; %for debug
showImages = globalParams.debugShowpupilePhoto;
smallObj = 50;
reopenRadius = 3;

if showImages
    figure(1)
    imshow(eyeIm)
end

eyeBw=~im2bw(eyeIm,bwThreshold);
%eyeBw = ~imbinarize(eyeIm,bwThreshold);
if showImages
    figure(2)
    %subplot(212)
    imshow(eyeBw);
end

eyeBwClose=bwmorph(eyeBw,'close'); %fill the little holes 
if showImages
    figure(3)
    imshow(eyeBwClose);
end

eyeBwOpen=bwareaopen(eyeBwClose,smallObj); %remove saperated small objects
if showImages
    figure(5)
    imshow(eyeBwOpen);
end

eyeFill=imfill(eyeBwOpen,'holes'); %remove screen reflection from center of pupile
if showImages
    figure(6)
    imshow(eyeFill);
end

se = strel('disk',reopenRadius);
eyeOpen = imopen(eyeFill,se);
if showImages
    figure(61)
    imshow(eyeOpen);
end
eyeFill = eyeOpen;



L=bwlabel(eyeFill);
% Get areas and tracking rectangle
regionProperties=regionprops(L);
% Count the number of objects
N=size(regionProperties,1);
if N < 1 || isempty(regionProperties) % Returns if no object in the image
    
    %return non found 
    center = [];
    pupileOnly = zeros(size(eyeIm));
    %continue
else

    % ---
    % Select larger area
    areas=[regionProperties.Area];
    [area_max, maxInd]=max(areas);
    center=round(regionProperties(maxInd).Centroid);
    pupileOnly = L==maxInd;
    
    if ~isempty(center)
 
        if showImages
            figure(7)
            imshow(pupileOnly)

            figure(8)
            imshow(eyeIm);
            hold on
            X=center(1);
            Y=center(2);
            plot(X,Y,'g+')
        end
    end

end