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
%%
% for each sample point in image space, there should be a correspoinding
% continous curve in the displayed volume space
% we can fit a line for each sample point, thus find the curve line in the
% displayed volume space. Then for each small region defined by the nearby
% 4 sample points, we can use 2D mapping and linear interpolation to find
% the correspond transformation.
% The viable displayed volume space is defined by within each small 4
% point region.

X_coord = zeros([10,14,280]);
Y_coord = zeros([10,14,280]);


z_query =1:280;

curr = 1;
X_z = zeros([10*14,Imgnum]);
Y_z = zeros([10*14,Imgnum]);

X_z_all = zeros([10*14,280]);
Y_z_all = zeros([10*14,280]);

use_polyfit = false;

for i = 1:14
    for j=1:10
        
        for k =1:Imgnum
            X_z(curr,k) = xy_data{k}.Location(j,i,1);
            Y_z(curr,k) = xy_data{k}.Location(j,i,2);           
        end
        
        if use_polyfit == true
        p_x = polyfit(double(Location), X_z(curr,:), 5);
        p_y = polyfit(double(Location), Y_z(curr,:), 5);
       
        
        X_z_all(curr,:) = polyval(p_x, z_query);
        Y_z_all(curr,:) = polyval(p_y, z_query);
        
        clear p_x p_y
        else
            
        X_z_all(curr,:) = interp1(double(Location), X_z(curr,:),z_query,'spline');
        Y_z_all(curr,:) = interp1(double(Location), Y_z(curr,:),z_query,'spline');
        
        end
        
        X_coord(j,i,:) = X_z_all(curr,:);
        Y_coord(j,i,:) = Y_z_all(curr,:);
        
        
        curr = curr+1;
    end
end

% view
viewnum = 100;

% x coordinates
plot(double(Location),X_z(viewnum,:),'o'); hold on;
plot(z_query,X_z_all(viewnum,:)); 

% y coordinates
plot(double(Location),Y_z(viewnum,:),'o'); hold on;
plot(z_query,Y_z_all(viewnum,:)); 
%%