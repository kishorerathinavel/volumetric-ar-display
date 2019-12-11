% Demo of test pattern after simple calibration
clear all;

%%
data_folder_path = get_data_folder_path();

%%
filename = sprintf('%s/Calibration/Fov_Capture/CalibrationDemo.mat',data_folder_path);
load(filename);
filename = sprintf('%s/%s/FocusDepth.mat',data_folder_path, 'FocusDepth');
load(filename);
%% Generate rectangle Images

I = zeros([768 1024]);

w = 400;
h = 200;

x = floor((1024-w)/2);
y = floor((768-h)/2);


I = insertShape(I, 'Rectangle',[x,y,w,h],'Color','White','Linewidth',5);
I = insertShape(I, 'Line',[x,y+h/2,x+w,y+h/2],'Color','White','Linewidth',5);
I = insertShape(I, 'Line',[x+w/2,y,x+w/2,y+h],'Color','White','Linewidth',5);
I = I*255;
imshow(I,[]);
%%
Location = [80, 200, 240];

Test = zeros([768 1024 280]);

Test(:,:,Location) = I;
%%
Test_undistort = FovResize(Location,1./v_factors, Test);

Test_undistort_order = Test_undistort(:,:,un_order);
%%
NumofBP = 280;
for i=1:NumofBP
      filename = sprintf('%s/Calibration/CalibratedPattern1/set1/Scene_%03d.png', data_folder_path, i);
      imwrite(Test_undistort_order(:,:,i),filename);  
end

 %% Generate Corresponding color codes
MaxIntensityHex='8555';
MaxIntensityDec=hex2dec(MaxIntensityHex);
 
R_index=zeros([280,1]);
G_index=zeros([280,1]);
B_index=zeros([280,1]);

%
R_index(Location(1)) = MaxIntensityDec;
G_index(Location(2)) = MaxIntensityDec;
B_index(Location(3)) = MaxIntensityDec;


IntensityR_Hex_all=num2cell(dec2hex(R_index),2);
IntensityG_Hex_all=num2cell(dec2hex(G_index),2);
IntensityB_Hex_all=num2cell(dec2hex(B_index),2);

%%
IntensityHex=cellfun(@(x,y,z) strcat('{0x',x,',0x',y,',0x',z,'}'),IntensityR_Hex_all, IntensityG_Hex_all,IntensityB_Hex_all,'Uniformoutput',false);

IntensityHex_order=IntensityHex(un_order);


%%
str1='static uint16_t codes[][3]=';

filename = sprintf('%s/Calibration/CalibratedPattern1/Test_codes3.h', data_folder_path);

fileID=fopen(filename,'w');
fprintf(fileID,'%s',str1);
fprintf(fileID,'{');
fprintf(fileID,'%s,',IntensityHex_order{1:end-1});
fprintf(fileID,'%s',IntensityHex_order{end});
fprintf(fileID,'};');
fclose(fileID);

%% generate calibrated dot pattern
I = zeros([768 1024]);

w = 400;
h = 200;

x = floor((1024-w)/2);
y = floor((768-h)/2);

m =8;
n =8;
r = 2;
x_dots = linspace(x,x+w,m);
y_dots = linspace(y,y+h,n);

[x_grid, y_grid] = meshgrid(x_dots, y_dots);

circle_coord(:,1) = reshape(x_grid,m*n,1);
circle_coord(:,2) = reshape(y_grid,m*n,1);
circle_coord(:,3) = r;

I = insertShape(I, 'FilledCircle',circle_coord,'Color','White');
I = I*255;
imshow(I,[]);

Location = 200:200+23;
Test = zeros([768 1024 280]);

Test(:,:,Location) = repmat(I(:,:,1),1,1,length(Location));
%%
Test_undistort = FovResize(Location,1./v_factors, Test);
Test_undistort_order = Test_undistort(:,:,un_order);
%%
NumofBP = 280;
for i=1:NumofBP
      filename = sprintf('%s/Calibration/CalibratedPattern2/Scene_%03d.png', data_folder_path, i);
      imwrite(Test_undistort_order(:,:,i),filename);  
end
%%
MaxIntensityHex='8555';
MaxIntensityDec=hex2dec(MaxIntensityHex);
 
R_index=zeros([280,1]);
G_index=zeros([280,1]);
B_index=zeros([280,1]);

%
R_index(Location) = MaxIntensityDec;
G_index(Location) = MaxIntensityDec;
B_index(Location) = MaxIntensityDec;


IntensityR_Hex_all=num2cell(dec2hex(R_index),2);
IntensityG_Hex_all=num2cell(dec2hex(G_index),2);
IntensityB_Hex_all=num2cell(dec2hex(B_index),2);

%%
IntensityHex=cellfun(@(x,y,z) strcat('{0x',x,',0x',y,',0x',z,'}'),IntensityR_Hex_all, IntensityG_Hex_all,IntensityB_Hex_all,'Uniformoutput',false);

IntensityHex_order=IntensityHex(un_order);


%%
str1='static uint16_t codes[][3]=';

filename = sprintf('%s/Calibration/dots_codes2.h', data_folder_path);

fileID=fopen(filename,'w');
fprintf(fileID,'%s',str1);
fprintf(fileID,'{');
fprintf(fileID,'%s,',IntensityHex_order{1:end-1});
fprintf(fileID,'%s',IntensityHex_order{end});
fprintf(fileID,'};');
fclose(fileID);