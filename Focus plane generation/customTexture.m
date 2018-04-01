img = zeros(500,500,3);
img(1:250,1:250,1) = 1;
img(251:end,1:250,2) = 1;
img(251:end,1:250,2) = 1;
img(1:250,251:end,3) = 1;
img(251:end,251:end,:) = 1;
imwrite(img, 'custom_rgb.jpg');

