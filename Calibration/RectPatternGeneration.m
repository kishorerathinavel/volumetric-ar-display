% Calibration pattern and corresponding LED color codes generation
clear all;

%%
addpath('library');
data_folder_path = get_data_folder_path();
%
filename = sprintf('%s/Params/FocusDepth_sin.mat',data_folder_path);
load(filename);
%% generate rect pattern

I = zeros([768 1024]);

w = 450;
h = 240;

x = floor((1024-w)/2);
y = floor((768-h)/2);


I = insertShape(I, 'Rectangle',[x,y,w,h],'Color','White','Linewidth',1);
I = insertShape(I, 'Line',[x,y+h/2,x+w,y+h/2],'Color','White','Linewidth',1);
I = insertShape(I, 'Line',[x+w/2,y,x+w/2,y+h],'Color','White','Linewidth',1);
I_RGB = I*255;
imshow(I_RGB,[]);

%% store the rect patterns(only one image per 280)
num =20;
Location = int64(linspace(1,280,num));


NumofBP = 280;

for i= 1:length(Location)
    Test = zeros([768 1024 280]);
    Test(:,:,Location(i)) = I_RGB(:,:,1);
    Test_unorder = Test(:,:,un_order);
for j=1:NumofBP
      filename = sprintf('%s/Calibration/CalibratedRect/set%d/Scene_%03d.png', data_folder_path, i,j);
      imwrite(Test_unorder(:,:,j),filename);  
end
end

%% rect patterns in all positions defined by Location 280
Test = zeros([768 1024 280]);
Test(:,:,Location) = repmat(I_RGB(:,:,1),1,1,num);
Test_unorder = Test(:,:,un_order);
for j=1:NumofBP
      filename = sprintf('%s/Calibration/CalibratedRect_20/set%d/Scene_%03d.png', data_folder_path, 0,j);
      imwrite(Test_unorder(:,:,j),filename); 
end


%% rect patterns in all 280 planes(Test set)
Test = zeros([768 1024 280]);
Test(:,:,:) = repmat(I_RGB(:,:,1),1,1,280);
Test_unorder = Test(:,:,un_order);
for j=1:NumofBP
      filename = sprintf('%s/Calibration/CalibratedRect/Test/Scene_%03d.png', data_folder_path,j);
      imwrite(Test_unorder(:,:,j),filename); 
end

%% Calibrate the Rect pattern images
load('Factor_z');
Test = zeros([768 1024 280]);
Test(:,:,Location) = repmat(I_RGB(:,:,1),1,1,num);
Test_undistort = FovResize(Location,1./S_z, Test);

Test_unorder = Test_undistort(:,:,un_order);
for j=1:NumofBP
      filename = sprintf('%s/Calibration/CalibratedRect_20/Calibrated/Scene_%03d.png', data_folder_path,j);
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

filename = sprintf('%s/Calibration/CalibratedRect_20/rect_codes%d.h', data_folder_path,i);

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

filename = sprintf('%s/Calibration/CalibratedRect_20/rect_codes%d.h', data_folder_path,0);

fileID=fopen(filename,'w');
fprintf(fileID,'%s',str1);
fprintf(fileID,'{');
fprintf(fileID,'%s,',IntensityHex_order{1:end-1});
fprintf(fileID,'%s',IntensityHex_order{end});
fprintf(fileID,'};');
fclose(fileID);
