%%this code will analyse the calibration images and output absoulte orientation for each picture

close all;
clear

numHeadCalibPoints = 5;  %number of calibration point to calibrate head orientation
numEyesCalibPoints = 11; %number of calib points to calib eyes orientation
capturePicsAndNotVideo = true;

headBaseName = 'calibration\calibration_images\headOnly';
eyesBaseName = 'calibration\calibration_images\eyesOnly';
calibFileType = '.png';

%%detectors:
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

%dealing with head pictures
for ind = 1:numHeadCalibPoints
     suffixName = sprintf('_%02d',ind); %suffix of the current calibration point name
     imName = sprintf('%s%s',headBaseName,suffixName,calibFileType);
     im = imread(imName);
     
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
     headCalibData{ind}.headOrientation = [tempOriX tempOriY];
  
end %for head picture

for ind = 1:numEyesCalibPoints
     suffixName = sprintf('_%02d',ind); %suffix of the current calibration point name
     imName = sprintf('%s%s',eyesBaseName,suffixName,calibFileType);
     im = imread(imName);
     
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
     eyeCalibData{ind}.headOrientation = [tempOriX tempOriY];
  
end %for eye picture
