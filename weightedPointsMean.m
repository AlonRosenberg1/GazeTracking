function meanCords = weightedPointsMean(relevantPointsCord,weightCoef)
%this function will find the weighted mean between two (or more) points

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



