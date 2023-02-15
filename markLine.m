function markLine(screenIm,gazeCord,personBboxIm,globalParams)
%this function will mark the line around the gaze coord by inserting a rectangle


notValid = globalParams.cantFindOrientationValue;
linewidth = 600;
lineHeight = 5;

linePosX = max(gazeCord(1)-round(linewidth/2),5); %linePosX is atleast 5
linePosY = max(gazeCord(2) - round(lineHeight/2),5);
linePosition = [linePosX linePosY linewidth lineHeight];

%% insert gaze to screen image
label = '';
if gazeCord(1) ~= notValid
    gazeOnScreen = insertObjectAnnotation(screenIm,'rectangle',linePosition,label,'Color','black','LineWidth',3);
else
    gazeOnScreen = screenIm; 
end
%imshow(gazeOnScreen)



figure(1)
%screen image
subplot(2,1,1)
imshow(gazeOnScreen);
subplot(2,1,2)
imshow(personBboxIm)
%pause




