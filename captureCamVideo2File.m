function captureCamVideo2File(globalParams)
%this code will present the calibration point on screen and record the user
%head and eye movements into series of files. currently it capture only snapshoots due to the fact that
%computer is too slow. in real code it will capture video and trigger time 

%flow of capturing new video (for myself)
%{
1)  run this function (it will prompt you to adjust cam, look at 16 calibration points 
    and 7 test points, then save the data to \calibration\calibration_images
2)  open getScreenSnapshot.m and show the screen image. make sure to enlarge the window
2.1)  open camera app for windows
3)  adjust resolution for 480 (make sure you are video part of setting, not pictures)
4)  copy the movies from pictures\camera roll to matlab dir
5)  open edit_camera_movies.m for edit
6)  make sure input name (eye_only_movement) and output (eye_only_cropped) are correct
7)  run the "%find start and end eye only" snipp. press button until start of movie
    copy the start time and frame of pervius frame to "eyes_only_start" and "eyes_frameIndStart"
8)  tap until the end of wanted frame and copy the current time and frame to "eyes_only_end" and "eyes_frameIndEnd"
9)  CTR-C to kill the while, and run to numFrames and skip to numFrames = eyesOnlyNumFrames; 
10) skip to frameInd = 0; and run untill the open(eye)
11) run while untill close of eye movie
%}


%{
close all
clear all
%}

%% general parameters
skipTestPointsCapture = globalParams.isRealTime; %if we do realtime than skip capturing the test points
numHeadCalibPoints = globalParams.numHeadCalibPoints; % 5;  %number of calibration point to calibrate head orientation
numEyesCalibPoints = globalParams.numEyesCalibPoints; %11; %number of calib points to calib eyes orientation
%maxFrameCount = globalParams.maxFrameCount; %240;     %maximun number of frame to record when using video (capturePicsAndNotVideo = false)
capturePicsAndNotVideo = globalParams.capturePicsAndNotVideo;% true; %true - we use the camcorder to caputre pics when user click a key
                               %false - we use camcorder to caputre video. still need to figure out how to know when the
                               %user is gazing the target
                           
                             
calibFileType = globalParams.calibFileType; % '.png';
notValid = globalParams.cantFindBboxValue;



%% file names prefix
calibrationImFileNameEyesOnly = 'calibration\calibration_points_printscreen_eyesOnly';
calibrationImFileNameHeadOnly = 'calibration\calibration_points_printscreen_headOnly';
testInFileName = 'calibration\test';
calibrationCaptureFileNameEyesOnly = globalParams.eyesBaseName;% 'calibration\calibration_images\eyesOnly';
calibrationCaptureFileNameHeadOnly = globalParams.headBaseName;% 'calibration\calibration_images\headOnly';
testCaptureFileName = 'calibration\calibration_images\test'; 
instructions_headOnly = 'calibration\instructionsHeadOnly.png';
instructions_EyesOnly = 'calibration\instructionsEyesOnly.png';
errorDetectedFileName = 'calibration\errorDetected.png';
errorInputKey = 'calibration\errorInputKey.png';
numTest =globalParams.numTestPoints;


%% find best cam (with highest resoultion), if several cameras are installed
%{
numWebCams = length(webcamlist);
maxRes = 0;
maxInd = 1;
for ind = 1:numWebCams
    cam = webcam(ind);
    res = cam.Resolution; %res is in format aaaxbbb
    xInd = strfind(res,'x');
    res1 = str2num(res(1:xInd-1));
    res2 = str2num(res(xInd+1:end));
    
    if res1*res2 >maxRes
        maxRes = res1*res2;
        maxInd = ind;
    end
    clear cam
   
end %find best webcam

cam = webcam(maxInd);
%}
cam = webcam(2); %dinas computer usb camera is number 2
screenSize = get(0,'ScreenSize');

