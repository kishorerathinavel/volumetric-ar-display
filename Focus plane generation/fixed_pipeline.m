clear all;
close all;
warning off;

%% 
print_images = true;
rgb = true;

%% Setting folder paths
data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/RGBD_data', data_folder_path);
output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);
output_mat_files_dir = sprintf('%s/scene_decomposition_output/analysis_input', data_folder_path);

%% Display Settings
NumofBP=acd_get_num_binary_planes();
colorbit=24;

%% Input RGB, depth map, and depth planes

filename = sprintf('%s/trial_01_rgb.png',input_dir);
RGBImg=imread(filename);

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

%% Fixed pipeline decomposition

tic
[Image_sequence,Image_CutVol]=fixed_pipeline_gen_img_seq(RGBImg,DepthMap,'NumofBP',NumofBP, 'colorbit',colorbit, 'rgb', rgb);
Image_CutVol=uint8(Image_CutVol);
ImageSeq_order=flipud(Image_sequence(:,:,un_order));
toc

%% Saves binary images

use_temporal_order = false;
if(use_temporal_order == true)
    for i=1:NumofBP
        filename = sprintf('%s/Calibration/Results/Bridge2/Scene_%03d.png', data_folder_path, i);
        imwrite(ImageSeq_order(:,:,i),filename);  
    end
else
    % if(print_images == true)
    %     for i=1:NumofBP
    %         filename = sprintf('%s/binary_%03d.png', output_dir, i);
    %         imwrite(Image_sequence(:,:,i),filename);  
    %     end
    % end
    
    DDS_values = [128, 64, 32, 16, 8, 4, 2, 1];
    LEDs_24_planes = zeros(24, 3);
    if(rgb == true)
        LEDs_24_planes(1:8, 1) = DDS_values';
        LEDs_24_planes(9:9+7, 2) = DDS_values';
        LEDs_24_planes(9+7+1:9+7+1+7, 3) = DDS_values';
    else % bgr
        LEDs_24_planes(1:8, 3) = DDS_values';
        LEDs_24_planes(9:9+7, 2) = DDS_values';
        LEDs_24_planes(9+7+1:9+7+1+7, 1) = DDS_values';
    end
    
    LEDs_ALL = repmat(LEDs_24_planes, [ceil(NumofBP/24), 1]);
    LEDs_ALL(NumofBP+1:end, :) = [];
    LEDs_ALL = LEDs_ALL/256;
    
    dac_codes = LEDs_ALL;
    binary_images = Image_sequence;
    
    actual_reconstruction = zeros(size(RGBImg));
    for binary_plane_number  = 1:NumofBP
        bin_img = binary_images(:,:,binary_plane_number);
        LEDs = LEDs_ALL(binary_plane_number,:);
        img = displayedImage(LEDs, bin_img);
        actual_reconstruction = actual_reconstruction + img;
        
        if(print_images)
            if(mod(binary_plane_number, 1) == 0)
                filename = sprintf('%s/binary_%03d.png', output_dir, binary_plane_number);
                custom_imagesc_save(bin_img, filename);
            end
            
            if(mod(binary_plane_number, 1) == 0)
                filename = sprintf('%s/bin_colorized_%03d.png', output_dir, binary_plane_number);
                custom_imagesc_save(img, filename);
            end
            
            if(mod(binary_plane_number, 1) == 0)
                filename = sprintf('%s/actual_reconstruction_%03d.png', output_dir, binary_plane_number);
                custom_imagesc_save(actual_reconstruction, filename);
            end
        end
    end
    
    exp_name = 'fixed_pipeline';

    filename = sprintf('%s/%s_binary_images.mat', output_mat_files_dir, exp_name);
    save(filename, 'binary_images', '-v7.3');

    filename = sprintf('%s/%s_dac_codes.mat', output_mat_files_dir, exp_name);
    save(filename, 'dac_codes', '-v7.3');
end

