function calibrationPointsOrientation = extractCalibOrientation(globalParams)

%%this code will analyse the calibration images and output absoulte orientation for each caib photo

%close all;
%clear

numHeadCalibPoints = globalParams.numHeadCalibPoints;  %number of calibration point to calibrate head orientation
numEyesCalibPoints = globalParams.numEyesCalibPoints; %number of calib points to calib eyes orientation
capturePicsAndNotVideo = globalParams.capturePicsAndNotVideo; %to do - add code for capturing vidoe

headBaseName = globalParams.headBaseName;
eyesBaseName = globalParams.eyesBaseName;
calibFileType = globalParams.calibFileType;

%% old params
%{
numHeadCalibPoints = 5;  %number of calibration point to calibrate head orientation
numEyesCalibPoints = 11; %number of calib points to calib eyes orientation
capturePicsAndNotVideo = true;

headBaseName = 'calibration\calibration_images\headOnly';
eyesBaseName = 'calibration\calibration_images\eyesOnly';
calibFileType = '.png';
%}

%% detectors:
%{
numDetectors = 5;
detectors{1} = vision.CascadeObjectDetector(); %face detector
detectors{2} = vision.CascadeObjectDetector('Mouth');
detectors{3} = vision.CascadeObjectDetector('Nose');
detectors{4} = vision.CascadeObjectDetector('LeftEyeCART');
detectors{5} = vision.CascadeObjectDetector('RightEyeCART');

for featureInd = 2:numDetectors
    detectors{featureInd}.UseROI = true;
end


bbox = zeros(numDetectors,4);
%}
calibrationPointsOrientation = cell(1,numHeadCalibPoints+numEyesCalibPoints);
tic
%dealing with head pictures
for ind = 1:numHeadCalibPoints
    
     currentCalibHead = ind

     suffixName = sprintf('_%02d',ind); %suffix of the current calibration point name
     imName = sprintf('%s%s',headBaseName,suffixName,calibFileType);
     im = imread(imName);
     %%resize to video image
     if globalParams.resizeCalibToMovie == 1
        im = imresize(im,globalParams.vidSize);
     end
     [calibrationPointsOrientation{ind} bbox] = extractFrameOrientation(im,globalParams);
     %% save bbox and size for debug
     calibrationPointsOrientation{ind}.headBbox = bbox(globalParams.headBboxIndex,:);
     calibrationPointsOrientation{ind}.headSize = bbox(globalParams.headBboxIndex,3)*bbox(globalParams.headBboxIndex,4);
     calibrationPointsOrientation{ind}.leftEyeBbox = bbox(globalParams.leftEyeBboxIndex);
     calibrationPointsOrientation{ind}.leftEyeSize = bbox(globalParams.leftEyeBboxIndex,3)*bbox(globalParams.leftEyeBboxIndex,4);
     calibrationPointsOrientation{ind}.rightEyeBbox = bbox(globalParams.rightEyeBboxIndex);
     calibrationPointsOrientation{ind}.rightEyeSize = bbox(globalParams.rightEyeBboxIndex,3)*bbox(globalParams.rightEyeBboxIndex,4);
     
     
     
     %%old
     %{
     %detect face, eyes etc bbox
     bbox = detectFeature(im);
     %{
     imAnotate = insertObjectAnnotation(im,'rectangle',bbox,'');   
     imshow(imAnotate)
     %}
     
     %detect vertical and horizontal orientation of face, right eye and left eye
     %the orentation is defined as location of center of face bbox
     %for eye it is defined as number of pixels the pupile is away from nose bridge
     [tempOriX tempOriY] = getHeadOrientation(bbox); %TODO - add this after check if bbox is empty
     calibrationPointsOrientation{ind}.headOrientation = [tempOriX tempOriY];
     
     if ~isempty(bbox)
        isLeftEye = 1;
        [tempOriXEye tempOriYEye] = geteyeOrientation(im,bbox(4,:),isLeftEye,globalParams);
        calibrationPointsOrientation{ind}.leftEyeOrientation = [tempOriXEye tempOriYEye];
        [tempOriXEye tempOriYEye] = geteyeOrientation(im,bbox(5,:),~isLeftEye,globalParams);
        calibrationPointsOrientation{ind}.rightEyeOrientation = [tempOriXEye tempOriYEye];
     end
     %}
  
end %for head picture


for ind = 1:numEyesCalibPoints
    
    currentCalibEye = ind
    
     suffixName = sprintf('_%02d',ind); %suffix of the current calibration point name
     imName = sprintf('%s%s',eyesBaseName,suffixName,calibFileType);
     im = imread(imName);
     %imshow(im)
     if globalParams.resizeCalibToMovie == 1
        im = imresize(im,globalParams.vidSize);
     end
     [calibrationPointsOrientation{numHeadCalibPoints+ind} bbox] = extractFrameOrientation(im,globalParams);
     %% save bbox and size for debug
     calibrationPointsOrientation{numHeadCalibPoints+ind}.headBbox = bbox(globalParams.headBboxIndex,:);
     calibrationPointsOrientation{numHeadCalibPoints+ind}.headSize = bbox(globalParams.headBboxIndex,3)*bbox(globalParams.headBboxIndex,4);
     calibrationPointsOrientation{numHeadCalibPoints+ind}.leftEyeBbox = bbox(globalParams.leftEyeBboxIndex);
     calibrationPointsOrientation{numHeadCalibPoints+ind}.leftEyeSize = bbox(globalParams.leftEyeBboxIndex,3)*bbox(globalParams.leftEyeBboxIndex,4);
     calibrationPointsOrientation{numHeadCalibPoints+ind}.rightEyeBbox = bbox(globalParams.rightEyeBboxIndex);
     calibrationPointsOrientation{numHeadCalibPoints+ind}.rightEyeSize = bbox(globalParams.rightEyeBboxIndex,3)*bbox(globalParams.rightEyeBboxIndex,4);

     %old
     %{
     %detect face, eyes etc bbox
     bbox = detectFeature(im);
     %{
     imAnotate = insertObjectAnnotation(im,'rectangle',bbox,'');   
     imshow(imAnotate)
     %}
     
     %detect vertical and horizontal orientation of face, right eye and left eye
     %the orentation is defined as location of center of face bbox
     %for eye it is defined as number of pixels the pupile is away from nose bridge
     [tempOriX tempOriY] = getHeadOrientation(bbox);
     %eyeCalibData{numHeadCalibPoints+ind}.headOrientation = [tempOriX tempOriY];
     calibrationPointsOrientation{numHeadCalibPoints+ind}.headOrientation = [tempOriX tempOriY];
    
     if ~isempty(bbox) 
        [tempOriXEye tempOriYEye] = geteyeOrientation(im,bbox(4,:),isLeftEye,globalParams);
        calibrationPointsOrientation{numHeadCalibPoints+ind}.leftEyeOrientation = [tempOriXEye tempOriYEye];
        [tempOriXEye tempOriYEye] = geteyeOrientation(im,bbox(5,:),~isLeftEye,globalParams);
        calibrationPointsOrientation{numHeadCalibPoints+ind}.rightEyeOrientation = [tempOriXEye tempOriYEye];
     end
     %}
  
end %for eye picture
toc
