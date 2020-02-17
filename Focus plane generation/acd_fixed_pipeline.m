clear all;
close all;

%% 
print_images = true;
descending = true;
rgb = true;


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
bitdepth = 8;

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

    for subvolume_append = 1:NumofBP-1 
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

    % save bw_Img_all.mat bw_Img_all -v7.3
else 
    load('bw_Img_all.mat');
end

%% Create binary volume
binary_volume = zeros(size(RGBImg,1), size(RGBImg,2), NumofBP+3*bitdepth-1);
LED_ALL = zeros(NumofBP+3*bitdepth-1,3);
channel = 1;
bitplane = 8;

tic
for color_plane_number = 1:NumofBP
    subvolume = uint8(255*bw_Img_all(:,:,:,color_plane_number).*RGBImg);
    gray_subvolume = squeeze(sum(subvolume,3));
    index = find(gray_subvolume);
    for iter = 1:numel(index)
        [r,c] = ind2sub(size(gray_subvolume), index(iter)); 
        RB=double(de2bi(subvolume(r,c,1),bitdepth));
        GB=double(de2bi(subvolume(r,c,2),bitdepth));
        BB=double(de2bi(subvolume(r,c,3),bitdepth));
        
        if(rgb) % rgb
            pattern = [RB GB BB];
        else % bgr
            pattern = [BB GB RB];
        end
        
        shift = mod(color_plane_number - 1, 3*bitdepth);
        pattern = circshift(pattern, -shift);
        binary_volume(r,c,color_plane_number:color_plane_number+3*bitdepth-1) = pattern;
    end
end
toc

%% LEDs
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

LEDs_ALL = repmat(LEDs_24_planes, [ceil((NumofBP+3*bitdepth-1)/24), 1]);

%% Printing binary volume
actual_reconstruction = zeros(size(RGBImg));

for binary_plane_number  = 1:NumofBP
    bin_img = binary_volume(:,:,binary_plane_number);
    LEDs = LEDs_ALL(binary_plane_number,:);
    img = displayedImage(LEDs, bin_img);
    actual_reconstruction = actual_reconstruction + img;
    
    if(print_images)
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

return;
waitforbuttonpress


% binary_volume(:,:,3*bitdepth/2 + NumofBP:end) = [];
% binary_volume(:,:,1:3*bitdepth/2-1) = [];

% LEDs_ALL(NumofBP+3*bitdepth/2:end,:) = [];
% LEDs_ALL(1:3*bitdepth/2-1,:) = [];


%% Loop variables
residue = zeros(size(RGBImg));
actual_reconstruction = zeros(size(RGBImg));
expected_reconstruction = zeros(size(RGBImg));

for binary_plane_number  = 1:NumofBP
    subvolume = bw_Img_all(:,:,:,binary_plane_number).*RGBImg;
    expected_reconstruction = expected_reconstruction + subvolume;
    
    bin_img = binary_volume(:,:,binary_plane_number);
    LEDs = LEDs_ALL(binary_plane_number,:);
    
    img = displayedImage(LEDs, bin_img);
    actual_reconstruction = actual_reconstruction + img;

    residue = expected_reconstruction - actual_reconstruction;
    
    if(print_images)
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
dac_codes = LEDs_ALL/256;

exp_name = 'fixed_pipeline';

filename = sprintf('%s/%s_binary_images.mat', output_mat_files_dir, exp_name);
save(filename, 'binary_images', '-v7.3');

filename = sprintf('%s/%s_dac_codes.mat', output_mat_files_dir, exp_name);
save(filename, 'dac_codes', '-v7.3');


