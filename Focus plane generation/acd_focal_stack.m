clear all;
close all;

%% Setting folder paths
data_folder_path = get_data_folder_path();
rendering_output_dir = sprintf('%s/RGBD_data', data_folder_path);
decomposition_output_dir = sprintf('%s/scene_decomposition_output/analysis_input', data_folder_path);
output_dir = sprintf('%s/scene_decomposition_output/analysis_output', data_folder_path);

%% Inputting data

filename = sprintf('%s/trial_01_rgb.png', rendering_output_dir);
RGBImg=im2double(imread(filename));

filename = sprintf('%s/%s/FocusDepth.mat', data_folder_path, 'FocusDepth');
load(filename);
% Description of variables:
% d - distance to depth plane in meters ordered in sequence of when each depth plane is displayed.
% d_sort - sorted distanced to depth planes
% order - index for each entry in d_sort in d
% un_order - 1:num
% fov_sort - FoV for each depth plane following same order of d_sort

filename = sprintf('%s/trial_01_DepthMap.mat',rendering_output_dir);
load(filename);

experiment_names = {'adaptive_color_decomposition_all_channels', 'highest_energy_channel_decomposition'};

exp_binary_images = zeros(768, 1024, 280, numel(experiment_names));
exp_dac_codes = zeros(280, 3, numel(experiment_names));

for iter = 1:numel(experiment_names)
    filename = sprintf('%s/%s_binary_images.mat', decomposition_output_dir, string(experiment_names(iter)));
    load(filename);

    filename = sprintf('%s/%s_dac_codes.mat', decomposition_output_dir, string(experiment_names(iter)));
    load(filename);
    
    exp_binary_images(:,:,:,iter) = binary_images;
    exp_dac_codes(:,:,iter) = dac_codes;
end

%% 

for iter = 1:10:280
    focal_plane_number = iter;
    
    reconstructed_focal_image = zeros(size(RGBImg));
    for defocus_plane_number = 1:280
        focal_plane_depth = d_sort(focal_plane_number);
        defocus_plane_depth = d_sort(defocus_plane_number);
        pupil_diameter = 3/1000; % 3 mm in meters
        convolution_kernel_physical_size = pupil_diameter*(abs(defocus_plane_depth - ...
                                                          focal_plane_depth))/ ...
            focal_plane_depth;
        convolution_kernel_physical_size = convolution_kernel_physical_size/2;
        
        field_of_view_degrees = 40;
        defocus_plane_image_size = 2*defocus_plane_depth*tan(degtorad(field_of_view_degrees/ ...
                                                          2));
        convolution_kernel_pixel_size = round(512*convolution_kernel_physical_size/defocus_plane_image_size);
        
        defocus_binary_slice = exp_binary_images(:,:,defocus_plane_number,1);
        
        if(convolution_kernel_pixel_size == 0)
            perceived_dbs = defocus_binary_slice;
        else
            convolution_kernel = fspecial('disk', convolution_kernel_pixel_size);
            perceived_dbs = conv2(defocus_binary_slice, convolution_kernel,'same');
        end
        
        defocus_color_image = zeros(size(defocus_binary_slice,1), ...
                                    size(defocus_binary_slice,2),3);
        defocus_color_image(:,:,1) = perceived_dbs*exp_dac_codes(defocus_plane_number,1,1);
        defocus_color_image(:,:,2) = perceived_dbs*exp_dac_codes(defocus_plane_number,2,1);
        defocus_color_image(:,:,3) = perceived_dbs*exp_dac_codes(defocus_plane_number,3,1);
        reconstructed_focal_image = reconstructed_focal_image + defocus_color_image;
    end

    filename = sprintf('%s/perceived_%03d.png', output_dir, iter);
    custom_imagesc_save(reconstructed_focal_image, filename);
end

