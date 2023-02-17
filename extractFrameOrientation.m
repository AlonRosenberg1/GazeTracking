function [frameOrientation bbox] = extractFrameOrientation(im,globalParams)
%this function will extract the current frame's head and eye orientation
%output is a struct with the fields headOrientation,leftEyeOrientation and rightEyeOrientation
%each is [x y] values

%detect face, eyes etc bbox
 bbox = detectFeature(im,globalParams);
 notValid = globalParams.cantFindOrientationValue;
 notValidBbox = globalParams.cantFindBboxValue;
 
 %detect vertical and horizontal orientation of face, right eye and left eye
 %the orentation is defined as location of center of face bbox
 %for eye it is defined as number of pixels the pupile is away from outer point of eye bbox
 

 if bbox(1,:) ~= ones(1,4)*notValidBbox %if head is not found bbox is zeros
    [tempOriX tempOriY] = getHeadOrientation(bbox); 
    frameOrientation.headOrientation = [tempOriX tempOriY];
    
    isLeftEye = 1;
    if bbox(4,:) ~= ones(1,4)*notValidBbox
        [tempOriXEye tempOriYEye] = geteyeOrientation(im,bbox(4,:),isLeftEye,globalParams);
        frameOrientation.leftEyeOrientation = [tempOriXEye tempOriYEye];
    else 
        frameOrientation.leftEyeOrientation = [notValid notValid];
    end
    
    if bbox(5,:) ~= ones(1,4)*notValidBbox
        [tempOriXEye tempOriYEye] = geteyeOrientation(im,bbox(5,:),~isLeftEye,globalParams);
        frameOrientation.rightEyeOrientation = [tempOriXEye tempOriYEye];
    else
        frameOrientation.rightEyeOrientation = [notValid notValid];
    end
        
 else
     frameOrientation.headOrientation = [notValid notValid];
     frameOrientation.leftEyeOrientation = [notValid notValid];
     frameOrientation.rightEyeOrientation = [notValid notValid];
    
 end