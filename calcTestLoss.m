function [linearLoss squareLoss] = calcTestLoss(realCoords, estimateCoords )
%this function will calculate the score, or distance, of the estimation coordinates from real coordinates
%input is two numTest by 2 array, first is X than Y coords
%the linear score is simply eucledian norm beteen estimation and real coordinates
%square score is square of the linear norm, representing larger penelty for large error


squareLoss = (sum((realCoords - estimateCoords).^2,2));

linearLoss = sqrt(squareLoss);