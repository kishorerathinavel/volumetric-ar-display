% Calibration pattern and corresponding LED color codes generation
clear all;

%%
addpath('library');
data_folder_path = get_data_folder_path();
%
filename = sprintf('%s/Params/FocusDepth_sin.mat',data_folder_path);
load(filename);
%% generate circle pattern
I = zeros([768 1024]);

w = 400;
h = 260;

x = floor((1024-w)/2);
y = floor((768-h)/2);

m =14;
n =10;
r = 1;
x_dots = linspace(x,x+w,m);
y_dots = linspace(y,y+h,n);

[x_grid, y_grid] = meshgrid(x_dots, y_dots);

circle_coord(:,1) = reshape(x_grid,m*n,1);
circle_coord(:,2) = reshape(y_grid,m*n,1);
circle_coord(:,3) = r;

I_RGB = insertShape(I, 'FilledCircle',circle_coord,'Color','White');
I_RGB = I_RGB*255;
imshow(I_RGB,[]);

%% store the circle patterns(only one image per 280)

num = 10;
Location = int64(linspace(1,280,num));


NumofBP = 280;

for i= 1:length(Location)
    Test = zeros([768 1024 280]);
    Test(:,:,Location(i)) = I_RGB(:,:,1);
    Test_unorder = Test(:,:,un_order);
for j=1:NumofBP
      filename = sprintf('%s/Calibration/CalibratedCirclePattern2/set%d/Scene_%03d.png', data_folder_path, i,j);
      imwrite(Test_unorder(:,:,j),filename);  
end
end
%% circle patterns in all positions defined by Location 280
Test = zeros([768 1024 280]);
Test(:,:,Location) = repmat(I_RGB(:,:,1),1,1,num);
Test_unorder = Test(:,:,un_order);
for j=1:NumofBP
      filename = sprintf('%s/Calibration/CalibratedCirclePattern_21/set%d/Scene_%03d.png', data_folder_path,0,j);
      imwrite(Test_unorder(:,:,j),filename);  
end

%% calibrated circle patterns
load('Factor_z');
Test = zeros([768 1024 280]);
Test(:,:,Location) = repmat(I_RGB(:,:,1),1,1,num);
Test_undistort = FovResize(Location,1./S_z, Test);

Test_unorder = Test_undistort(:,:,un_order);
for j=1:NumofBP
      filename = sprintf('%s/Calibration/CalibratedCirclePattern_10/Calibrated/Scene_%03d.png', data_folder_path,j);
      imwrite(Test_unorder(:,:,j),filename); 
end

 %% Generate Corresponding color codes
for i=1:length(Location)
MaxIntensityHex='8555';
MaxIntensityDec=hex2dec(MaxIntensityHex);
 
R_index=zeros([280,1]);
G_index=zeros([280,1]);
B_index=zeros([280,1]);

R_index(Location(i)) = MaxIntensityDec;
G_index(Location(i)) = MaxIntensityDec;
B_index(Location(i)) = MaxIntensityDec;

IntensityR_Hex_all=num2cell(dec2hex(R_index),2);
IntensityG_Hex_all=num2cell(dec2hex(G_index),2);
IntensityB_Hex_all=num2cell(dec2hex(B_index),2);

IntensityHex=cellfun(@(x,y,z) strcat('{0x',x,',0x',y,',0x',z,'}'),IntensityR_Hex_all, IntensityG_Hex_all,IntensityB_Hex_all,'Uniformoutput',false);

IntensityHex_order=IntensityHex(un_order);
%%
str1='static uint16_t codes[][3]=';

filename = sprintf('%s/Calibration/CalibratedCirclePattern_21/circlePattern_codes%d.h', data_folder_path,i);

fileID=fopen(filename,'w');
fprintf(fileID,'%s',str1);
fprintf(fileID,'{');
fprintf(fileID,'%s,',IntensityHex_order{1:end-1});
fprintf(fileID,'%s',IntensityHex_order{end});
fprintf(fileID,'};');
fclose(fileID);
end
%% Generate Corresponding color codes for simutaneous
MaxIntensityHex='8555';
MaxIntensityDec=hex2dec(MaxIntensityHex);
 
R_index=zeros([280,1]);
G_index=zeros([280,1]);
B_index=zeros([280,1]);

R_index(Location) = MaxIntensityDec;
G_index(Location) = MaxIntensityDec;
B_index(Location) = MaxIntensityDec;

IntensityR_Hex_all=num2cell(dec2hex(R_index),2);
IntensityG_Hex_all=num2cell(dec2hex(G_index),2);
IntensityB_Hex_all=num2cell(dec2hex(B_index),2);

IntensityHex=cellfun(@(x,y,z) strcat('{0x',x,',0x',y,',0x',z,'}'),IntensityR_Hex_all, IntensityG_Hex_all,IntensityB_Hex_all,'Uniformoutput',false);

IntensityHex_order=IntensityHex(un_order);
%%
str1='static uint16_t codes[][3]=';

filename = sprintf('%s/Calibration/CalibratedCirclePattern_21/circlePattern_codes%d.h', data_folder_path,0);

fileID=fopen(filename,'w');
fprintf(fileID,'%s',str1);
fprintf(fileID,'{');
fprintf(fileID,'%s,',IntensityHex_order{1:end-1});
fprintf(fileID,'%s',IntensityHex_order{end});
fprintf(fileID,'};');
fclose(fileID);

%% detect circle center location and store them.
imshow(I_RGB,[]);
ROI = getrect;
rectangle('Position',ROI,'EdgeColor','r');

ROI_Cell{1} = ROI;

I_gray = rgb2gray(I_RGB);
I_gray_cell{1} = I_gray;
points = featureDetect(I_gray_cell,'ROI',ROI_Cell);
imshow(I_gray); hold on;
plot(points{1}.Location(:,1),points{1}.Location(:,2),'color','g','marker','o','markersize',14,'linestyle','none');
plot(points{1}.Location(:,1),points{1}.Location(:,2),'color','g','marker','+','markersize',18,'linestyle','none');

Xdyd = points{1}.Location;
filename = 'XdYd_10_14.mat';
save(filename,'Xdyd');
save('DepthLocation_10_14.mat','Location');
