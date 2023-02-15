function im = getNewFrame_temp(baseName,ind,globalParams)
%this is a temporary function to treat photos as video frame in respect of reading

calibFileType = globalParams.calibFileType;

suffixName = sprintf('_%02d',ind); %suffix of the current calibration point name
imName = sprintf('%s%s',baseName,suffixName,calibFileType);
im = imread(imName);
