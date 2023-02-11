%this code will present the calibration point on screen and record the user
%head and eye movements. currently it capture only snapshoots due to the fact that
%computer is too slow. in real code it will capture video and trigger time 

close all
clear all


%% general parameters
numHeadCalibPoints = 5;  %number of calibration point to calibrate head orientation
numEyesCalibPoints = 11; %number of calib points to calib eyes orientation
maxFrameCount = 240;     %maximun number of frame to record when using video (capturePicsAndNotVideo = false)
capturePicsAndNotVideo = true; %true - we use the camcorder to caputre pics when user click a key
                               %false - we use camcorder to caputre video. still need to figure out how to know when the
                               %user is gazing the target
                           
                             
calibFileType = '.png';



%% file names prefix
%{
for ind = 1:numEyesCalibPoints
    calibrationImFileNameEyesOnly{ind} = 'calibration\calibration_points_printscreen_eyesOnly.png';
end
for ind = 1:numHeadCalibPoints
    calibrationImFileNameHeadOnly{ind} = 'calibration\calibration_points_printscreen_headOnly.png';
end
%}
calibrationImFileNameEyesOnly = 'calibration\calibration_points_printscreen_eyesOnly';
calibrationImFileNameHeadOnly = 'calibration\calibration_points_printscreen_headOnly';
calibrationCaptureFileNameEyesOnly = 'calibration\calibration_images\eyesOnly';
calibrationCaptureFileNameHeadOnly = 'calibration\calibration_images\headOnly';
instructions_headOnly = 'calibration\instructionsHeadOnly.png';
instructions_EyesOnly = 'calibration\instructionsEyesOnly.png';


%% find best cam (with highest resoultion)
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
    
        pause;

        inputkey = get(gcf, 'CurrentCharacter');
        if inputkey =='y'
            faceInPic=1;
        end
    end
    %% head only movement
    hFig = figure('units','normalized','outerposition',[0 0 1 1]); %make the figure max size
    imshow(instructions_headOnly); %instruct to press any key to dismiss it and when looking at tarket
    pause; %wait for any keyboard input to contiue
    for ind = 1:numHeadCalibPoints
        suffixName = sprintf('_%02d',ind); %suffix of the current calibration point name
        
        %file name of pic with only the relevant target.
        %calibName = sprintf('%s%s%s',calibrationImFileNameHeadOnly,suffixName,calibFileType);
        calibName = sprintf('%s%s',calibrationImFileNameHeadOnly,calibFileType); %now we use one file for all targets
        
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
        imName = sprintf('%s%s%s',calibrationCaptureFileNameHeadOnly,suffixName,calibFileType); %user picture file name
        imwrite(im,imName);
        
    end
    
    %% eyes only calibration
    hFig = figure('units','normalized','outerposition',[0 0 1 1]); %make the figure max size
    imshow(instructions_EyesOnly); %instruct to press any key to dismiss it and when looking at tarket
    pause; %wait for any keyboard input to contiue
    for ind = 1:numEyesCalibPoints
        suffixName = sprintf('_%02d',ind); %suffix of the current calibration point name
        
        %file name of pic with only the relevant target.
        %calibName = sprintf('%s%s%s',calibrationImFileNameHeadOnly,suffixName,calibFileType);
        calibName = sprintf('%s%s',calibrationImFileNameEyesOnly,calibFileType); %now we use one file for all targets
        
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
        imName = sprintf('%s%s%s',calibrationCaptureFileNameEyesOnly,suffixName,calibFileType); %user picture file name
        imwrite(im,imName);
        
    end
    
    
else %we need to capture video
%frameCount = 240;

    camVidWriter = VideoWriter('cam.avi');
    screenVidWriter = VideoWriter('screen.avi');

    open(camVidWriter);
    open(screenVidWriter);



    for index = 1:frameCount
        % Acquire frame for processing
        camIm = snapshot(cam);
        screenIm = screencapture(0,screenSize);
        % Write frame to video
        writeVideo(camVidWriter,camIm);
        writeVideo(screenVidWriter,screenIm);

    end %for frame count

    toc
    close(camVidWriter);
    close(screenVidWriter);
end
clear cam
close all