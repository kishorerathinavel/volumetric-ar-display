clear all;
close all;

%% Execution parameters
print_images = false;

%% Paths
data_folder_path = get_data_folder_path();
output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);
output_mat_files_dir = sprintf('%s/scene_decomposition_output/analysis_input', data_folder_path);

%% Display parameters
NumofBP=acd_get_num_binary_planes();
binarization_threshold = 1.0;

%% Get color volume
color_volume = acd_get_color_volume();
size_color_volume = size(color_volume);

%% Loop variables

residue = zeros(size_color_volume(1:3));
actual_reconstruction = zeros(size_color_volume(1:3));
expected_reconstruction = zeros(size_color_volume(1:3));
LED_ALL = zeros(NumofBP,3);
bin_image_ALL = zeros([size_color_volume(1:2) NumofBP]);
Energy_all = [];

tic

for subvolume_append = 1:NumofBP-1 
    subvolume = color_volume(:,:,:,subvolume_append);
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
    bin_img2(channel2_toOptimize/LEDs(channel_order(2)) > binarization_threshold) = 1;
    
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
    bin_img3(channel3_toOptimize/LEDs(channel_order(3)) > binarization_threshold) = 1;
    
    bin_img = bin_img1.*bin_img3;
    
    toOptimize3 = zeros(size(toOptimize));
    toOptimize3(:,:,1) = toOptimize(:,:,1).*bin_img;
    toOptimize3(:,:,2) = toOptimize(:,:,2).*bin_img;
    toOptimize3(:,:,3) = toOptimize(:,:,3).*bin_img;
    
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
    bin_img2(channel2_toOptimize/LEDs(channel_order(2)) > binarization_threshold) = 1;
    
    bin_img3 = zeros(size(channel_toOptimize));
    bin_img3(channel3_toOptimize/LEDs(channel_order(3)) > binarization_threshold) = 1;
    
    bin_img = bin_img1.*bin_img2.*bin_img3;
    toOptimize4 = zeros(size(toOptimize));
    toOptimize4(:,:,1) = toOptimize(:,:,1).*bin_img;
    toOptimize4(:,:,2) = toOptimize(:,:,2).*bin_img;
    toOptimize4(:,:,3) = toOptimize(:,:,3).*bin_img;
    
    nLEDs = returnNonZeroMinimumOfChannels(toOptimize4); % Document
    nLEDs(isnan(nLEDs)) = 0;
    
    LEDs = [0,0,0];
    LEDs(channel_order(1)) = nLEDs(channel_order(1));
    LEDs(channel_order(2)) = nLEDs(channel_order(2));
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
    
    LED_ALL(subvolume_append,:) = LEDs;
    actual_reconstruction = actual_reconstruction + img;
    overall_residue = expected_reconstruction - actual_reconstruction;

    if(print_images)
        bin_colorized = zeros(size_color_volume(1:3));
        if(LEDs(1) > 0)
            bin_colorized(:,:,1) = bin_img;
        end
        
        if(LEDs(2) > 0)
            bin_colorized(:,:,2) = bin_img;
        end
        
        if(LEDs(3) > 0)
            bin_colorized(:,:,3) = bin_img;
        end
        
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
end

toc

binary_images = bin_image_ALL;
dac_codes = LED_ALL;

exp_name = 'brute_force';

filename = sprintf('%s/%s_binary_images.mat', output_mat_files_dir, exp_name);
save(filename, 'binary_images', '-v7.3');

filename = sprintf('%s/%s_dac_codes.mat', output_mat_files_dir, exp_name);
save(filename, 'dac_codes', '-v7.3');

