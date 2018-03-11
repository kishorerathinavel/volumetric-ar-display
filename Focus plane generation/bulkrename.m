clear all;
close all;

for iter = 1:280
    str = sprintf('Model6/Scene_%03d.png', iter);
    img = imread(str);
    str = sprintf('Model9/Scene_%03d.png', mod(iter+40,280));
    imwrite(img, str);
end
