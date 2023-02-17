%main program
close all
clear all

%this program will implement a prototype of gaze tracker
%algorithm 
%1) do calibration for gaze detection (and if needed, the logic of interpeting the gaze)
%2) while running:
%   a) get current eye gaze location on screen
%   b) fill logic for interpeting the gaze, such as if no face detected save last row,
%      detect drowziness, detect incomperhension


globalParams = generateGlobalParams();

%% program parameters
onlineGazeReadPhotos = 0; %1 if the test gaze ("online" reading of frames) reads seperated pics and not movie
inVidFileName = 'twoLinesVideoShort780P.avi';
globalParams.debugShowEyePhoto = 0; %1 if we want to show the eye orientation debug photos
globalParams.debugShowpupilePhoto = 0; %1 if we want to show the eye orientation debug photos for only the pupile phase
globalParams.isRealTime = 1; %1 - realtime usage of camera, code for building, otherwise it uses pre-recorded video
outputMovie = 0; %if 1 save output frames as movie for presentation
outMovieName = 'temp';
outputShowHead = 0; %1 if we want to show head in output window

if outputMovie
    outMov = VideoWriter(outMovieName,'MPEG-4');
    outMov.FrameRate = 8;
    open(outMov)
end

if globalParams.isRealTime == 1
    globalParams.resizeCalibToMovie = 0; 
    globalParams.resizeMovieToCalib = 0; 
end


%% redo calibration if needed

    captureCamVideo2File(globalParams);


numHeadCalibPoints = globalParams.numHeadCalibPoints;

testPoints = [209 135;1130 600; 283 403; 1273 95;762 250;806 687;326 685];
numTestPoints = globalParams.numTestPoints;


indFrame = 1;

%% get images/video frame sizes

if globalParams.isRealTime == 1
    %% get online video frame size
    cam = webcam(2); %in Dina's computer USB is webcam no 2
    im = snapshot(cam);
    temp = size(im);
    globalParams.vidSize = temp(1:2);
    hasFrameVideo=1;
    
    
else %not real time

    %% get calibration images size
    suffixName = sprintf('_%02d',1); %suffix of the current calibration point name
    imName = sprintf('%s%s',globalParams.headBaseName,suffixName,globalParams.calibFileType);
    im = imread(imName);
    calibImSize = size(im);
    if length(calibImSize)>2
        calibImSize = calibImSize(1:2);
    end
    globalParams.calibImSize = calibImSize;


    if onlineGazeReadPhotos
        %% setup input "online" video
        %for first check we will use the calibration images
        hasFrameVideo=1;
        indFrame = 17; %to start test points

        %get calibration images size

        globalParams.vidSize = calibImSize;

    else
        %% setup input video
        inVid = VideoReader(inVidFileName);
        hasFrameVideo = hasFrame(inVid);
        globalParams.vidSize = [inVid.Height inVid.Width];
    end
end %if realtime

%% get calibration points orientation (from camera) and cordination (on screen)
calibData.calibrationPointsOrientation = extractCalibOrientation(globalParams);

          
calibData.screenPointsCord = getScreenPoints();
%for debug
tic
globalParams.minDist = zeros(300,4);
globalParams.minInd = zeros(300,4);
globalParams.normMinDist = zeros(300,4);
globalParams.normMinInd = zeros(300,4);

notValidBbox = globalParams.cantFindBboxValue;

headDetected = 0; 

prevHeadSize = zeros(1,globalParams.averageHeadSizeHistoryLength); %array which saves the sizes of pervius heads we saw
goodPrecentageDiffOfAverage = globalParams.goodPrecentageDiffOfAverage;
headVanishCounter = 0;
maxHeadVanish = globalParams.maxHeadVanish; %wait for head vanish counter to reach this number befor marking a line to combat false positive
lastGaze = [0 0];
while hasFrameVideo
    
    
    %% get new frame
    if globalParams.isRealTime == 1
        im = snapshot(cam);
    else %not real time

        if onlineGazeReadPhotos

        %%get new frame - from photoes

            if indFrame <= numHeadCalibPoints %we are reading head photoes
                baseName = globalParams.headBaseName;
                im = getNewFrame_temp(baseName,indFrame,globalParams);
            elseif indFrame <= numHeadCalibPoints+globalParams.numEyesCalibPoints
                baseName = globalParams.eyesBaseName;
                im = getNewFrame_temp(baseName,indFrame - numHeadCalibPoints,globalParams);
            else
                baseName = 'calibration\calibration_images\test';
                im = getNewFrame_temp(baseName,indFrame - numHeadCalibPoints-globalParams.numEyesCalibPoints,globalParams);
            end %if indFrame
        else %read new frame from video
            im = readFrame(inVid);
        end %if online gaze==1
    end %if is realtime
    
    
    
    %for debug
    globalParams.currFrame = indFrame;
    fprintf('current frame is %d \n',indFrame)

    %% analyse frame
    useHeadOnly = 0;
    [gaze(indFrame,:), bbox, globalParams] = getGaze(im,calibData,globalParams,useHeadOnly);
    
    headSize = bbox(1,3)*bbox(1,4);
    if prevHeadSize(end) == 0 %not enough data on pervius heads
        headDetectedCrtiria = bbox(1,:) ~= ones(1,4)*notValidBbox;
    else %we have data on pervius head size, criteria need to be +-given% of average
        averageHeadSize = mean(prevHeadSize);
        maxAllowedDiff = averageHeadSize*goodPrecentageDiffOfAverage/100;
        headDetectedCrtiria = abs(averageHeadSize - headSize) <= maxAllowedDiff;
        
    end
    
      
    if headDetectedCrtiria %head is detected
        prevHeadSize = [headSize prevHeadSize];
        prevHeadSize(end) = [];
        lastGaze = gaze(indFrame,:);
        headDetected = 1;
        headVanished = 0;
        headVanishCounter = 0;

    else %head is not detected
        headVanishCounter = headVanishCounter+1;
        headVanished = headDetected;
    end
    
    %% get screen snapshot
    screenIm = getScreenSnapshot();
    
    %% show results mark line if head is vanished
    if ~outputMovie %if we dont write move make empty movie handler so function will know to ignore it
        outMov = [];
    end

    
    if (headVanishCounter >= maxHeadVanish) && (headVanished)
        markLine = 1;
        plotGazeResult(screenIm,lastGaze,im,bbox,markLine,globalParams,outputShowHead,outMov);

    else
        markLine = 0;
        %dummyGaze = [1 1];
        dummyGaze = lastGaze;
        plotGazeResult(screenIm,dummyGaze,im,bbox,markLine,globalParams,outputShowHead,outMov);
    end
      
    indFrame = indFrame+1; %index for saving outputs
    %update hasframe
    if globalParams.isRealTime == 1
        hasFrameVideo = 1;
    else
        
        if onlineGazeReadPhotos
            if indFrame > globalParams.numHeadCalibPoints+globalParams.numEyesCalibPoints+numTestPoints
                hasFrameVideo = 0;
            end
        else
            hasFrameVideo = hasFrame(inVid);
        end
    end %if is realtime
    
end %while has frames
toc

if outputMovie
    close(outMov)
end

if globalParams.isRealTime ~= 1

    %calc error - distance between real points and my gaze
    testGaze = gaze(numHeadCalibPoints+globalParams.numEyesCalibPoints+1:end,:);
    [diffDistance diffDistSquare] = calcTestLoss(testPoints,testGaze);
    meanDist = mean(diffDistance)
    meanSquareDist = mean(diffDistSquare) 
end