function [gaze bbox globalParams] = getGaze(im,calibData,globalParams,useHeadOnly)
%this function will calculate the current frame's gaze (x,y) by comparing current orientation to calibration orientation
%algorithm :
%1) get current frame head and eye orientation
%2) alternative 1:
%    a) get the closest 2 points (in resepect to head orientation diff) from head only data
%    b) baseline head gaze is weighted mean of those 2 points
%    c) get 2 closet points (in respect to eye orientation diff) from eyes only data
%    d) set eye adjustment vector to be the weighted mean of those 2 points
%    e) add eye adjustment vector to baseline head gaze point
%2) alternative 2:
%    a) calculate total orientation distance (diff) (head diff + eye diff) to all calib points
%    b) choose 4 closests points
%    c) do weighted mean to get eye gaze

numberOfClosePoints = 4;%the number of close points to calculate mean location between them

numHeadCalibPoints = globalParams.numHeadCalibPoints;  %number of calibration point to calibrate head orientation
numEyesCalibPoints = globalParams.numEyesCalibPoints; %number of calib points to calib eyes orientation
cantFindOri = globalParams.cantFindOrientationValue;

headDistance = zeros(1,numHeadCalibPoints+numEyesCalibPoints); %to do - switch them to scalar
bothEyesDist = zeros(1,numHeadCalibPoints+numEyesCalibPoints); %to do - switch them to scalar
totalOriDistance = zeros(1,numHeadCalibPoints+numEyesCalibPoints);


calibrationPointsOrientation = calibData.calibrationPointsOrientation;
screenPointsCord = calibData.screenPointsCord;

[currOrientation bbox] = extractFrameOrientation(im,globalParams);

currHeadOri = currOrientation.headOrientation;
currEyeOriLeft = currOrientation.leftEyeOrientation;
currEyeOriRight = currOrientation.rightEyeOrientation;

%% for debug, show all orientations and bbox in one cell
currFrame.headOrientation = currHeadOri;
currFrame.leftEyeOrientation = currEyeOriLeft;
currFrame.rightEyeOrientation = currEyeOriRight;
currFrame.headBbox = bbox(globalParams.headBboxIndex,:);
currFrame.headSize = bbox(globalParams.headBboxIndex,3)*bbox(globalParams.headBboxIndex,4);
currFrame.leftEyeBbox = bbox(globalParams.leftEyeBboxIndex);
currFrame.leftEyeSize = bbox(globalParams.leftEyeBboxIndex,3)*bbox(globalParams.leftEyeBboxIndex,4);
currFrame.rightEyeBbox = bbox(globalParams.rightEyeBboxIndex);
currFrameex.rightEyeSize = bbox(globalParams.rightEyeBboxIndex,3)*bbox(globalParams.rightEyeBboxIndex,4);



if currHeadOri(1) == cantFindOri
    tempGaze = [cantFindOri cantFindOri];
