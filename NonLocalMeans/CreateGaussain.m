function [ gaussian] = CreateGaussain( x0,y0,sig1,sig2,A,size)
%CREATEGAUSSAIN Summary of this function goes here
%   Detailed explanation goes here

gaussian = zeros(size,size);

step = floor(size/2);

for i=-step:1:step
    for j=-step:1:step
        gaussian((i+step + 1),(j+step + 1)) = A*exp(-(((i-x0)^2)/(2*sig1^2) + ((j-y0)^2)/(2*sig2^2)));
    end
end



end

