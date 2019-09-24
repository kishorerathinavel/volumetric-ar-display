% This code simulates the perceived imagery on Volumetric display due to
% FOV changes.
% Human Vision Sytem (HVS) is simply model as a pinhole camera
% More complex HVS model is left for future.

% fov_sort is sorted as to distances between binary image and eye
% from the nearest to the farthest.

%%
clear all;
warning off;

%%
data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);
output_dir = sprintf('%s/fov_simulation', data_folder_path);
%% load all files
filename = sprintf('%s/%s/FocusDepth.mat',data_folder_path, 'FocusDepth');
load(filename);
filename = sprintf('%s/ImageSeq_Binary.mat',input_dir);
load(filename);
%% Visualize data
figure;
imshow(uint8(sum(ImageSeq_Binary,4)),[]); % check correctness of ImageSeq_Binary

figure;

plot(d_sort, fov_sort); % check FOV diagram as to distance
title('FOV Diagram');
xlabel('Virtual Image Distance/m');
ylabel('FOV/degree');
%% find resizing factors for all binary images regarding to the nearest binary image
% use the nearest binary image as reference.

t1 = tand(fov_sort/2);
t2 = repmat(tand(fov_sort(1)/2), 1, size(fov_sort,2));
factor = t1./t2;

ImageSeq_perceived = Myresize(factor, ImageSeq_Binary);
Imagery_Pinhole = uint8(sum(ImageSeq_perceived,4));
%%
figure;
imshow(Imagery_Pinhole,[]);
%%
filename = sprintf('%s/PinholeCamera.mat', output_dir);
save(filename, 'ImageSeq_perceived');
filename = sprintf('%s/PinholeCamera.png', output_dir);
imwrite(Imagery_Pinhole,filename);
