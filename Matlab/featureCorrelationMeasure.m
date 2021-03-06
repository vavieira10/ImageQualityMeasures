function [fcmMeasure] = featureCorrelationMeasure(logGaborNormImage, normMaskImage)
%featureCorrelationMeasure Function that computes the feature correlation
%measures based on the iris normalized segmented image

% Most of the variables names are following the paper Feature correlation evaluation approach for iris feature
% quality measure (by Craig Belcher, Yingzi Du, Zhi Zhou and Robert Ives) nomenclature.

%% Variables initialization
[rows, cols] = size(logGaborNormImage);

% information distance weighting variables
Beta = 0.005;
alpha = 1/Beta;
invalidRows = [];

%% Computing the measure

% in order to eliminate the effects of noise, the mean value of valid pixels of each row are assigned to the pixels that are covered
% by occlusions of the same row
for i = 1:rows
    noisePositions = find(normMaskImage(i, :) == 0);
    normalIrisPositions = find(normMaskImage(i, :) == 255);
    if(length(normalIrisPositions) > 0)
        normalIrisMean = mean(logGaborNormImage(i, normalIrisPositions));
        logGaborNormImage(i, noisePositions) = normalIrisMean;
    else
          invalidRows = [invalidRows i];
%         epsilon = 10e-10; % avoiding NaN values
%         normalIrisMean = epsilon;
    end
%     logGaborNormImage(i, noisePositions) = normalIrisMean;
end

logGaborNormImage(invalidRows, :) = [];
[rows, cols] = size(logGaborNormImage);
r = zeros(1, cols);
s = zeros(1, cols);
p = zeros(1, cols);
q = zeros(1, cols);
J = zeros(1, rows - 1);

% looping through the image rows and computing the correlation measures
% between them
for i = 1:rows-1
    
    r = logGaborNormImage(i, :);
    s = logGaborNormImage(i + 1, :);
    
    % computing the probability mass function of the both rows
    p = r./sum(r, 2);
    q = s./sum(s, 2);
    
    % information distance
    J(1, i) = relativeEntropy(p, q) + relativeEntropy(q, p);
end

% computing the FCM measure
FCM = mean(J)

%% Computing the measure normalization
if(0 <= FCM && FCM <= Beta)
    fcmMeasure = alpha*FCM;
else
    fcmMeasure = 1;
end

end

