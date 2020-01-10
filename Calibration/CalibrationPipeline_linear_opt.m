%% Calibration pipeline
% Generate a lookup table for the display calibration
% Using linear-volume interpolation method
clear all;
%% get the path where all data are stored
addpath('library');
data_folder_path =  get_data_folder_path();
%% extract point from the captured image

% variable indicating if using high resolution image
highres =false;

Imgnum = 10;

if ~highres
inputdir = sprintf('%s/Calibration/CalibratedCirclePattern_10/Capture',data_folder_path);
else
inputdir = sprintf('%s/Calibration/CalibratedCirclePattern_10/Capture/high_res',data_folder_path);
end

% read images
for i=1:Imgnum
    if highres
    filename = sprintf('%s/red/set%d_highres_red.JPG',inputdir,i);
    else
    filename = sprintf('%s/set%d.png',inputdir,i);
    end
    images{i} = imread(filename);
end

% pre-processing
if ~highres
images_processed = PreProcessing(images,'Pattern','dot','Disksize',4);
else
images_processed = PreProcessing(images,'Pattern','dot','Disksize',10);
end
%%
imshow(images_processed{1},[]);
ROI = getrect;
rectangle('Position',ROI,'EdgeColor','r');

for i = 1:Imgnum
ROI_Cell{i} = ROI;
end

points = featureDetect(images_processed,'ROI',ROI_Cell);

for i=1:Imgnum
figure
imshow(images_processed{i},[]); hold on;
title(sprintf('Image %d',i));
plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','o','markersize',14,'linestyle','none');
plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','+','markersize',18,'linestyle','none');
end
%%

featureNum = [10,14];

% variable indicating if mannully marking undetected points
manual =true;

if manual
    points = ManualSelect(images_processed, points,'ROI',ROI,'FeatureNum',featureNum);
end

for i=1:Imgnum
figure
imshow(images_processed{i},[]); hold on;
title(sprintf('Image %d',i));
plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','o','markersize',14,'linestyle','none');
plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','+','markersize',18,'linestyle','none');
end
%%
save points_10 points
%% load corresponding (xd,yd) data
load('DepthLocation_10_14.mat');
load('XdYd_10_14.mat');
filename = sprintf('%s/Params/FocusDepth_sin.mat',data_folder_path);
load(filename);

% flip the y coordinate of yd
% the captured image from display is upside down of the loaded parttern
Xdyd_flip = Xdyd;
Xdyd_flip(:,2) = 768 - Xdyd_flip(:,2) + 1;

%% reshape the captured points
xy_data = ReshapeFeatures(points,[10,14],'OriginalShape',0);
% reshape the inported (xd,yd) data
xdyd_points{1}.Location = Xdyd_flip;
xdyd_points{1}.Count = 10*14;
xdyd_data = ReshapeFeatures(xdyd_points,[10,14],'OriginalShape',0);

%% fitting an function 
% z' = z;
% y' = f1(x,y,z)
% x' = f2(x,y,z)
% where f1 and f2 are quadratic to x and y, and cubic to z


% chose only five planes for direct SVD solution
% leave others for optimization

X_coord = [];
Y_coord = [];
Z_coord = [];

XD_coord = [];
YD_coord = [];

for i=1:2:9
    x_tem = xy_data{i}.Location(:,:,1);
    y_tem = xy_data{i}.Location(:,:,2);
    
    X_coord = [X_coord; x_tem(:)];
    Y_coord = [Y_coord; y_tem(:)];
    Z_coord = [Z_coord; repmat(Location(i),10*14,1)];
    
    
    XD_coord = [XD_coord; reshape(xdyd_data{1}.Location(:,:,1),10*14,1)];
    YD_coord = [YD_coord; reshape(xdyd_data{1}.Location(:,:,2),10*14,1)];
end
ZD_coord = Z_coord;

m = length(X_coord);
% backward transform
A1 = [X_coord.^2, X_coord, ones([m,1])];
A2 = [Y_coord.^2, Y_coord, ones([m,1])];
A3 = double([Z_coord.^3, Z_coord.^2, Z_coord, ones([m,1])]);

A4 = [A1(:,1).*A2, A1(:,2).*A2, A1(:,3).*A2];
A5 = [A3(:,1).*A4, A3(:,2).*A4, A3(:,3).*A4, A3(:,4).*A4];

AX = [A5,-XD_coord];
AY = [A5,-YD_coord];

[UX,SX,VX] = svd(AX);
[UY,SY,VY] = svd(AX);


