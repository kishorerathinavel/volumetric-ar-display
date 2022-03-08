clear all;
close all;

%% Execution parameters
print_images = false;

%% Paths
data_folder_path = data_folder_path();
output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);
output_mat_files_dir = sprintf('%s/scene_decomposition_output/analysis_input', data_folder_path);

%% Display parameters
NumofBP=num_binary_planes();
binarization_threshold = 1.0;

%% Get color volume
color_volume = color_volume();
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
    
    channel = channel_order(1);
    Energy_plane = [];
    %% Initialization

    channel_toOptimize = toOptimize(:,:,channel);
    
    LEDs = [0,0,0];
    nLEDs = non_zero_mean(toOptimize);
    nLEDs(nLEDs < 0) = 0;
    LEDs(channel) = nLEDs(channel);
    
    bin_img = zeros(size(channel_toOptimize));
    bin_img(channel_toOptimize/LEDs(channel) >= binarization_threshold) = 1;
 
    img = displayed_image(LEDs, bin_img);

    residue = toOptimize - img;

    currEnergy = residue.*residue;
    currEnergy = sum(currEnergy(:));
    Energy_plane = [Energy_plane currEnergy];

    bin_image_ALL(:,:,subvolume_append) = bin_img;
    bin_colorized = zeros(size_color_volume(1:3));
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

