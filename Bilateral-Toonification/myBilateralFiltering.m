function y = myBilateralFiltering(input_image, spatial_sigma, intensity_sigma, pad)

% we go from -pad to +pad for every pixel
y = zeros(size(input_image));
for i = 1:3
    y(:,:,i) = nlfilter(input_image(:,:,i), [2*pad+1, 2*pad+1], @(x)myWeightCalculation(x, spatial_sigma, intensity_sigma));
end