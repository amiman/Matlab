clear all

% Load image and add noise
I = imread('./testImage1.jpg');
I = rgb2gray(I);
[row,col] = size(I);

% Go over several noise variances and calculate for each one of them the denoised image
noiseVariances = [0.001 0.003 0.005 0.007 0.009 0.013 0.02];
%noiseVariances = [0.001 0.005];

MSENoise = zeros(length(noiseVariances),1);
MSEMean = zeros(length(noiseVariances),1);
MSELowHigh = zeros(length(noiseVariances),1);

index = 1;
for noiseVarinace=noiseVariances
    index
    J = imnoise(I,'gaussian',0,noiseVarinace);

    % Run Non Local Means for denoising
    neighbrhood = 7;
    denoisedImageMeanPatches = NonLocalMeans(J,3,1,1,3*neighbrhood,1);
    denoisedImageLowHighPatches = NonLocalMeans(J,3,1,1,3*neighbrhood,2);

    % Calculate mean sqare error
    MSENoise(index,1) = sum(sum((I - J).^2))/(row*col);
    MSEMean(index,1) = sum(sum((I - uint8(denoisedImageMeanPatches)).^2))/(row*col);
    MSELowHigh(index,1) = sum(sum((I - uint8(denoisedImageLowHighPatches)).^2))/(row*col);
    
    index = index + 1;
end



