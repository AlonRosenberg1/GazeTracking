function [headOrientationX headOrientationY]  = getHeadOrientation(bbox)
%this function will calculate the head orientation based on the feature bbox
%currently it is the center of face bbox 

headOrientationX = bbox(1,1)+round(bbox(1,3)/2);
headOrientationY = bbox(1,2)+round(bbox(1,4)/2);