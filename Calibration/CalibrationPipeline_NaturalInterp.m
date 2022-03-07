%% Calibration pipeline
% Generate a lookup table for the display calibration
% Using matlab built-in natural interpolation method
% Natural interpolation method is designed for scattered data
clear all;
%% get the path where all data are stored
addpath('library');
data_folder_path =  get_data_folder_path();

%% extract point from the captured image

% variable indicating if using high resolution image
highres =false;



if ~highres
inputdir = sprintf('%s/Calibration/CalibratedCirclePattern/Capture',data_folder_path);
else
inputdir = sprintf('%s/Calibration/CalibratedCirclePattern/Capture/high_res',data_folder_path);
end

% read images
for i=1:5
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

for i = 1:5
ROI_Cell{i} = ROI;
end

% % detecting points
% for i=1:5
% points{i} = detectSURFFeatures(images_processed{i},'ROI',ROI,'NumOctaves',1,'MetricThreshold',900,'NumScaleLevels',4);
% end
% 
points = featureDetect(images_processed,'ROI',ROI_Cell);

for i=1:5
subplot(3,2,i),
imshow(images_processed{i},[]); hold on;
title(sprintf('Image %d',i));
plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','o','markersize',14,'linestyle','none');
plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','+','markersize',18,'linestyle','none');
end



%% mannul filter undetected points

featureNum = [8,10];

% variable indicating if mannully marking undetected points
manual =true;

if manual
    points = ManualSelect(images_processed, points,'ROI',ROI,'FeatureNum',featureNum);
end


% if manual
%     manual_location=[];
%     
% for i=1:5
%     imshow(images_processed{i},[]); hold on;
%     imagetitle = sprintf('Image %d',i);
%     title(imagetitle);
%     plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','o','markersize',14,'linestyle','none');
%     plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','+','markersize',18,'linestyle','none');
%     
%     NumofUndetected = 80 - points{i}.Count;
%     
%     if NumofUndetected>0
%         manual_location = zeros(NumofUndetected,2);
%     for k = 1:NumofUndetected  
%      [x,y] = ginput(1,'Color',[1,0,0]);
%      % hold on;
%      plot(x,y,'marker','o','color','r','markersize',10);
%      plot(x,y,'marker','+','color','r','markersize',10);
%      drawnow
%      manual_location(k,:) = [x,y];     
%     end
%     end
%     
%     points{i}.Location = [points{i}.Location;manual_location];
%     points{i}.Count = points{i}.Count + NumofUndetected;
% end
% end



for i=1:5
subplot(3,2,i),
imshow(images_processed{i},[]); hold on;
title(sprintf('Image %d',i));
plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','o','markersize',14,'linestyle','none');
plot(points{i}.Location(:,1),points{i}.Location(:,2),'color','g','marker','+','markersize',18,'linestyle','none');
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

[indx,c_x] = kmeans(points{j}.Location(:,1),10,'Replicates',5,'OnlinePhase','on');
[c_x_sort,c_x_order] = sort(c_x);
c_x_unorder(c_x_order)=1:10;

[indy,c_y] = kmeans(points{j}.Location(:,2),8,'Replicates',5,'OnlinePhase','on');
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
XYZTem(:,4) = Location(i);
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
clear all;
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

%% doing backward interpolation 
s=1;
DisplayPattern = zeros([768 1024 5]);

Interp2d = false;

for j=1:5
    
% z_query = ones(size(y_query))*d_sort(Location(j));
z_query = ones(size(y_query))*double(Location(j));

if (Interp2d)
% doing image pairwise 2D interpolation
FX = scatteredInterpolant(XYZ_sample(s:s+points{j}.Count-1,1),XYZ_sample(s:s+points{j}.Count-1,2),double(XDYDZD_sample(s:s+points{j}.Count-1,1)),'natural');
FY = scatteredInterpolant(XYZ_sample(s:s+points{j}.Count-1,1),XYZ_sample(s:s+points{j}.Count-1,2),double(XDYDZD_sample(s:s+points{j}.Count-1,2)),'natural');

X_Display = FX(x_query,y_query);
Y_Display = FY(x_query,y_query);




s = s+points{j}.Count;
else
% doing 3D volume interpolation 
FX = scatteredInterpolant(XYZ_sample(:,1),XYZ_sample(:,2),XYZ_sample(:,4),double(XDYDZD_sample(:,1)),'natural');
FY = scatteredInterpolant(XYZ_sample(:,1),XYZ_sample(:,2),XYZ_sample(:,4),double(XDYDZD_sample(:,2)),'natural');

X_Display = FX(x_query,y_query,z_query);
Y_Display = FY(x_query,y_query,z_query);
end



index = find(~isnan(X_Display));

X_Display_valid = X_Display(index);
Y_Display_valid = Y_Display(index);
Y_Display_valid = 768+1-Y_Display_valid;

for i =1:length(X_Display_valid)
DisplayPattern(int64(Y_Display_valid(i)),int64(X_Display_valid(i)),j) = 255;
end
clear X_Display Y_Display index X_Display_valid Y_Display_valid z_query
end


%%
implay(DisplayPattern);

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