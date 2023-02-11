function bbox = detectFeature(im)
% this function will detect face,mouth, nose and eyes bounding box 
% input - rgb image
% out 5x4 bbox matrix with bbox(1,:)= face, 2 is mouth, 3 is nose, 4 &5 is left and right eye
%current implementation is using vision.CascadeObjectDetector


numDetectors = 5;
detectors{1} = vision.CascadeObjectDetector(); %face detector
detectors{2} = vision.CascadeObjectDetector('Mouth');
detectors{3} = vision.CascadeObjectDetector('Nose');
detectors{4} = vision.CascadeObjectDetector('LeftEyeCART');
detectors{5} = vision.CascadeObjectDetector('RightEyeCART');

for featureInd = 2:numDetectors
    detectors{featureInd}.UseROI = true;
end


bbox = zeros(numDetectors,4);

%detect a face
 tempBbox = detectors{1}(im);
     
 %detect nose mouth and eyes
 if ~isempty(tempBbox)
     bbox(1,:) = tempBbox(1,:); %if we have many fea
     roi = bbox(1,:); %our region of interest is the face, consider enlrage it a little

     for featureInd = 2:numDetectors
         tempBbox = step(detectors{featureInd},im,roi);
         if featureInd < 4   %ind 2 and 3 is mouth and nose
            %prone false detrection, for now, tack the first object
            bbox(featureInd,:) = tempBbox(1,:); %if we have many features, how do we choose
         end
         %{
         tempIm = insertObjectAnnotation(im,'rectangle',tempBbox,'');   
         imshow(tempIm)

         tempIm = insertObjectAnnotation(im,'rectangle',tempBbox(1,:),'');   
         imshow(tempIm)

          tempIm = insertObjectAnnotation(im,'rectangle',bbox,'');   
         imshow(tempIm)
         %}

         if featureInd > 3 %ind 4 and 5 is eyes - which always detect at least 2
             if size(tempBbox,1) >2 %we detect more than 2 eyes
                 objArea = tempBbox(:,3).*tempBbox(:,4);
                 [temp sortInd] = sort(objArea,'descend');

                 tempBbox = tempBbox(sortInd(1:2),:); %%continue with the 2 largest objects
             end
             [temp sortIndLeft] = sort(tempBbox(:,1)); %sort the 2 bbox from left (low x value) to right
                 %choose left for left eye etc
             if featureInd == 4 %we are detecting left eye
                 bbox(featureInd,:) = tempBbox(sortIndLeft(1),:);
             else %right eye
                 bbox(featureInd,:) = tempBbox(sortIndLeft(2),:);

             end %if featureInd==4

         end %if featureInd>3



         %{
         tempIm = insertObjectAnnotation(im,'rectangle',tempBbox,'');   
         imshow(tempIm)
         %}

     end %for num of detectors

     %{

     imAnotate = insertObjectAnnotation(im,'rectangle',bbox,'');   
     imshow(imAnotate)
     %}
 end %if there is atleast 1 face
end %function
 