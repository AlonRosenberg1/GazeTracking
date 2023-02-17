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


calibrationPointsOrientation = cell(1,numHeadCalibPoints+numEyesCalibPoints);

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
 
  
end %for head picture


for ind = 1:numEyesCalibPoints
    
    currentCalibEye = ind
    
     suffixName = sprintf('_%02d',ind); %suffix of the current calibration point name
     imName = sprintf('%s%s',eyesBaseName,suffixName,calibFileType);
     im = imread(imName);
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

       
end %for eye picture
toc
