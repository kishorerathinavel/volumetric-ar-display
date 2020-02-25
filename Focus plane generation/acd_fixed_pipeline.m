clear all;
close all;

%% Execution parameters
print_images = false;
[descending, rgb] = acd_get_fixed_pipeline_settings();
clip_both_sides = true;

%% Paths
data_folder_path = get_data_folder_path();
output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);
output_mat_files_dir = sprintf('%s/scene_decomposition_output/analysis_input', data_folder_path);

%% Display parameters
NumofBP=acd_get_num_binary_planes();
bitdepth = 8;

%% Get color volume
color_volume = acd_get_color_volume();
size_color_volume = size(color_volume);

%% LEDs
if(descending)
    DDS_values = [128, 64, 32, 16, 8, 4, 2, 1];
else
    DDS_values = [1, 2, 4, 8, 16, 32, 64, 128];
end

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

LEDs_ALL = repmat(LEDs_24_planes, [ceil((NumofBP+3*bitdepth-1)/24), 1]);
LEDs_ALL = LEDs_ALL/256;

%% Create binary volume

if(descending == true)
    de2bi_option = 'left-msb';
else
    de2bi_option = 'right-msb';
end

binary_volume = zeros([size_color_volume(1:2) NumofBP+3*bitdepth-1]);
tic
for color_plane_number = 1:NumofBP
    subvolume = uint8(255*color_volume(:,:,:,color_plane_number));
    gray_subvolume = squeeze(sum(subvolume,3));
    index = find(gray_subvolume);
    for iter = 1:numel(index)
        [r,c] = ind2sub(size(gray_subvolume), index(iter)); 
        
        RB=double(de2bi(subvolume(r,c,1),bitdepth, de2bi_option));
        GB=double(de2bi(subvolume(r,c,2),bitdepth, de2bi_option));
        BB=double(de2bi(subvolume(r,c,3),bitdepth, de2bi_option));
        
        if(rgb) % rgb
            pattern = [RB GB BB];
        else % bgr
            pattern = [BB GB RB];
        end
        
        shift = mod(color_plane_number - 1, 3*bitdepth);
        pattern = circshift(pattern, -shift);
        overwrite_zero = sum(binary_volume(r,c,color_plane_number:color_plane_number+3*bitdepth-1));
        if(overwrite_zero == 0)
            binary_volume(r,c,color_plane_number:color_plane_number+3*bitdepth-1) = pattern;
        end
    end
end
toc

%% Clipping binary volume
if(clip_both_sides)
    shift = 6;
    binary_volume = circshift(binary_volume, -shift, 3);
    binary_volume(:,:,NumofBP+1:end) = [];
    
    LEDs_ALL = circshift(LEDs_ALL, -shift, 1);
    LEDs_ALL(NumofBP+1:end,:) = [];
    
    % binary_volume(:,:,3*bitdepth/2 + NumofBP:end) = [];
    % binary_volume(:,:,1:3*bitdepth/2-1) = [];

    % LEDs_ALL(NumofBP+3*bitdepth/2:end,:) = [];
    % LEDs_ALL(1:3*bitdepth/2-1,:) = [];
else
    binary_volume(:,:,NumofBP+1:end) = [];
    LEDs_ALL(NumofBP+1:end,:) = [];
end


%% Printing binary volume
residue = zeros(size_color_volume(1:3));
actual_reconstruction = zeros(size_color_volume(1:3));
expected_reconstruction = zeros(size_color_volume(1:3));
actual_reconstruction = zeros(size_color_volume(1:3));

for binary_plane_number  = 1:NumofBP
    subvolume = color_volume(:,:,:,binary_plane_number);
    expected_reconstruction = expected_reconstruction + subvolume;
    
    bin_img = binary_volume(:,:,binary_plane_number);
    LEDs = LEDs_ALL(binary_plane_number,:);
    img = displayedImage(LEDs, bin_img);
    actual_reconstruction = actual_reconstruction + img;
    
    residue = expected_reconstruction - actual_reconstruction;
    
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
        
        if(mod(binary_plane_number, 1) == 0)
            filename = sprintf('%s/residue_%03d.png', output_dir, binary_plane_number);
            custom_imagesc_save(abs(residue), filename);
        end
    end
end

binary_images = binary_volume;
dac_codes = LEDs_ALL;

exp_name = 'fixed_pipeline';

filename = sprintf('%s/%s_binary_images.mat', output_mat_files_dir, exp_name);
save(filename, 'binary_images', '-v7.3');

filename = sprintf('%s/%s_dac_codes.mat', output_mat_files_dir, exp_name);
save(filename, 'dac_codes', '-v7.3');


    