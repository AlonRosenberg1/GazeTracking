function OriDist = calcOrientationDistance(orientation1,orientation2)
%this function will calculate a distance between two given orientation
%the current metric is the ocledian norm (sqrt(dx^2+dy^2), but it can changed later on


dx = orientation1(1) - orientation2(1);
dy = orientation1(2) - orientation2(2);

OriDist = sqrt(dx^2 + dy^2);