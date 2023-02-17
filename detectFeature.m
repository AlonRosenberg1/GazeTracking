function bbox = detectFeature(im,globalParams)
% this function will detect face,mouth, nose and eyes bounding box 
% input - rgb image
% out 5x4 bbox matrix with bbox(1,:)= face, 2 is mouth, 3 is nose, 4 &5 is left and right eye
%current implementation is using vision.CascadeObjectDetector


numDetectors = globalParams.bboxNumDetector;

headInd = globalParams.headBboxIndex;
mouthInd = globalParams.mouthBboxIndex;
noseInd =  globalParams.noseBboxIndex;
leftEyeInd = globalParams.leftEyeBboxIndex;
rightEyeInd = globalParams.rightEyeBboxIndex;

pixelInSameLine = globalParams.pixelInSameLineFeatureDetector;



detectors{headInd} = vision.CascadeObjectDetector(); %face detector
detectors{mouthInd} = vision.CascadeObjectDetector('Mouth');
detectors{noseInd} = vision.CascadeObjectDetector('Nose');
detectors{leftEyeInd} = vision.CascadeObjectDetector('LeftEyeCART');
detectors{rightEyeInd} = vision.CascadeObjectDetector('RightEyeCART');

for featureInd = 2:numDetectors
    detectors{featureInd}.UseROI = true;
end


bbox = zeros(numDetectors,4); 

%detect a face
 tempBbox = detectors{headInd}(im);
     
 %detect nose mouth and eyes
 if ~isempty(tempBbox)
     bbox(1,:) = tempBbox(1,:); %if we have many fea
     roi = bbox(1,:); %our region of interest is the face, consider enlrage it a little
     
     for featureInd = 2:numDetectors
         tempBbox = step(detectors{featureInd},im,roi);
         if isempty(tempBbox)
             bbox(featureInd,:) = [0 0 0 0]; 
         else
             
             if featureInd == mouthInd || featureInd == noseInd   
                %prone false detrection, for now, tack the first object
                bbox(featureInd,:) = tempBbox(1,:); %if we have many features, how do we choose
             end
             

             if featureInd == leftEyeInd || featureInd == rightEyeInd %eyes most times detect more then 2 objects
                 if size(tempBbox,1) >2 %we detect more than 2 "eyes"
                     %we will choose 2 objects which are in similar horizontal line
                     
                     if size(tempBbox,1) >3 %breakpoint for debug
                         yValue = 1;
                     end
                     
                     yValue = tempBbox(:,2)+0.5*tempBbox(:,4);
                     numObj = length(yValue);
                     isSameLine = zeros(numObj);
                     
                     for nInd = 1:numObj
                         for mInd = nInd+1: numObj
                             isSameLine(nInd,mInd) = abs(yValue(nInd)-yValue(mInd))<=pixelInSameLine;
                         end
                     end
                     
                     %find 2 or more objects within same line
                     [firstObj secondObj] = find(isSameLine);
                     if isempty(firstObj) %no two objects within same line detected - return base on size
                    
                         objArea = tempBbox(:,3).*tempBbox(:,4);
                         [temp sortInd] = sort(objArea,'descend');

                         tempBbox = tempBbox(sortInd(1:2),:); %%continue with the 2 largest objects
                        
                     else
                         [temp highstObj] = sort(yValue(firstObj));
                         twoEyesBbox(1,:) = tempBbox(firstObj(highstObj(1)),:);
                         [temp highstObj] = sort(yValue(secondObj));
                         twoEyesBbox(2,:) = tempBbox(secondObj(highstObj(1)),:);
                         
                         tempBbox = twoEyesBbox;
                         
                        
                     end %if firstObj is empty
                         
                 end
                 [temp sortIndLeft] = sort(tempBbox(:,1)); %sort the 2 bbox from left (low x value) to right
                 
                     %choose left for left eye etc
                 if featureInd == leftEyeInd %we are detecting left eye
                     bbox(featureInd,:) = tempBbox(sortIndLeft(1),:);
                     
                 else %right eye
                     if length(tempBbox(:,1))>1
                        bbox(featureInd,:) = tempBbox(sortIndLeft(2),:);
                        
                     else %only one item
                        bbox (featureInd,:)= tempBbox;
                        
                     end

                 end %if featureInd==4

             end %if featureInd>3



         
         end %if is empty

     end %for num of detectors

     
 end %if there is atleast 1 face
end %function
 