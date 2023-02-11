close all;
clear all;

screenShotFilename = 'calibration_points_printscreen.png';

%% crop eyes only and with head movement to same length

eye_only_movement = VideoReader('camera_only_eye.mp4');
eye_only_cropped = VideoWriter('camera_only_eye_cropped.mp4');
head_movement = VideoReader('cam_head_movement.mp4');
head_movement_cropped = VideoWriter('cam_head_movement_cropped.mp4');

%%find start and end eye only
% frameInd = 0;
%  while hasFrame(eye_only_movement)
%      im = readFrame(eye_only_movement);
%      imshow(im);
%      eye_only_movement.CurrentTime
%      frameInd = frameInd+1
%      pause
%  end
eyes_only_start = 5.6000;
eyes_frameIndStart = 28;
eyes_only_end = 20.0641;
eyes_frameIndEnd = 110;
eyesOnlyNumFrames = eyes_frameIndEnd-eyes_frameIndStart+1;

%%find start and end with head movement
% frameInd = 0;
%  while hasFrame(head_movement)
%      im = readFrame(head_movement);
%      imshow(im);
%      head_movement.CurrentTime
%      frameInd = frameInd+1
%      pause
%  end
head_movement_start = 6.4001;
head_frameIndStart = 32;
head_movement_end = 23.9039;
head_frameIndend = 127;
withHeadNumFrames = head_frameIndend-head_frameIndStart+1;

numFrames = max(withHeadNumFrames,eyesOnlyNumFrames);

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
    im = readFrame(head_movement);
    writeVideo(head_movement_cropped,im);
    
end
close(eye_only_cropped);
close(head_movement_cropped);

%%crop the eye movement video
% 
% eye_only_movement.CurrentTime = eyes_only_start;
% open(eye_only_cropped);
% while eye_only_movement.CurrentTime <= eyes_only_end
%     im = readFrame(eye_only_movement);
%     writeVideo(eye_only_cropped,im);
% end
% close(eye_only_cropped);

%%crop the head movement video
% head_movement.CurrentTime = head_movement_start;
% open(head_movement_cropped);
% while head_movement.CurrentTime <= head_movement_end
%     im = readFrame(head_movement);
%     writeVideo(head_movement_cropped,im);
% end
% close(head_movement_cropped);


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


