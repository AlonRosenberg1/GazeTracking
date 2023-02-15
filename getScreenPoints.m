function screenPoints = getScreenPoints()
%this function will get the x,y coords (in matlab frame) of the calibration target points on screen
%the format will be 2D array, with first dim the number of points (first head than eyes) and 2nd dim will be [x y]
%currently it is done manually, but later morpological actions with cross will do the trick automatically

headCalibFileName = 'calibration\calibration_points_printscreen_headOnly.png';
eyesCalibFileName = 'calibration\calibration_points_printscreen_eyesOnly.png';
test01FileName = 'calibration\test_01.png';
test02FileName = 'calibration\test_02.png';
test03FileName = 'calibration\test_03.png';
test04FileName = 'calibration\test_04.png';
test05FileName = 'calibration\test_05.png';
test06FileName = 'calibration\test_06.png';
test07FileName = 'calibration\test_07.png';

numHeadCalibPoints = 5;  %number of calibration point to calibrate head orientation
numEyesCalibPoints = 11; %number of calib points to calib eyes orientation

%{
im = imread(test07FileName);
imshow(im)
%}
%im = imread(headCalibFileName);

%imshow(im)
%head only part
screenPoints(1,:) = [687 388];
screenPoints(2,:) = [85 386];
screenPoints(3,:) = [1283 389];
screenPoints(4,:) = [686 84];
screenPoints(5,:) = [686 695];

%im = imread(eyesCalibFileName);
%imshow(im)
%eyes only part
screenPoints(6,:) = [89 84];
screenPoints(7,:) = [520 85];
screenPoints(8,:) = [952 88];
screenPoints(9,:) = [1282 85];
screenPoints(10,:) = [283 402];
screenPoints(11,:) = [745 403];
screenPoints(12,:) = [1141 402];
screenPoints(13,:) = [89 693];
screenPoints(14,:) = [520 691];
screenPoints(15,:) = [950 691];
screenPoints(16,:) = [1280 691];