function globalParams = generateGlobalParams()

%% calibration params
globalParams.numHeadCalibPoints = 5;  %number of calibration point to calibrate head orientation
globalParams.numEyesCalibPoints = 11; %number of calib points to calib eyes orientation
globalParams.numTestPoints = 7;
globalParams.capturePicsAndNotVideo = true; %true if calibration capture is saperated photos (false if movie)

%% pre-processing images params
globalParams.resizeCalibToMovie = 1; %1 if we want to resize the calibration images to online movie size
globalParams.resizeMovieToCalib = 0; %1 if we want to resize the online movie frames to calib image size

%base name for calibration head only photoes. they will get a number suffix <>_01 etc
globalParams.headBaseName = 'calibration\calibration_images\headOnly'; 
globalParams.eyesBaseName = 'calibration\calibration_images\eyesOnly';
globalParams.calibFileType = '.png';

%% detect feature params
globalParams.pixelInSameLineFeatureDetector = 10; %number of pixel difference for two bbox consider to be in same line
globalParams.cantFindBboxValue = 0; %the value returned when could find valid orientation
%%feature detector indexes and number of detectors
globalParams.bboxNumDetector = 5;
globalParams.headBboxIndex = 1;
globalParams.mouthBboxIndex = 2;
globalParams.noseBboxIndex = 3;
globalParams.leftEyeBboxIndex = 4;
globalParams.rightEyeBboxIndex = 5;

%% orientation caluculation params
globalParams.cantFindOrientationValue = -999; %the value returned when could find valid orientation
globalParams.eyeOrientationSanityCheckPixles = 5; %if the center of pupile is closer to edge than this number return -999 ("not found")
pupileDetectionMethood{1} = 'Bw Morphological Actions';
pupileDetectionMethood{2} = 'filled edges and opening with disk';
globalParams.pupileDetectionMethood = pupileDetectionMethood{1}; %choose the pupile detection methood
globalParams.pupileDetectorBwThreshold = 0.25; %threshold for BW convertion

%% prune small head detections params
globalParams.averageHeadSizeHistoryLength = 10; %array which saves the last head sizes we saw
globalParams.goodPrecentageDiffOfAverage = 50; %new head detection which its size diviates from average is not processed 
globalParams.maxHeadVanish = 3; %wait for head vanish counter to reach this number befor marking a line to combat false positive