else
    
    %% alternative 2 - calc head and eye orientation distance from current frame to each calib point
    for ind = 1:numHeadCalibPoints+numEyesCalibPoints
        calibPointHeadOri = calibrationPointsOrientation{ind}.headOrientation;
        if calibPointHeadOri(1) == cantFindOri
            headDistance(ind) = intmax; %there is not head in <ind> calib point
        else
            headDistance(ind) = calcOrientationDistance(currHeadOri,calibPointHeadOri);
        end
       
        if currEyeOriLeft(1)==cantFindOri && currEyeOriRight(1)==cantFindOri
            eyesDistanceLeft = 0;
            eyesDistanceRight = 0;
            
            
            
            %add logic of what to do if we cant find any eye in current frame
        else %we detect at least one eye in current frame
        %calculate eyes distance to each calib point
            calibPointEyeOriLeft = calibrationPointsOrientation{ind}.leftEyeOrientation;
            calibPointEyeOriRight = calibrationPointsOrientation{ind}.rightEyeOrientation;
        
            if calibPointEyeOriLeft(1) == cantFindOri || currEyeOriLeft(1)==cantFindOri
                %eyesDistanceLeft(ind-numHeadCalibPoints) = intmax;
                eyesDistanceLeft = cast(intmax,'double');
            else
                %eyesDistanceLeft(ind-numHeadCalibPoints) = calcOrientationDistance(currEyeOriLeft,calibPointEyeOriLeft);
                eyesDistanceLeft = calcOrientationDistance(currEyeOriLeft,calibPointEyeOriLeft);
            end
        
            if calibPointEyeOriRight(1) == cantFindOri || currEyeOriRight(1)==cantFindOri
                %eyesDistanceRight(ind-numHeadCalibPoints) = intmax;
                eyesDistanceRight = cast(intmax,'double');
            else
                %eyesDistanceRight(ind-numHeadCalibPoints) = calcOrientationDistance(currEyeOriRight,calibPointEyeOriRight);
                eyesDistanceRight = calcOrientationDistance(currEyeOriRight,calibPointEyeOriRight);
            end
        
            %add the distances from 2 eye to account for both eyes distance
            %if one eye is not present for given calib use the distance for the other eye
            %if both eyes are not present for given calib - use intmax (dont use this calib point)
        
            if xor(eyesDistanceLeft == intmax,eyesDistanceRight == intmax)
                %only one of the eyes is detected - assume other eyes has same distance and add the values
                bothEyesDist(ind) = 2.0*min(eyesDistanceRight,eyesDistanceLeft);
            
            else %either both eyes didnt detect or both eyes have valid value
                if eyesDistanceRight == intmax %meaning both eyes didnt detec
                    bothEyesDist(ind) = cast(intmax,'double');
                else %meaning both eyes have valid value
                    bothEyesDist(ind) = eyesDistanceRight+eyesDistanceLeft;
                
                end %if one eye is not detected
            end %xor 
            
    
            %%add the head and eyes dist
            
        end %cant find both eyes
        
    end %for calib points
    
    %if both eyes didnt detected replace thier value with eye average
    if max(bothEyesDist)==intmax
        meanEyeDist = mean(bothEyesDist(bothEyesDist<intmax));
        bothEyesDist(bothEyesDist==intmax) = meanEyeDist;
    end
    
    %normelize the distances
    headDistMin = min(headDistance);
    headDistDelta = max(headDistance) - headDistMin;
    normHeadDist = (headDistance - headDistMin)./headDistDelta;
    
    eyesDistMin = min(bothEyesDist);
    eyesDistDelta = max(bothEyesDist) - eyesDistMin;
    normEyesDist = (bothEyesDist - eyesDistMin)./eyesDistDelta;
            
    totalOriDistance = bothEyesDist + headDistance;
    normTotalDist = normEyesDist + normHeadDist; %keep in mind that norm dist can be 0, which will force
                                                 %weigted mean to choose its point coords, use norm dist only for
                                                 %choosing best points, and mean should be calculated based on regualr
                                                 %dist
    
    
    %for debug - remove later
    if useHeadOnly
        totalOriDistance = headDistance;
        normTotalDist = normHeadDist;
    end
    
        

    %find minimum
    [minDist minInd] = sort(totalOriDistance);
    minDist = minDist(1:numberOfClosePoints);
    minInd = minInd(1:numberOfClosePoints);
    
    %find minimum
    [normMinDist normMinInd] = sort(normTotalDist);
    normMinDist = normMinDist(1:numberOfClosePoints);
    normMinInd = normMinInd(1:numberOfClosePoints);
    
    %for debug
    globalParams.minDist(globalParams.currFrame,:) = minDist;
    globalParams.minInd(globalParams.currFrame,:) = minInd;
    globalParams.normMinDist(globalParams.currFrame,:) = normMinDist;
    globalParams.normMinInd(globalParams.currFrame,:) = normMinInd;

    %get wieghted mean
    relevantPointsCord = screenPointsCord(minInd,:); 
    tempGaze = weightedPointsMean(relevantPointsCord,minDist);
  
    
end %if we cant find any eye in frame

gaze = tempGaze;