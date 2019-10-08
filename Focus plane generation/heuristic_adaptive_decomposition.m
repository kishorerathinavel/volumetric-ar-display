clear all;
close all;

tic

%% 
data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/RGBD_data', data_folder_path);
output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);

%% Creating a backup of the files that are used to generate each set of results

%% Input RGB, depth map, and depth planes

filename = sprintf('%s/trial_01_rgb.png',input_dir);
RGBImg=im2double(imread(filename));

filename = sprintf('%s/%s/FocusDepth.mat', data_folder_path, 'FocusDepth');
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

    filename = sprintf('bw_Img_all_%d.mat',NumofBP);
    save(filename, 'bw_Img_all', '-v7.3');
else 
    filename = sprintf('bw_Img_all_%d.mat',NumofBP);
    load(filename);
end

%% Loop variables

residue = zeros(size(RGBImg));
actual_reconstruction = zeros(size(RGBImg));
expected_reconstruction = zeros(size(RGBImg));
LED_ALL = zeros(NumofBP,3);
bin_image_ALL = zeros(size(RGBImg,1), size(RGBImg,2), NumofBP);
Energy_all = [];

binarization_threshold = 1.4;
%binarization_threshold = 1.33;

for subvolume_append = 1:NumofBP-1 
    subvolume = bw_Img_all(:,:,:,subvolume_append).*RGBImg;
    expected_reconstruction = expected_reconstruction + subvolume;
    
    toOptimize = subvolume;
    toOptimize = toOptimize + residue;
    
    per_channel_energy = squeeze(sum(sum(toOptimize, 1), 2));
    [value, channel_order] = sort(per_channel_energy, 'descend');
    
    bin_img_all = zeros(size(toOptimize, 1), size(toOptimize, 2), 4);
    LEDs_all = zeros(3, 4);
    img_all = zeros(size(toOptimize,1), size(toOptimize,2), size(toOptimize,3), 4);
    residue_all = zeros(size(toOptimize,1), size(toOptimize,2), size(toOptimize,3), 4);
    energy_all = zeros(1,4);
    
    %% Calc binary image if we optimized only the channel with maximum energy
    channel_toOptimize = toOptimize(:,:,channel_order(1));
    
    nLEDs = returnNonZeroMeanOfChannels(toOptimize); % Document
    nLEDs(isnan(nLEDs)) = 0;
    
    
    LEDs = [0,0,0];
    LEDs(channel_order(1)) = nLEDs(channel_order(1));
    LEDs(LEDs < 0) = 0;
    
    bin_img = zeros(size(channel_toOptimize));
    bin_img(channel_toOptimize/LEDs(channel_order(1)) > binarization_threshold) = 1;
    
    img = displayedImage(LEDs, bin_img);
    residue = toOptimize - img;
    
    bin_img_all(:,:,1) = bin_img;
    LEDs_all(:,1) = LEDs;
    img_all(:,:,:,1) = img;
    residue_all(:,:,:,1) = residue;
    curr_energy = residue.*residue;
    energy_all(1) = sum(curr_energy(:));
    
    
    %% Calc binary image if we optimized the 1st and 2nd energy-sorted channels
    channel1_toOptimize = toOptimize(:,:,channel_order(1));
    channel2_toOptimize = toOptimize(:,:,channel_order(2));

    nLEDs = returnNonZeroMeanOfChannels(toOptimize); % Document
    nLEDs(isnan(nLEDs)) = 0;
    
    LEDs = [0,0,0];
    LEDs(channel_order(1)) = nLEDs(channel_order(1));
    LEDs(channel_order(2)) = nLEDs(channel_order(2));
    LEDs(LEDs < 0) = 0;
    
    bin_img1 = zeros(size(channel_toOptimize));
    bin_img1(channel1_toOptimize/LEDs(channel_order(1)) > binarization_threshold) = 1;
    
    bin_img2 = zeros(size(channel_toOptimize));
    bin_img1(channel1_toOptimize/LEDs(channel_order(2)) > binarization_threshold) = 1;
    
    bin_img = bin_img1.*bin_img2;
    toOptimize2 = zeros(size(toOptimize));
    toOptimize2(:,:,1) = toOptimize(:,:,1).*bin_img;
    toOptimize2(:,:,2) = toOptimize(:,:,2).*bin_img;
    toOptimize2(:,:,3) = toOptimize(:,:,3).*bin_img;
    
    nLEDs = returnNonZeroMinimumOfChannels(toOptimize2); % Document
    nLEDs(isnan(nLEDs)) = 0;
    
    LEDs = [0,0,0];
    LEDs(channel_order(1)) = nLEDs(channel_order(1));
    LEDs(channel_order(2)) = nLEDs(channel_order(2));
    LEDs(LEDs < 0) = 0;
    
    img = displayedImage(LEDs, bin_img);
    residue = toOptimize - img;
    
    bin_img_all(:,:,2) = bin_img;
    LEDs_all(:,2) = LEDs;
    img_all(:,:,:,2) = img;
    residue_all(:,:,:,2) = residue;
    curr_energy = residue.*residue;
    energy_all(2) = sum(curr_energy(:));
    
    %% Calc binary image if we optimized the 1st and 3rd energy-sorted channels
    channel1_toOptimize = toOptimize(:,:,channel_order(1));
    channel3_toOptimize = toOptimize(:,:,channel_order(3));

    nLEDs = returnNonZeroMeanOfChannels(toOptimize); % Document
    nLEDs(isnan(nLEDs)) = 0;
    
    LEDs = [0,0,0];
    LEDs(channel_order(1)) = nLEDs(channel_order(1));
    LEDs(channel_order(3)) = nLEDs(channel_order(3));
    LEDs(LEDs < 0) = 0;
    
    bin_img1 = zeros(size(channel_toOptimize));
    bin_img1(channel1_toOptimize/LEDs(channel_order(1)) > binarization_threshold) = 1;
    
    bin_img3 = zeros(size(channel_toOptimize));
    bin_img1(channel1_toOptimize/LEDs(channel_order(3)) > binarization_threshold) = 1;
    
    bin_img = bin_img1.*bin_img3;
    
    toOptimize3 = zeros(size(toOptimize));
    toOptimize2(:,:,1) = toOptimize(:,:,1).*bin_img;
    toOptimize2(:,:,2) = toOptimize(:,:,2).*bin_img;
    toOptimize2(:,:,3) = toOptimize(:,:,3).*bin_img;
    
    nLEDs = returnNonZeroMinimumOfChannels(toOptimize3); % Document
    nLEDs(isnan(nLEDs)) = 0;
    
    LEDs = [0,0,0];
    LEDs(channel_order(1)) = nLEDs(channel_order(1));
    LEDs(channel_order(3)) = nLEDs(channel_order(3));
    LEDs(LEDs < 0) = 0;
    
    img = displayedImage(LEDs, bin_img);
    residue = toOptimize - img;
    
    bin_img_all(:,:,3) = bin_img;
    LEDs_all(:,3) = LEDs;
    img_all(:,:,:,3) = img;
    residue_all(:,:,:,3) = residue;
    curr_energy = residue.*residue;
    energy_all(3) = sum(curr_energy(:));
    
    %% Calc binary image if we optimized all channels simultaneously
    channel1_toOptimize = toOptimize(:,:,channel_order(1));
    channel2_toOptimize = toOptimize(:,:,channel_order(2));
    channel3_toOptimize = toOptimize(:,:,channel_order(3));

    nLEDs = returnNonZeroMeanOfChannels(toOptimize); % Document
    nLEDs(isnan(nLEDs)) = 0;
    
    LEDs = [0,0,0];
    LEDs(channel_order(1)) = nLEDs(channel_order(1));
    LEDs(channel_order(2)) = nLEDs(channel_order(2));
    LEDs(channel_order(3)) = nLEDs(channel_order(3));
    LEDs(LEDs < 0) = 0;
    
    bin_img1 = zeros(size(channel_toOptimize));
    bin_img1(channel1_toOptimize/LEDs(channel_order(1)) > binarization_threshold) = 1;
    
    bin_img2 = zeros(size(channel_toOptimize));
    bin_img1(channel1_toOptimize/LEDs(channel_order(2)) > binarization_threshold) = 1;
    
    bin_img3 = zeros(size(channel_toOptimize));
    bin_img1(channel1_toOptimize/LEDs(channel_order(3)) > binarization_threshold) = 1;
    
    bin_img = bin_img1.*bin_img2.*bin_img3;
    toOptimize4 = zeros(size(toOptimize));
    toOptimize2(:,:,1) = toOptimize(:,:,1).*bin_img;
    toOptimize2(:,:,2) = toOptimize(:,:,2).*bin_img;
    toOptimize2(:,:,3) = toOptimize(:,:,3).*bin_img;
    
    nLEDs = returnNonZeroMinimumOfChannels(toOptimize4); % Document
    nLEDs(isnan(nLEDs)) = 0;
    
    LEDs = [0,0,0];
    LEDs(channel_order(1)) = nLEDs(channel_order(1));
    LEDs(channel_order(3)) = nLEDs(channel_order(3));
    LEDs(channel_order(3)) = nLEDs(channel_order(3));
    LEDs(LEDs < 0) = 0;
    
    img = displayedImage(LEDs, bin_img);
    residue = toOptimize - img;
    
    bin_img_all(:,:,4) = bin_img;
    LEDs_all(:,4) = LEDs;
    img_all(:,:,:,4) = img;
    residue_all(:,:,:,4) = residue;
    curr_energy = residue.*residue;
    energy_all(4) = sum(curr_energy(:));
    

    %% Choose best case
    [value, indices] = sort(energy_all, 'ascend');
    bin_img = bin_img_all(:,:,indices(1));
    LEDs = LEDs_all(:,indices(1));
    img = img_all(:,:,:,indices(1));
    residue = residue_all(:,:,:,indices(1));
    
    %% Outputing final choice
    bin_image_ALL(:,:,subvolume_append) = bin_img;
    Energy_all = [Energy_all; curr_energy];
    
    bin_colorized = zeros(size(RGBImg));
    if(LEDs(1) > 0)
        bin_colorized(:,:,1) = bin_img;
    end
    
    if(LEDs(2) > 0)
        bin_colorized(:,:,2) = bin_img;
    end
    
    if(LEDs(3) > 0)
        bin_colorized(:,:,3) = bin_img;
    end
    
    LED_ALL(subvolume_append,:) = LEDs;
    actual_reconstruction = actual_reconstruction + img;
    overall_residue = expected_reconstruction - actual_reconstruction;
    
    if(mod(subvolume_append, 1) == 0)
        filename = sprintf('%s/bin_colorized_%03d.png', output_dir, subvolume_append);
        imwrite(bin_colorized, filename);
    end
    
    if(mod(subvolume_append, 1) == 0)
        filename = sprintf('%s/actual_reconstruction_%03d.png', output_dir, subvolume_append);
        imwrite(actual_reconstruction, filename);
    end
    
    if(mod(subvolume_append, 1) == 0)
        filename = sprintf('%s/overall_residue_%03d.png', output_dir, subvolume_append);
        imwrite(abs(overall_residue), filename);
    end
    
end

binary_images = bin_image_ALL;
filename = sprintf('%s/heuristic_adaptive_decomposition_binary_images.mat', output_dir);
save(filename, 'binary_images', '-v7.3');

dac_codes = LED_ALL;
filename = sprintf('%s/heuristic_adaptive_decomposition_dac_codes.mat', output_dir);
save(filename, 'dac_codes', '-v7.3');

toc
