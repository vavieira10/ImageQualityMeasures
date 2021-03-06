function distortDatabaseImages(folder, extraFolder, database, inputFile, outputFile)

%% Reading images to be distorted
inputFile = fullfile(folder, database, 'NoDistortionFiles', inputFile);
outFilename = [folder database outputFile];
fidOut = fopen(outFilename, 'w');

% Distortions parameters
gaussian = linspace(0.5, 5, 4);
impulseNoise = linspace(0.05, 0.5, 4);
overExposure = linspace(10, 100, 4);
motionBlur = linspace(10, 60, 4);
wgn = linspace(0.002, 0.02, 4);
jpeg2000 = [25, 50, 75, 100];

images = readtable(inputFile, 'Delimiter', '\n', 'ReadVariableNames', false);
images = images.Var1;

%% For each image, generating the distortions
amountImages = length(images);
for i = 1:amountImages
   splitImagename = strsplit(images{i}, '.');
   imagename = splitImagename{1};
   extension = splitImagename(2);
   imageFilename = [folder database extraFolder images{i}];
   outputFilename = [folder database extraFolder];
   im = imread(imageFilename); 
   % Generating the distortions and saving the image
%    s = strcat(imagename, '_histspecification', '.', extension);
%    imwrite(histogramSpecification(im, 8), [outputFilename s{1}]);
   for j = 1:4
       s = strcat(imagename, '_gaussian', num2str(gaussian(j)), '.', extension);
       fprintf(fidOut, '%s\n', s{1});
       imwrite(imgaussfilt(im, gaussian(j)), [outputFilename s{1}]);
       
       s = strcat(imagename, '_impulse', num2str(impulseNoise(j)), '.', extension);
       fprintf(fidOut, '%s\n', s{1});
       imwrite(imnoise(im, 'salt & pepper', impulseNoise(j)), [outputFilename s{1}]);
       
       s = strcat(imagename, '_over_exposure', num2str(overExposure(j)), '.', extension);
       fprintf(fidOut, '%s\n', s{1});
       imwrite(im + overExposure(j), [outputFilename s{1}]);
       
       s = strcat(imagename, '_motion_blur', num2str(motionBlur(j)), '.', extension);
       fprintf(fidOut, '%s\n', s{1});
       H = fspecial('motion', motionBlur(j), motionBlur(j));
       imwrite(imfilter(im, H, 'replicate'), [outputFilename s{1}]);
       
       s = strcat(imagename, '_wgn', num2str(wgn(j)), '.', extension);
       fprintf(fidOut, '%s\n', s{1});
       imwrite(imnoise(im, 'gaussian', 0, wgn(j)), [outputFilename s{1}]);
       
       s = strcat(imagename, '_jpeg2000_', num2str(jpeg2000(j)), '.jp2');
       fprintf(fidOut, '%s\n', s);
       imwrite(im, [outputFilename s], 'jp2', 'CompressionRatio', jpeg2000(j));
   end
end

fclose(fidOut);

end

