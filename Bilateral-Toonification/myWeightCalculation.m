function y = myWeightCalculation(input_image, spatial_sigma, intensity_sigma)

h = size(input_image, 1);
w = size(input_image, 2);

centerX = floor((1 + h) / 2);
centerY = floor((1 + w) / 2);

intensity_weight = zeros(h, w);

for i = 1:h
    for j = 1:w
        diff_spat = (i - centerX)^2 + (j-centerY^2);
        exp_spat = exp(-diff_spat / (2*spatial_sigma*spatial_sigma));
        diff_int = (input_image(i,j) - input_image(centerX,centerY))^2;
        exp_int = exp(-diff_int / (2*intensity_sigma*intensity_sigma));
        intensity_weight(i,j) = exp_spat * exp_int;
    end
end
weight_matrix = intensity_weight ./ sum(sum(intensity_weight));
y = sum(sum(weight_matrix .* input_image));


