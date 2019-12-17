% simple 3 sample interpolation calibration
clear all;

%%
addpath('library');
data_folder_path = get_data_folder_path();

%%
filename = sprintf('%s/Calibration/Fov_Capture/FOV9.png',data_folder_path);
fovImage = imread(filename);

filename = sprintf('%s/Params/cameraParams.mat',data_folder_path);
load(filename);

filename = sprintf('%s/fov_simulation/Factor.mat',data_folder_path);
load(filename);

imshow(fovImage, []);
%% Undistort the image using cameraParams
I_undistort = undistortImage(fovImage, cameraParams);

figure;
imshowpair(fovImage,I_undistort,'montage');
title('original(left) vs. Corrected(right)');


%% find corners in order
%I_gray = rgb2gray(I_undistort);

loaddata = true;


if loaddata == false
figure;
imshow(I_undistort, []);
x_n = zeros(12, 1);
y_n = zeros(12, 1);

for i=1:12
[x,y] = ginput(1);
hold on;
plot(x,y,'r+')
drawnow
x_n(i) = x;
y_n(i) = y;
end

else
    load('data.mat');
    figure;
    imshow(I_undistort, []); hold on;
    plot(x_n,y_n,'r+');
end
%%
save('data.mat', 'x_n','y_n');


%%
rect = zeros(3,4);

for i =1:3
    offset = (i-1)*4;
    rect(i,1) = x_n(2+offset) - x_n(1+offset);
    rect(i,2) = y_n(3+offset) - y_n(2+offset);
    rect(i,3) = x_n(3+offset) - x_n(4+offset);
    rect(i,4) = y_n(4+offset) - y_n(1+offset);
end

factors = rect./repmat(rect(1,:),3,1);
factors_mean = mean(factors,2);
%%
v_factors = interp1([1, 140 280],factors_mean',1:1:280);

figure;
plot(1:1:280,factor,'b-',1:1:280,v_factors,'r*');
%%
filename = sprintf('%s/Calibration/Fov_Capture/CalibrationDemo.mat',data_folder_path);
save(filename,'v_factors');