if capturePicsAndNotVideo %we caputre single snapshoot
    
    %making sure whole face is recorded
    faceInPic = 0;
    while faceInPic ~=1
        im = snapshot(cam);
        
        imshow(im)
        str1 = 'please make sure your face in the picture.';
        str2 = 'if eyes or mouth is not shown pleas adjust camera and press n key.';
        str3 = 'if mouth and eyes are shown please press y key';
        title(sprintf('%s%s%s',str1,str2,str3));
        
        hFigFaceTest = gcf;
        % set the figure to full screen
        set(hFigFaceTest,'units','normalized','outerposition',[0 0 1 1]);
        
        % Create button to bypass problem with pause (in standalone, input only to cmd window).
        buttonH = uicontrol('Style','popupmenu','Position', [0 400 120 120]);
        buttonH.String = {'    ','No','Yes',};
        
        waitfor(buttonH,'Value');
    
        %pause;
        if buttonH.Value == 3
            inputkey ='y';
        else
            inputkey ='n';
        end
            
        
        if inputkey =='y'
            faceInPic=1;
        elseif isempty(inputkey)
            %couldnt process input key, probably on hebrew
            imshow(errorInputKey)
            pause;
        end
    end
    %% head only movement
    imshow(instructions_headOnly); %instruct to press any key to dismiss it and when looking at tarket
    
    nextButtonPos = [0.4 0.0 0.1 0.1];
    netxButtonH = uicontrol('Style','togglebutton','String','Next','Units','normalized','Position', nextButtonPos);
    
    waitfor(netxButtonH,'value');
    
    for ind = 1:numHeadCalibPoints
        isOk = 0; %for checking if eyes and face were detected
        while ~isOk
            suffixName = sprintf('_%02d',ind); %suffix of the current calibration point name

            %file name of pic with only the relevant target.
            calibName = sprintf('%s%s%s',calibrationImFileNameHeadOnly,suffixName,calibFileType);

            imshow(calibName,'Border','tight')

            %code for fitting pic to screen size
            % get the figure and axes handles
            hFig = gcf;
            hAx  = gca;
            % set the figure to full screen
            set(hFig,'units','normalized','outerposition',[0 0 1 1]);
            % set the axes to full screen
            set(hAx,'Unit','normalized','Position',[0 0 1 1]);
            % hide the toolbar
            set(hFig,'menubar','none')
            % to hide the title
            set(hFig,'NumberTitle','off');
            
            nextButtonPos = [0.0 0.9 0.03 0.03];
            netxButtonH = uicontrol('Style','togglebutton','String','Next','Units','normalized','Position', nextButtonPos);
            waitfor(netxButtonH,'value');
            %pause; %wait for user input he is gazing the target

            im = snapshot(cam);
            
            %% check if eyes and face were identifed correctly
            bbox = detectFeature(im,globalParams);
            tempVal = [bbox(globalParams.headBboxIndex,1) bbox(globalParams.leftEyeBboxIndex,1) bbox(globalParams.rightEyeBboxIndex,1)];
            isOk = all(tempVal ~= notValid);
            if isOk

                imName = sprintf('%s%s%s',calibrationCaptureFileNameHeadOnly,suffixName,calibFileType); %user picture file name
                imwrite(im,imName);
            else
                %show error
                imshow(errorDetectedFileName);
                nextButtonPos = [0.4 0.0 0.1 0.1];
                netxButtonH = uicontrol('Style','togglebutton','String','Next','Units','normalized','Position', nextButtonPos);
                waitfor(netxButtonH,'value');
                %pause;
            end%if
        end %while 

    end %for 
    
    %% eyes only calibration
    imshow(instructions_EyesOnly); %instruct to press any key to dismiss it and when looking at tarket
    nextButtonPos = [0.4 0.0 0.1 0.1];
    netxButtonH = uicontrol('Style','togglebutton','String','Next','Units','normalized','Position', nextButtonPos);
    waitfor(netxButtonH,'value');
    for ind = 1:numEyesCalibPoints
        isOk = 0;
        while ~isOk
            suffixName = sprintf('_%02d',ind); %suffix of the current calibration point name

            %file name of pic with only the relevant target.
            calibName = sprintf('%s%s%s',calibrationImFileNameEyesOnly,suffixName,calibFileType);

            imshow(calibName,'Border','tight')

            %code for fitting pic to screen size
            % get the figure and axes handles
            hFig = gcf;
            hAx  = gca;
            % set the figure to full screen
            set(hFig,'units','normalized','outerposition',[0 0 1 1]);
            % set the axes to full screen
            set(hAx,'Unit','normalized','Position',[0 0 1 1]);
            % hide the toolbar
            set(hFig,'menubar','none')
            % to hide the title
            set(hFig,'NumberTitle','off');
            
            nextButtonPos = [0.0 0.9 0.03 0.03];
            netxButtonH = uicontrol('Style','togglebutton','String','Next','Units','normalized','Position', nextButtonPos);
            waitfor(netxButtonH,'value');

            im = snapshot(cam);
            
            %% check if eyes and face were identifed correctly
            bbox = detectFeature(im,globalParams);
            tempVal = [bbox(globalParams.headBboxIndex,1) bbox(globalParams.leftEyeBboxIndex,1) bbox(globalParams.rightEyeBboxIndex,1)];
            isOk = all(tempVal ~= notValid);
            if isOk

                imName = sprintf('%s%s%s',calibrationCaptureFileNameEyesOnly,suffixName,calibFileType); %user picture file name
                imwrite(im,imName);
            else
                %show error
                imshow(errorDetectedFileName);
                nextButtonPos = [0.4 0.0 0.1 0.1];
                netxButtonH = uicontrol('Style','togglebutton','String','Next','Units','normalized','Position', nextButtonPos);
                waitfor(netxButtonH,'value');
                %pause;
            end%if
            
        end%while

    end %for 
    
    if ~skipTestPointsCapture
        %% capturing test points
        for ind = 1:numTest
            suffixName = sprintf('_%02d',ind); %suffix of the current calibration point name

            %file name of pic with only the relevant target.
            calibName = sprintf('%s%s%s',testInFileName,suffixName,calibFileType);

            imshow(calibName,'Border','tight')

            %code for fitting pic to screen size
            % get the figure and axes handles
            hFig = gcf;
            hAx  = gca;
            % set the figure to full screen
            set(hFig,'units','normalized','outerposition',[0 0 1 1]);
            % set the axes to full screen
            set(hAx,'Unit','normalized','Position',[0 0 1 1]);
            % hide the toolbar
            set(hFig,'menubar','none')
            % to hide the title
            set(hFig,'NumberTitle','off');

            pause; %wait for user input he is gazing the target
            im = snapshot(cam);
            imName = sprintf('%s%s%s',testCaptureFileName,suffixName,calibFileType); %user picture file name
            imwrite(im,imName);

        end
    end %skip test points

    
else %we need to capture video
%frameCount = 240;

    camVidWriter = VideoWriter('cam.avi');

    open(camVidWriter);

    frameCount = 100;
    for index = 1:frameCount
        % Acquire frame for processing
        camIm = snapshot(cam);
        % Write frame to video
        writeVideo(camVidWriter,camIm);

    end %for frame count

    close(camVidWriter);
    close(screenVidWriter);
end
clear cam
close all