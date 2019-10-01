clear all;
close all;

tic

%% 
data_folder_path = get_data_folder_path();
input_dir = sprintf('RGB_Depth', data_folder_path);
output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);

%% Creating a backup of the files that are used to generate each set of results
copyfile heuristic_adaptive_decomposition.m adaptive_color_decomposition_images/heuristic_adaptive_decomposition.m
copyfile custom_imagesc_save.m adaptive_color_decomposition_images/custom_imagesc_save.m

%% Input RGB, depth map, and depth planes

filename = sprintf('%s/reference.png',input_dir);
RGBImg=im2double(imread(filename));

filename = sprintf('%s/%s/FocusDepth.mat',data_folder_path, 'FocusDepth');
load(filename);

% Description of variables:
% d - distance to depth plane in meters ordered in sequence of when each depth plane is displayed.
% d_sort - sorted distanced to depth planes
% order - index for each entry in d_sort in d
% un_order - 1:num
% fov_sort - FoV for each depth plane following same order of d_sort

filename = sprintf('%s/trial_01_DepthMap.mat',input_dir);
load(filename);

%% Display parameters
NumofBP=280;

%% Normalizing and Removing zeros from depth map
DepthMap_norm=DepthMapNormalization(DepthMap);
unique_DM_values = unique(sort(reshape(DepthMap_norm, 1, [])));
DepthMap_norm(DepthMap_norm == 0) = unique_DM_values(1,2);

%% Assuming that depth map is linearized
DepthList=linspace(0,1,NumofBP);
DepthSeparater=DepthList;

%% save or load bw_Img_all
savedata = false;
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

    filename = sprintf('bw_Img_all_%d.mat',NumofBP)
    save(filename, 'bw_Img_all', '-v7.3');
else 
    filename = sprintf('bw_Img_all_%d.mat',NumofBP)
    load(filename);
end

%% Loop variables

residue = zeros(size(RGBImg));
actual_reconstruction = zeros(size(RGBImg));
expected_reconstruction = zeros(size(RGBImg));
LED_ALL = zeros(NumofBP,3);

for subvolume_append = 1:NumofBP-1 
    subvolume = bw_Img_all(:,:,:,subvolume_append).*RGBImg;
    expected_reconstruction = expected_reconstruction + subvolume;
    

    %% Initialization

    toOptimize = subvolume;
    toOptimize = toOptimize + residue;
    
    per_channel_energy = squeeze(sum(sum(toOptimize, 1), 2));
    [value, channel] = max(per_channel_energy);
    
    channel_toOptimize = toOptimize(:,:,channel);
    
    nLEDs = returnNonZeroMeanOfChannels(toOptimize); % Document
    nLEDs(isnan(nLEDs)) = 0;
    
    LEDs = [0,0,0];
    LEDs(channel) = nLEDs(channel);
    LEDs(LEDs < 0) = 0;
   
    bin_img = zeros(size(channel_toOptimize));
    bin_img(channel_toOptimize > LEDs(channel)) = 1;
    
    img = displayedImage(LEDs, bin_img);

    residue = toOptimize - img;

    bin_colorized = zeros(size(RGBImg));
    bin_colorized(:,:,channel) = bin_img;
    if(mod(subvolume_append, 1) == 0)
        filename = sprintf('adaptive_color_decomposition_images/bin_colorized_%02d.png', subvolume_append);
        imwrite(bin_colorized, filename);
    end
    
    LED_ALL(subvolume_append,:) = LEDs;
    
    actual_reconstruction = actual_reconstruction + img;
    if(mod(subvolume_append, 1) == 0)
        filename = sprintf('adaptive_color_decomposition_images/actual_reconstruction_%02d.png', ...
                           subvolume_append);
        imwrite(actual_reconstruction, filename);
    end
    
    overall_residue = expected_reconstruction - actual_reconstruction;
    if(mod(subvolume_append, 1) == 0)
        filename = sprintf('adaptive_color_decomposition_images/overall_residue_%02d.png', subvolume_append);
        imwrite(abs(overall_residue), filename);
    end
    
end

save 'adaptive_color_decomposition_images/dac_codes.mat' LED_ALL -v7.3

toc
