% Generate Test Pattern to test the FOV change in Real Display
% Generate 3 Rectangles to be displayed on near, middle and far binary
% planes
% The color of near, middle and far rectangles are red, green and blue
% respectively
% Generate corresponding color codes to be sent to LED DAC control


%%
clear all;

%%
data_folder_path = get_data_folder_path();
output_dir = sprintf('%s/Calibration', data_folder_path);
%%
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
%% write Images

Location = [80, 200, 240];

Test = zeros([768 1024 280]);

Test(:,:,Location) = I;

Test_order = Test(:,:,un_order);
%%
NumofBP = 280;
 for i=1:NumofBP
        filename = sprintf('%s/TestPattern1/set1/Scene_%03d.png', output_dir, i);
        imwrite(Test_order(:,:,i),filename);  
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

filename = sprintf('%s/Test_codes.h', output_dir);

fileID=fopen(filename,'w');
fprintf(fileID,'%s',str1);
fprintf(fileID,'{');
fprintf(fileID,'%s,',IntensityHex_order{1:end-1});
fprintf(fileID,'%s',IntensityHex_order{end});
fprintf(fileID,'};');
fclose(fileID);


%% generate test image for phase detection

Location = 36:2:54;
NumofBP = 280;

for i=1:length(Location)
    Test = zeros([768 1024 280]);

    Test(:,:,Location(i)) = I(:,:,1);
    
   
 for j=1:NumofBP
        filename = sprintf('%s/PhaseDetection/Finest/set%d/Scene_%03d.png', output_dir, i,j);
        imwrite(Test(:,:,j),filename);  
 end
    
    
end
 %% Generate color codes all single color
 
for i =1
MaxIntensityHex='8555';
MaxIntensityDec=hex2dec(MaxIntensityHex);
 
R_index=zeros([280,1]);
G_index=zeros([280,1]);
B_index=zeros([280,1]);

%
R_index(Location(i)) = MaxIntensityDec;
%G_index(Location(2)) = MaxIntensityDec;
%B_index(Location(3)) = MaxIntensityDec;


IntensityR_Hex_all=num2cell(dec2hex(R_index),2);
IntensityG_Hex_all=num2cell(dec2hex(G_index),2);
IntensityB_Hex_all=num2cell(dec2hex(B_index),2);

%%
IntensityHex=cellfun(@(x,y,z) strcat('{0x',x,',0x',y,',0x',z,'}'),IntensityR_Hex_all, IntensityG_Hex_all,IntensityB_Hex_all,'Uniformoutput',false);

%IntensityHex_order=IntensityHex(un_order);


%%
str1='static uint16_t codes[][3]=';

filename = sprintf('%s/PhaseDetection/Finest/phase_codes%d.h', output_dir,i);

fileID=fopen(filename,'w');
fprintf(fileID,'%s',str1);
fprintf(fileID,'{');
fprintf(fileID,'%s,',IntensityHex{1:end-1});
fprintf(fileID,'%s',IntensityHex{end});
fprintf(fileID,'};');
fclose(fileID);
end

%% Generate dot pattern for distortion map

I = zeros([768 1024]);

w = 400;
h = 200;

x = floor((1024-w)/2);
y = floor((768-h)/2);

m =8;
n =8;
r = 1;
x_dots = linspace(x,x+w,m);
y_dots = linspace(y,y+h,n);

[x_grid, y_grid] = meshgrid(x_dots, y_dots);

circle_coord(:,1) = reshape(x_grid,m*n,1);
circle_coord(:,2) = reshape(y_grid,m*n,1);
circle_coord(:,3) = r;

I = insertShape(I, 'FilledCircle',circle_coord,'Color','White');
I = I*255;
imshow(I,[]);

%%
Location = 200:200+23;
Test = zeros([768 1024 280]);

Test(:,:,Location) = repmat(I(:,:,1),1,1,length(Location));
Test_order = Test(:,:,un_order);

%%
NumofBP = 280;
 for i=1:NumofBP
        filename = sprintf('%s/TestPattern2/Set0/Scene_%03d.png', output_dir, i);
        imwrite(Test_order(:,:,i),filename);  
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

filename = sprintf('%s/TestPattern2/dots_codes.h', output_dir);

fileID=fopen(filename,'w');
fprintf(fileID,'%s',str1);
fprintf(fileID,'{');
fprintf(fileID,'%s,',IntensityHex_order{1:end-1});
fprintf(fileID,'%s',IntensityHex_order{end});
fprintf(fileID,'};');
fclose(fileID);
