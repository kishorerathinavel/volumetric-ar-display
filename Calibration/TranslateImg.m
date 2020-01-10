% Translate the sample obj with a [x,y] vector
% [x,y] defines the translation in x, y axes.
clear all;
close all;
warning off;
%%

data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/RGBD_data', data_folder_path);
%%
filename = sprintf('%s/trial_08_rgb.png',input_dir);
RGBImg=imread(filename);

filename = sprintf('%s/trial_08_DepthMap.mat',input_dir);
load(filename);

%% Translate Image
T = [200,100];

RGBImg_trans = imtranslate(RGBImg,T,'FillValues',[255;255;255]);

DepthMap_trans = imtranslate(DepthMap,T,'FillValues',1.0);

%% save image

filename = sprintf('%s/trial_09_rgb.png',input_dir);
imwrite(RGBImg_trans,filename);

DepthMap = DepthMap_trans;
filename = sprintf('%s/trial_09_DepthMap.mat',input_dir);
save(filename,'DepthMap');