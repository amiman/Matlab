function [ denoisedImage ] = NonLocalMeans( image,neighborhood,sigma,h,searchRadius,mode )

% Non local means algorithm based on: 
% A non-local algorithm for image denoising by Antoni Buades

[row,col,channels] = size(image);
h = h^2;

% if this is an RGB image convert to gray scale
if(channels == 3)
    image = rgb2gray(image);
end

% expand the matrix size accring to the neighborhood
step = floor(neighborhood/2);
padImage = double(padarray(image,[step step],'symmetric'));

% create gaussain kernel for weighting neighbrhood
gaussainKernel = CreateGaussain(0,0,sigma,sigma,1/sqrt(2*pi),neighborhood);

% allocate weight matrix
[newRow,newCol] = size(padImage);

% allocate denoised image
denoisedImage = zeros(newRow,newCol);

% Prepare neighborhood's
neighborhoods = zeros(row,col,neighborhood,neighborhood);

% if mode == 2 use high and low frequnciy for reconstruction of denoised image
if(mode == 2)
    
    % convolve the image with a gaussain
    lowFrequnciyImage = conv2(padImage,gaussainKernel,'same');
    highFrequnciyImage = padImage - lowFrequnciyImage;
    neighborhoodsHigh = zeros(row,col,neighborhood,neighborhood);
end



for i=step+1:1:newRow-step
     for j=step+1:1:newCol-step 
         neighborhoods(i,j,:,:) = padImage(i-step:i+step,j-step:j+step);
         if(mode == 2)
            neighborhoodsHigh(i,j,:,:) = highFrequnciyImage(i-step:i+step,j-step:j+step);
         end
     end
end

for n=step+1:1:newRow-step
    
    for m=step+1:1:newCol-step
        
        % Take the current neighborhood around the pixel
        mainNeighborhood = reshape(neighborhoods(n,m,:,:),neighborhood,neighborhood);  

        % like in the original implemntation only serach patches next to
        % main neighbrhood. This is justfied because of the property of
        % natural images that they have a similar patches in the neigbrhood
        % around them
        startI = max(step+1,n-searchRadius);
        maxI = min(newRow-step,n+searchRadius);
        startJ = max(step+1,m-searchRadius);
        maxJ = min(newCol-step,m+searchRadius);
        
        weightRow = length(startI:maxI);
        weightCol = length(startJ:maxJ);
        weight = -inf*ones(weightRow,weightCol);
        newValues = zeros(weightRow,weightCol);
        for i=startI:1:maxI      
            for j=startJ:1:maxJ
                % Take the neighborhood around the pixel
                if(n ~= i) || (m ~= j)
                    
                    currentNeighborhood = reshape(neighborhoods(i,j,:,:),neighborhood,neighborhood);   
                    
                    % according to mode save orignal value or high freqncy value
                    if(mode==1)
                        newValues(i-startI+1,j-startJ+1) = currentNeighborhood(step+1,step+1);
                    else
                        currentNeighborhoodHigh = reshape(neighborhoodsHigh(i,j,:,:),neighborhood,neighborhood);
                        newValues(i-startI+1,j-startJ+1) = currentNeighborhoodHigh(step+1,step+1);
                    end
                    
                    % Calculate the similarity using a gaussain weighting
                    weight(i-startI+1,j-startJ+1) = -1*norm((mainNeighborhood - currentNeighborhood).*gaussainKernel);
                end
            end  
        end

        % Normalize weight matrix
        weight = exp(weight./h);
        weight = weight./(sum(sum(weight)));
        
        % Applay weight matrix and calculate the new value of the current pixel
        if(mode==1)
            denoisedImage(n,m) = sum(sum(weight.*double(newValues)));
        else
            denoisedImage(n,m) = sum(sum(weight.*double(newValues))) + lowFrequnciyImage(n,m);
        end
        
    end
end

denoisedImage = denoisedImage(step+1:newRow-step,step+1:newCol-step);

end

