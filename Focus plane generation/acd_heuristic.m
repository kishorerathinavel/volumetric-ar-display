clear all;
close all;

%% 
print_images = true;

%% 

data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/RGBD_data', data_folder_path);
output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);
output_mat_files_dir = sprintf('%s/scene_decomposition_output/analysis_input', data_folder_path);

%% Display Settings
NumofBP=acd_get_num_binary_planes();

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

%% What is this?
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
Energy_all = [];
LED_ALL = zeros(NumofBP,3);
bin_image_ALL = zeros(size(RGBImg,1), size(RGBImg,2), NumofBP);
binarization_threshold = 1.0;

combinations = [[1,0,0]; [0,1,0]; [0,0,1]; [1,1,0]; [0,1,1]; [1,0,1]; [1,1,1]];

tic
previousEnergy = 0;

for subvolume_append = 1:NumofBP-1
    % if(subvolume_append == 124)
    %     waitforbuttonpress
    % end

    Energy_plane = [];
    subvolume = bw_Img_all(:,:,:,subvolume_append).*RGBImg;
    expected_reconstruction = expected_reconstruction + subvolume;

    %% Initialization

    toOptimize = subvolume;
    toOptimize = toOptimize + residue;
    
    LEDs = returnNonZeroMeanOfChannels(toOptimize); % Document
    LEDs(isnan(LEDs)) = 0;
    options = zeros(size(toOptimize,1), size(toOptimize,2),7);
    options = zeros(size(toOptimize,1), size(toOptimize,2),7);

    bin_img1 = toOptimize(:,:,1)/LEDs(1);
    bin_img2 = toOptimize(:,:,2)/LEDs(2);
    bin_img3 = toOptimize(:,:,3)/LEDs(3);
    bin_img1(isnan(bin_img1)) = 0;
    bin_img2(isnan(bin_img2)) = 0;
    bin_img3(isnan(bin_img3)) = 0;
    bin_img1(bin_img1 < binarization_threshold) = 0.0;
    bin_img2(bin_img2 < binarization_threshold) = 0.0;
    bin_img3(bin_img3 < binarization_threshold) = 0.0;

    for iter = 1:7
        curr_bin_img = ones(size(bin_img1,1), size(bin_img1,2));
        if(combinations(iter,1) ~= 0)
            curr_bin_img = curr_bin_img .* bin_img1;
        end
        if(combinations(iter,2) ~= 0)
            curr_bin_img = curr_bin_img .* bin_img2;
        end
        if(combinations(iter,3) ~= 0)
            curr_bin_img = curr_bin_img .* bin_img3;
        end
        options(:,:,iter) = curr_bin_img;
    end
    
    sum_options = zeros(7,1);
    for iter = 1:7
        curr_option = options(:,:,iter);
        sum_options(iter) = sum(combinations(iter,:))*sum(curr_option(:));
    end
   
    
    [sorted_sum_options, sort_indices] = sort(sum_options, 'descend');
   
    ind = 1;
    if(subvolume_append > 2)
        if(Energy_all(end-1,end) == Energy_all(end,end))
            ind = sort_indices(2);
        else
            ind = sort_indices(1);
        end
    else
        ind = sort_indices(1);
    end
    
    bin_img = options(:,:,ind);
    LEDs = LEDs.*combinations(ind,:);
    LEDs(isnan(LEDs)) = 0;
    
    img = displayedImage(LEDs, bin_img);
    if(~isempty(find(isnan(img))))
        waitforbuttonpress
    
    end
    residue = toOptimize - img;

    currEnergy = residue.*residue;
    residue(:,:,1) = residue(:,:,1)*combinations(ind,1);
    residue(:,:,2) = residue(:,:,2)*combinations(ind,2);
    residue(:,:,3) = residue(:,:,3)*combinations(ind,3);
    currEnergy = sum(currEnergy(:));
    Energy_plane = [Energy_plane currEnergy];

    %% Optimization
    for iter = 1:1

        lambda = 1.00; % Kishore: Do we need this factor?
        denominator = (bin_img.*bin_img + 1e-8);

        old_img = img;
        old_LEDs = LEDs;
        old_energy = currEnergy;
        
        numerator = (residue(:,:,1).*bin_img);
        delta = sum(numerator(:))./sum(denominator(:));
        LEDs(1) = LEDs(1) + lambda*delta;
        
        numerator = (residue(:,:,2).*bin_img);
        delta = sum(numerator(:))./sum(denominator(:));
        LEDs(2) = LEDs(2) + lambda*delta;
        
        numerator = (residue(:,:,3).*bin_img);
        delta = sum(numerator(:))./sum(denominator(:));
        LEDs(3) = LEDs(3) + lambda*delta;
        
        LEDs = LEDs.*combinations(ind,:);
        LEDs(isnan(LEDs)) = 0;
        
        img = displayedImage(LEDs, bin_img);
        if(~isempty(find(isnan(img))))
            waitforbuttonpress
        end
        residue = toOptimize - img;
        residue(:,:,1) = residue(:,:,1)*combinations(ind,1);
        residue(:,:,2) = residue(:,:,2)*combinations(ind,2);
        residue(:,:,3) = residue(:,:,3)*combinations(ind,3);
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
        
        if(mod(subvolume_append, 1) == 0)
            filename = sprintf('%s/target_%03d.png', output_dir, subvolume_append);
            custom_imagesc_save(toOptimize, filename);
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

exp_name = 'heuristic';

filename = sprintf('%s/%s_binary_images.mat', output_mat_files_dir, exp_name);
save(filename, 'binary_images', '-v7.3');

filename = sprintf('%s/%s_dac_codes.mat', output_mat_files_dir, exp_name);
save(filename, 'dac_codes', '-v7.3');

