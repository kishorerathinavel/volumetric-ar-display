clear all;

%%
data_folder_path = data_folder_path();
input_dir = sprintf('%s/Params', data_folder_path);
%%
% MSBFirst
MaxIntensityHex='5055';
colorbit=24;
NumofBP=280;

filename = sprintf('%s/FocusDepth_sin.mat',input_dir);
load(filename);

m=colorbit/3;
n=floor(NumofBP/colorbit)+1;

filename = sprintf('%s/ColorCalibration.mat',input_dir);
load(filename);


MaxIntensityDec=hex2dec(MaxIntensityHex);
R_index=zeros([colorbit,1]);
G_index=zeros([colorbit,1]);
B_index=zeros([colorbit,1]);

%%
MaxIntensityDecR=MaxIntensityDec*0.6;
MaxIntensityDecG=MaxIntensityDec*1.2;
MaxIntensityDecB=MaxIntensityDec*kb;
%% for simple color decomposition
R_index(1:m)=0.5.^(0:1:m-1);
G_index(m+1:2*m)=0.5.^(0:1:m-1);
B_index(2*m+1:3*m)=0.5.^(0:1:m-1);
%% for calibration
R_index(1:m)=1;
G_index(m+1:2*m)=1;
B_index(2*m+1:3*m)=1;
%%
IntensityR_Dec=floor(R_index*MaxIntensityDecR);
IntensityG_Dec=floor(G_index*MaxIntensityDecG);
IntensityB_Dec=floor(B_index*MaxIntensityDecB);
%%
IntensityR_Dec_all=repmat(IntensityR_Dec,n,1);
IntensityG_Dec_all=repmat(IntensityG_Dec,n,1);
IntensityB_Dec_all=repmat(IntensityB_Dec,n,1);

IntensityR_Dec_all=IntensityR_Dec_all(1:NumofBP);
IntensityG_Dec_all=IntensityG_Dec_all(1:NumofBP);
IntensityB_Dec_all=IntensityB_Dec_all(1:NumofBP);

IntensityR_Hex_all=num2cell(dec2hex(IntensityR_Dec_all),2);
IntensityG_Hex_all=num2cell(dec2hex(IntensityG_Dec_all),2);
IntensityB_Hex_all=num2cell(dec2hex(IntensityB_Dec_all),2);


%%
IntensityHex=cellfun(@(x,y,z) strcat('{0x',x,',0x',y,',0x',z,'}'),IntensityR_Hex_all, IntensityG_Hex_all,IntensityB_Hex_all,'Uniformoutput',false);

IntensityHex_order=IntensityHex(un_order);
%%
str1='static uint16_t codes[][3]=';
fileID=fopen('codes.h','w');
fprintf(fileID,'%s',str1);
fprintf(fileID,'{');
fprintf(fileID,'%s,',IntensityHex_order{1:end-1});
fprintf(fileID,'%s',IntensityHex_order{end});
fprintf(fileID,'};');
fclose(fileID);
