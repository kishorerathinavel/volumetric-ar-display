clear all;
close all;

%% Execution parameters
print_images = false;
binarization_threshold = 1.0;

%% Paths
data_folder_path = data_folder_path();
output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);
output_mat_files_dir = sprintf('%s/scene_decomposition_output/analysis_input', data_folder_path);

%% Display Settings
NumofBP=num_binary_planes();

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
    % if(subvolume_append == 92)
    %     waitforbuttonpress;
    % end
    
    Energy_plane = [];
    subvolume = color_volume(:,:,:,subvolume_append);
    expected_reconstruction = expected_reconstruction + subvolume;

    %% Initialization

    toOptimize = subvolume;
    toOptimize = toOptimize + residue;
    
    LEDs = non_zero_mean(toOptimize); % Document
    bin_img=zeros(size(toOptimize,1), size(toOptimize,2));

    r_delta_bin_img = residue(:,:,1)/LEDs(1);
    g_delta_bin_img = residue(:,:,2)/LEDs(2);
    b_delta_bin_img = residue(:,:,3)/LEDs(3);
    r_delta_bin_img(isnan(r_delta_bin_img)) = 0;
    g_delta_bin_img(isnan(g_delta_bin_img)) = 0;
    b_delta_bin_img(isnan(b_delta_bin_img)) = 0;
        
    delta_bin_img = r_delta_bin_img + g_delta_bin_img + b_delta_bin_img;
    bin_img = bin_img + delta_bin_img;
    bin_img(bin_img < binarization_threshold) = 0.0;
    bin_img(bin_img >= binarization_threshold) = 1.0;
    
    img = displayed_image(LEDs, bin_img);
    residue = toOptimize - img;

    currEnergy = residue.*residue;
    currEnergy = sum(currEnergy(:));
    Energy_plane = [Energy_plane currEnergy];

    %% Optimization
    for iter = 1:2

        lambda = 1.00; 
        denominator = (bin_img.*bin_img + 1e-8);

        old_img = img;
        old_LEDs = LEDs;
        old_energy = currEnergy;
        
        numerator = (residue(:,:,1).*bin_img);
        delta = sum(numerator(:))./sum(denominator(:));
        if(isnan(delta))
            delta = 0;
        end
        
        LEDs(1) = LEDs(1) + lambda*delta;
        
        numerator = (residue(:,:,2).*bin_img);
        delta = sum(numerator(:))./sum(denominator(:));
        if(isnan(delta))
            delta = 0;
        end
        LEDs(2) = LEDs(2) + lambda*delta;
        
        numerator = (residue(:,:,3).*bin_img);
        delta = sum(numerator(:))./sum(denominator(:));
        if(isnan(delta))
            delta = 0;
        end
        LEDs(3) = LEDs(3) + lambda*delta;
        
        LEDs(LEDs < 0) = 0;
        
        img = displayed_image(LEDs, bin_img);
        residue = toOptimize - img;
        currEnergy = residue.*residue;
        currEnergy = sum(currEnergy(:));
        Energy_plane = [Energy_plane currEnergy];
        
        r_delta_bin_img = residue(:,:,1)/LEDs(1);
        g_delta_bin_img = residue(:,:,2)/LEDs(2);
        b_delta_bin_img = residue(:,:,3)/LEDs(3);
        r_delta_bin_img(isnan(r_delta_bin_img)) = 0;
        g_delta_bin_img(isnan(g_delta_bin_img)) = 0;
        b_delta_bin_img(isnan(b_delta_bin_img)) = 0;
        
        old_img = img;
        old_bin_img = bin_img;
        old_energy = currEnergy;
        
        delta_bin_img = r_delta_bin_img + g_delta_bin_img + b_delta_bin_img;
        bin_img(delta_bin_img < -1.0) = 0.0;
        bin_img(bin_img >= 1.0) = 1.0;

        img = displayed_image(LEDs, bin_img);
        residue = toOptimize - img;
        currEnergy = residue.*residue;
        currEnergy = sum(currEnergy(:));
        
        Energy_plane = [Energy_plane currEnergy];
    end

    LED_ALL(subvolume_append,:) = LEDs;
    actual_reconstruction = actual_reconstruction + img;
    residue = expected_reconstruction - actual_reconstruction;
    Energy_all = [Energy_all; Energy_plane];
    bin_image_ALL(:,:,subvolume_append) = bin_img;
    
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

exp_name = 'projected_gradients';

filename = sprintf('%s/%s_binary_images.mat', output_mat_files_dir, exp_name);
save(filename, 'binary_images', '-v7.3');

filename = sprintf('%s/%s_dac_codes.mat', output_mat_files_dir, exp_name);
save(filename, 'dac_codes', '-v7.3');

