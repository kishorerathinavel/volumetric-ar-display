%% Calibration pipeline
% Generate a lookup table for the display calibration
% Using matlab cubic interpolation
clear all;
%% get the path where all data are stored
data_folder_path =  get_data_folder_path();

%% extract point from the captured image

inputdir = sprintf('%s/Calibration/CalibratedCirclePattern/Capture',data_folder_path);

for i=1:5
    filename = sprintf('%s/set%d.png',inputdir,i);
    images{i} = imread(filename);
end

for i=1:5
    images_gray{i} = rgb2gray(images{i});
    images_gray{i} = imadjust(images_gray{i});
end


se = strel('disk',4);
for i=1:5
    images_erode{i} = imerode(images_gray{i},se);
    images_denoise{i} = imdilate(images_erode{i},se);
end


[m,n,d] =size(images{1});
ROI = [200,50,n-400,m-100];

for i=1:5
points{i} = detectSURFFeatures(images_denoise{i},'ROI',ROI,'NumOctaves',1,'MetricThreshold',900,'NumScaleLevels',4);
end

for i=1:5
subplot(3,2,i),
imshow(images_denoise{i},[]); hold on;
title(sprintf('Image %d',i));
plot(points{i}.selectStrongest(points{i}.Count));
end
%% load corresponding (xd,yd) data
load('DepthLocation.mat');
load('XdYd.mat');
filename = sprintf('%s/Params/FocusDepth_sin.mat',data_folder_path);
load(filename);

% flip the y coordinate of yd
% the captured image from display is upside down of the loaded parttern
Xdyd_flip = Xdyd;
Xdyd_flip(:,2) = 768 - Xdyd_flip(:,2) + 1;

%% reshape the captured points
clear xy_data;

for j=1:5
xy_matrix = zeros([8 10 2])-1;

[indx,c_x] = kmeans(points{j}.Location(:,1),10,'Replicates',3,'OnlinePhase','on');
[c_x_sort,c_x_order] = sort(c_x);
c_x_unorder(c_x_order)=1:10;

[indy,c_y] = kmeans(points{j}.Location(:,2),8,'Replicates',3,'OnlinePhase','on');
[c_y_sort,c_y_order] = sort(c_y);
c_y_unorder(c_y_order) = 1:8;

for i =1:(points{j}.Count)
    xy_matrix(c_y_unorder(indy(i)),c_x_unorder(indx(i)),:) = points{j}.Location(i,:);
    xy_data{j} = xy_matrix;
end

clear indx c_x c_x_sort c_x_order c_x_unorder indy c_y c_y_sort c_y_order c_y_unorder;
clear xy_matrix;
end
%% debug
% imshow(images_denoise{4},[]);
% hold on;
% for k =1
% plot(points{4}.Location(indy==k,1),points{4}.Location(indy==k,2),'color',rand(1,3),'Marker','*','LineStyle','none','MarkerSize',10);
% end
%%
% reshape the inported (xd,yd) data
xdyd(:,:,1) = reshape(Xdyd_flip(:,1),10,8)';
xdyd(:,:,2) = reshape(Xdyd_flip(:,2),10,8)';

% reorganize the data for interpolation
XDYD(:,1) = reshape(xdyd(:,:,1),8*10,1);
XDYD(:,2) = reshape(xdyd(:,:,2),8*10,1);

XDYDZD_sample =[];
XYZ_sample = [];

for i=1:5
dataTem = xy_data{i};
XYZTem(:,1) = reshape(dataTem(:,:,1),8*10,1);
XYZTem(:,2) = reshape(dataTem(:,:,2),8*10,1);
XYZTem(:,3) = d_sort(Location(i)); % using the the calculated z value
index = find(XYZTem(:,1)== -1); % rule out undetected points in display space
XYZTem(index,:) = [];
XYZ_sample = [XYZ_sample;XYZTem];

XDYDZDTem(:,1:2) = XDYD;
XDYDZDTem(:,3) = d_sort(Location(i));% using the the calculated z value(should measure the real z value instead)
XDYDZDTem(index,:) = []; % rule out corresponding points in rendering space
XDYDZD_sample =[XDYDZD_sample;XDYDZDTem];

clear XYZTem XDYDZDTem
end
%%
save('XYZ_sample.mat','XYZ_sample');
save('XDYDZD_sample.mat','XDYDZD_sample');
save('Points.mat', 'points');
%% Calibration test
% load data

data_folder_path =  get_data_folder_path();
load('XYZ_sample.mat');
load('XDYDZD_sample.mat');
load('DepthLocation.mat');
load('Points.mat');
filename = sprintf('%s/Params/FocusDepth_sin.mat',data_folder_path);
load(filename);
%% generate test image in display space
I = zeros([720 1280]);



x = min(points{5}.Location(:,1))+60;
y = min(points{5}.Location(:,2))+60;

w = max(points{5}.Location(:,1)) - x- 60;
h = max(points{5}.Location(:,2)) - y -60;

m =5;
n =5;
r = 3;
x_dots = linspace(x,x+w,m);
y_dots = linspace(y,y+h,n);

[x_grid, y_grid] = meshgrid(x_dots, y_dots);

circle_coord(:,1) = reshape(x_grid,m*n,1);
circle_coord(:,2) = reshape(y_grid,m*n,1);
circle_coord(:,3) = r;

I_RGB = insertShape(I, 'FilledCircle',circle_coord,'Color','White');
I_RGB = I_RGB*255;
imshow(I_RGB,[]);

%% generating query locations


x = 1:1280;
y = 1:720;
[x_grid,y_grid] = meshgrid(x,y);
index = find(I_RGB(:,:,1));

x_query = x_grid(:);
x_query = x_query(index);

y_query = y_grid(:);
y_query = y_query(index);

%% doing forward interpolation trilinear
% 2D bilinear interpolation




%% saving images to be displayed(set1-set5)
for i= 1:length(Location)
    Test = zeros([768 1024 280]);
    Test(:,:,Location(i)) = DisplayPattern(:,:,i);
    Test_unorder = Test(:,:,un_order);
for j=1:280
      filename = sprintf('%s/Calibration/CalibratedCirclePattern/Calibrate%d/Scene_%03d.png', data_folder_path, i,j);
      imwrite(Test_unorder(:,:,j),filename);  
end
end
%% saving images to be displayed(set0)
Test = zeros([768 1024 280]);
Test(:,:,Location) = DisplayPattern;
Test_unorder = Test(:,:,un_order);
for j=1:280
      filename = sprintf('%s/Calibration/CalibratedCirclePattern/Calibrate%d/Scene_%03d.png', data_folder_path, 0,j);
      imwrite(Test_unorder(:,:,j),filename);  
end