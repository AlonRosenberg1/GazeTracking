close all;
clear all;

screenShotFilename = 'calibration_points_printscreen.png';

%% crop eyes only and with head movement to same length

eye_only_movement = VideoReader('demo_confuse_long.mp4');
eye_only_cropped = VideoWriter('twoLinesVideoShort460P','Uncompressed AVI');

head_movement = VideoReader('cam_head_movement.mp4');
head_movement_cropped = VideoWriter('cam_head_movement_cropped.mp4');

%find start and end eye only

eyes_only_start = 1.4080;
eyes_frameIndStart = 20;
eyes_only_end = 10.2082;
eyes_frameIndEnd = 153;
eyesOnlyNumFrames = eyes_frameIndEnd-eyes_frameIndStart+1;


head_movement_start = 6.4001;
head_frameIndStart = 32;
head_movement_end = 23.9039;
head_frameIndend = 127;
withHeadNumFrames = head_frameIndend-head_frameIndStart+1;

numFrames = max(withHeadNumFrames,eyesOnlyNumFrames);
%numFrames = eyesOnlyNumFrames;

%crop both videos according to max num of frames
frameInd = 0;
eye_only_movement.CurrentTime = eyes_only_start;
open(eye_only_cropped);
head_movement.CurrentTime = head_movement_start;
open(head_movement_cropped);

while frameInd < numFrames
    frameInd = frameInd + 1;
    im = readFrame(eye_only_movement);
    writeVideo(eye_only_cropped,im);
    
    
end
close(eye_only_cropped);
close(head_movement_cropped);

%% make movie from screenshot
screenVidWriter = VideoWriter('screen.mp4');
open(screenVidWriter);

im = imread(screenShotFilename);
frameInd = 0;
while frameInd < numFrames
    frameInd = frameInd + 1;
    writeVideo(screenVidWriter,im);
    
end
close(screenVidWriter);


