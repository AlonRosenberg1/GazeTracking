close all
clear all

testVideo = VideoWriter('testVideo.mp4');
%testVideo = VideoWriter('testVideo.mp4','Archival');
open(testVideo);

numWebCams = length(webcamlist);
cam = webcam(numWebCams);

while 1
    tic
    im = snapshot(cam);
    writeVideo(testVideo,im);
    toc
    
end%while

clear cam
close(testVideo);