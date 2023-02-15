function meanCords = weightedPointsMean(relevantPointsCord,weightCoef)
%this function will find the weighted mean between two (or more) points

%weightCoef=minHeadDist;
%weightCoef=minEyeDist




numPoints = length(weightCoef);

if numPoints == 2
    totalWeight = sum(weightCoef);
    relatieWeight = ones(1,numPoints) - weightCoef./totalWeight; %lower distance should be more imporant
else
    myEps = 0.0001;
    tempWeights = weightCoef;
    tempWeights(tempWeights==0) = myEps;
    invWeight = 1./tempWeights;
    
    totalWeight = sum(invWeight);
    relatieWeight = invWeight./totalWeight;
    
end
meanCords(1) = round(sum(relevantPointsCord(:,1).*relatieWeight'));
meanCords(2) = round(sum(relevantPointsCord(:,2).*relatieWeight'));

%visualisation
%{
temp = zeros(768,1366);
temp(relevantPointsCord(1,2)-1:relevantPointsCord(1,2)+1,relevantPointsCord(1,1)-1:relevantPointsCord(1,1)+1) = 1;
temp(relevantPointsCord(2,2)-1:relevantPointsCord(2,2)+1,relevantPointsCord(2,1)-1:relevantPointsCord(2,1)+1) = 1;
if numPoints > 2
    temp(relevantPointsCord(3,2)-1:relevantPointsCord(3,2)+1,relevantPointsCord(3,1)-1:relevantPointsCord(3,1)+1) = 1;
    temp(relevantPointsCord(4,2)-1:relevantPointsCord(4,2)+1,relevantPointsCord(4,1)-1:relevantPointsCord(4,1)+1) = 1;
end
temp(meanCords(2)-1:meanCords(2)+1,meanCords(1)-1:meanCords(1)+1) = 0.5;
imshow(temp,[])
%}


