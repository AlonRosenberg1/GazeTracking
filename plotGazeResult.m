function plotGazeResult(screenIm,gazeCord,headIm,bbox,markLine,globalParams,outputShowHead,outMovH)
%this function will plot the gaze results on screen image and bbox (head and eyes only) on head image
%if markLine = 1 then the current line around the gazeCord will be marked
%outMovH is handler from videoWriter, which assumed to be open and close elsewhare.
%if it is present we will wrtie to output video and we wont wrtie if it isnt present

if isempty(outMovH)
    writeOutVideo = 0;
else
    writeOutVideo = 1;
    
end

writeGray = 0; %0 for RGB, 1 for gray
    

headInd = globalParams.headBboxIndex;
leftEyeInd = globalParams.leftEyeBboxIndex;
rightEyeInd = globalParams.rightEyeBboxIndex;
notValid = globalParams.cantFindOrientationValue;
notValidBbox = 0;

linewidth = 600;
lineHeight = 60;
linePosX = max(gazeCord(1)-round(linewidth/2),5); %linePosX is atleast 5
linePosY = max(gazeCord(2) - round(lineHeight/2),5);
linePosition = [linePosX linePosY linewidth lineHeight];




%% insert gaze to screen image
label = '';
gazeRadius = 10;
if gazeCord(1) ~= notValid
    if markLine  %insert line on screen
        %gazeOnScreen = insertObjectAnnotation(screenIm,'rectangle',linePosition,label,,'LineWidth',3);
        gazeOnScreen = insertShape(screenIm,'FilledRectangle',linePosition);
        
    else %insert gaze on screen
        gazePosition = [gazeCord gazeRadius];
        gazeOnScreen = insertObjectAnnotation(screenIm,'circle',gazePosition,label,'Color','black','LineWidth',3);
    end
else %not valid gaze coords
    gazeOnScreen = screenIm; 
end %if gazecoord valid
%imshow(gazeOnScreen)

%% insert bbox on head image
headBbox = bbox(headInd,:);
leftEyeBbox = bbox(leftEyeInd,:);
rightEyeBbox = bbox(rightEyeInd,:);

combinedBbox = [headBbox; leftEyeBbox; rightEyeBbox];

if headBbox(1) ~= notValidBbox
    personBboxIm = insertObjectAnnotation(headIm,'rectangle',headBbox,label,'LineWidth',3);
    %imshow(personBboxIm)
else
    personBboxIm = headIm;
end

if leftEyeBbox(1) ~= notValidBbox
    personBboxIm = insertObjectAnnotation(personBboxIm,'rectangle',leftEyeBbox,label,'LineWidth',3);
    %imshow(personBboxIm)
end

if rightEyeBbox(1) ~= notValidBbox
    personBboxIm = insertObjectAnnotation(personBboxIm,'rectangle',rightEyeBbox,label,'LineWidth',3);
    %imshow(personBboxIm)
end

figure(1)
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

if outputShowHead == 0
    imshow(gazeOnScreen);
   
else
    
    %screen image
    subplot(2,1,1)
    imshow(gazeOnScreen);
    subplot(2,1,2)
    imshow(personBboxIm)
end


%pause

if writeOutVideo
    if writeGray
        gazeGray = rgb2gray(gazeOnScreen);
        personGray = rgb2gray(personBboxIm);
        [screenN screenM] = size(gazeGray);
        [headN headM] = size(personGray);
        picType = class(gazeGray);

        joinedN = 100;
        joinedM = max(screenM,headM);
        bufferIm = zeros(joinedN,joinedM,picType);

        joinedIm = zeros(screenN+joinedN+headN,joinedM,picType);
        joinedIm(1:screenN,1:screenM) = gazeGray;
        joinedIm(screenN+joinedN+1:end,1:headM) = personGray;
    else %write RGB
    
        [screenN screenM temp] = size(gazeOnScreen);
        [headN headM temp] = size(personBboxIm);
        picType = class(gazeOnScreen);

        joinedN = 100;
        joinedM = max(screenM,headM);

        joinedIm = zeros(screenN+joinedN+headN,joinedM,3,picType);
        joinedIm(1:screenN,1:screenM,:) = gazeOnScreen;
        joinedIm(screenN+joinedN+1:end,1:headM,:) = personBboxIm;
    end
    
    
    
    %imshow(joinedIm)
    writeVideo(outMovH,joinedIm);
    
end








