% This code simulates the perceived imagery on Volumetric display due to
% FOV changes.
% Human Vision Sytem (HVS) is simply modeled as a pinhole camera
% More complex HVS model is left for future.

% fov_sort is sorted as to distances between binary image and eye
% from the nearest to the farthest.

%%
clear all;
warning off;

%%
data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/scene_decomposition_output/ColorDC_edit4', data_folder_path);
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


filename = sprintf('%s/Factor.mat', output_dir);
save(filename,'factor');
%% Simulation of a Test Pattern

%generate Test Pattern
color = {'red','green','blue'};
Test = zeros([768 1024 3 3]);

for i = 1:3
I=zeros([768 1024 3]);
w = 400;
h = 200;

x = floor((1024-w)/2);
y = floor((768-h)/2);


I = insertShape(I, 'Rectangle',[x,y,w,h],'Color',char(color(i)),'Linewidth',10);
I = insertShape(I, 'Line',[x,y+h/2,x+w,y+h/2],'Color',char(color(i)),'Linewidth',10);
I = insertShape(I, 'Line',[x+w/2,y,x+w/2,y+h],'Color',char(color(i)),'Linewidth',10);
Test(:,:,:,i) = I;

figure;
imshow(Test(:,:,:,i),[]);
end

Test = uint8(255*Test);

%%

Test_perceived = Myresize(factor([1 141 280]), Test);
Test_pinhole = uint8(sum(Test_perceived ,4));
imshow(Test_pinhole,[]);

%%
filename = sprintf('%s/TestPattern1.mat', output_dir);
save(filename, 'Test_pinhole');
filename = sprintf('%s/TestPattern1.png', output_dir);
imwrite(Test_pinhole,filename);