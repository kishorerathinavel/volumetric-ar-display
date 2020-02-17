clear all;
close all;

%% 
print_images = false;

%% 
data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/RGBD_data', data_folder_path);
output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);
output_mat_files_dir = sprintf('%s/scene_decomposition_output/analysis_input', data_folder_path);

%% Creating a backup of the files that are used to generate each set of results
% copyfile adaptive_color_decomposition.m adaptive_color_decomposition_images/adaptive_color_decomposition.m
% copyfile custom_imagesc_save.m adaptive_color_decomposition_images/custom_imagesc_save.m

%% Display parameters
NumofBP=acd_get_num_binary_planes();
binarization_threshold = 1.0;

%% Input RGB, depth map, and depth planes

filename = sprintf('%s/trial_01_rgb.png',input_dir);
RGBImg=im2double(imread(filename));

filename = sprintf('%s/%s/FocusDepth_%03d.mat', data_folder_path, 'Params', NumofBP);
load(filename);

% Description of variables:
% d - distance to depth plane in meters ordered in sequence of when each depth plane is displayed.
% d_sort - sorted distanced to depth planes
% order - index for each entry in d_sort in d
% un_order - 1:num
% fov_sort - FoV for each depth plane following same order of d_sort

filename = sprintf('%s/trial_01_DepthMap.mat',input_dir);
load(filename);

%% Normalizing and Removing zeros from depth map
DepthMap_norm=DepthMapNormalization(DepthMap);
unique_DM_values = unique(sort(reshape(DepthMap_norm, 1, [])));
DepthMap_norm(DepthMap_norm == 0) = unique_DM_values(1,2);

%% Assuming that depth map is linearized
DepthList=linspace(0,1,NumofBP);
DepthSeparater=DepthList;

%% save or load bw_Img_all
savedata = true;
if(savedata)
    s = size(RGBImg);
    bw_Img_all = zeros(s(1), s(2), s(3), NumofBP);

    parfor subvolume_append = 1:NumofBP-1 
        trial = DepthMap_norm;
        trial(trial < DepthSeparater(subvolume_append)) = 0;
        trial(trial > DepthSeparater(subvolume_append+1)) = 0;
        bw = im2double(im2bw(trial,0));
        
        bw_Img = zeros(size(RGBImg));
        bw_Img(:,:,1) = bw;
        bw_Img(:,:,2) = bw;
        bw_Img(:,:,3) = bw;
        bw_Img_all(:,:,:,subvolume_append) = bw_Img;
    end

    save bw_Img_all.mat bw_Img_all -v7.3
else 
    load('bw_Img_all.mat');
end


%% Loop variables

residue = zeros(size(RGBImg));
actual_reconstruction = zeros(size(RGBImg));
expected_reconstruction = zeros(size(RGBImg));
Energy_all = [];
LED_ALL = zeros(NumofBP,3);
bin_image_ALL = zeros(size(RGBImg,1), size(RGBImg,2), NumofBP);

tic

for subvolume_append = 1:NumofBP-1 
    subvolume = bw_Img_all(:,:,:,subvolume_append).*RGBImg;
    expected_reconstruction = expected_reconstruction + subvolume;
    toOptimize = subvolume;
    toOptimize = toOptimize + residue;

    per_channel_energy = squeeze(sum(sum(toOptimize, 1), 2));
    [value, channel_order] = sort(per_channel_energy, 'descend');
    
    channel = channel_order(1);
    Energy_plane = [];
    %% Initialization

    channel_toOptimize = toOptimize(:,:,channel);
    
    LEDs = [0,0,0];
    nLEDs = returnNonZeroMeanOfChannels(toOptimize);
    nLEDs(nLEDs < 0) = 0;
    LEDs(channel) = nLEDs(channel);
    
    bin_img = zeros(size(channel_toOptimize));
    bin_img(channel_toOptimize/LEDs(channel) > binarization_threshold) = 1;
 
    img = displayedImage(LEDs, bin_img);

    residue = toOptimize - img;

    currEnergy = residue.*residue;
    currEnergy = sum(currEnergy(:));
    Energy_plane = [Energy_plane currEnergy];

    bin_image_ALL(:,:,subvolume_append) = bin_img;
    bin_colorized = zeros(size(RGBImg));
    bin_colorized(:,:,channel) = bin_img;
    
    LED_ALL(subvolume_append,:) = LEDs;
    actual_reconstruction = actual_reconstruction + img;
    residue = expected_reconstruction - actual_reconstruction;
    Energy_all = [Energy_all; Energy_plane];

    if(print_images)
        if(mod(subvolume_append, 1) == 0)
            filename = sprintf('%s/bin_colorized_%03d.png', output_dir, subvolume_append);
            custom_imagesc_save(bin_colorized, filename);
        end
        
        if(mod(subvolume_append, 1) == 0)
            filename = sprintf('%s/actual_reconstruction_%03d.png', output_dir, subvolume_append);
            custom_imagesc_save(actual_reconstruction, filename);
        end
        
        if(mod(subvolume_append, 1) == 0)
            filename = sprintf('%s/residue_%03d.png', output_dir, subvolume_append);
            custom_imagesc_save(abs(residue), filename);
        end
    end
end

toc

binary_images = bin_image_ALL;
dac_codes = LED_ALL;

exp_name = 'highest_energy_channel';

filename = sprintf('%s/%s_binary_images.mat', output_mat_files_dir, exp_name);
save(filename, 'binary_images', '-v7.3');

filename = sprintf('%s/%s_dac_codes.mat', output_mat_files_dir, exp_name);
save(filename, 'dac_codes', '-v7.3');

