clear all;
close all;

%%
print_images = true;
show_images = false;

%% Setting folder paths
data_folder_path = get_data_folder_path();
rendering_output_dir = sprintf('%s/RGBD_data', data_folder_path);
decomposition_output_dir = sprintf('%s/scene_decomposition_output/analysis_input', data_folder_path);
output_dir = sprintf('%s/scene_decomposition_output/analysis_output', data_folder_path);

%% Display Settings
NumofBP = acd_get_num_binary_planes();
focal_plane_depth_all = [round(1:NumofBP/4:NumofBP) NumofBP];
pupil_radius = 2;

%% Inputting data

filename = sprintf('%s/trial_01_rgb.png', rendering_output_dir);
RGBImg=im2double(imread(filename));

filename = sprintf('%s/%s/FocusDepth_%03d.mat', data_folder_path, 'Params', NumofBP);
load(filename);
% Description of variables:
% d - distance to depth plane in meters ordered in sequence of when each depth plane is displayed.
% d_sort - sorted distanced to depth planes
% order - index for each entry in d_sort in d
% un_order - 1:num
% fov_sort - FoV for each depth plane following same order of d_sort

filename = sprintf('%s/trial_01_DepthMap.mat',rendering_output_dir);
load(filename);

experiment_names = {'fixed_pipeline', 'brute_force', 'highest_energy_channel', 'projected_gradients', 'heuristic'};
%experiment_names = {'fixed_pipeline', 'highest_energy_channel', 'projected_gradients', 'heuristic'};
%experiment_names = {'fixed_pipeline'};
%experiment_names = {'brute_force', 'highest_energy_channel', 'projected_gradients', 'heuristic'};
%experiment_names = {'projected_gradients', 'heuristic'};

exp_binary_images = zeros(768, 1024, NumofBP, numel(experiment_names));
exp_dac_codes = zeros(NumofBP, 3, numel(experiment_names));

for iter = 1:numel(experiment_names)
    filename = sprintf('%s/%s_binary_images.mat', decomposition_output_dir, string(experiment_names(iter)));
    load(filename);

    filename = sprintf('%s/%s_dac_codes.mat', decomposition_output_dir, string(experiment_names(iter)));
    load(filename);
    
    exp_binary_images(:,:,:,iter) = binary_images;
    exp_dac_codes(:,:,iter) = dac_codes;
end

%% Difference in weighed mean 

depth_planes = 1:NumofBP;
depth_planes = reshape(depth_planes, [1,1,NumofBP]);
depth_planes_volume = repmat(depth_planes, [768, 1024]);

for iter = 1:numel(experiment_names)
    string(experiment_names(iter))

    dac_codes = exp_dac_codes(:,:,iter);
    binary_images = exp_binary_images(:,:,:,iter);
    
    r_dac_z_column = reshape(dac_codes(:,1), [1,1,NumofBP]);
    r_dac_code_volume = repmat(r_dac_z_column, [768, 1024]);
    
    g_dac_z_column = reshape(dac_codes(:,2), [1,1,NumofBP]);
    g_dac_code_volume = repmat(g_dac_z_column, [768, 1024]);

    b_dac_z_column = reshape(dac_codes(:,3), [1,1,NumofBP]);
    b_dac_code_volume = repmat(b_dac_z_column, [768, 1024]);

    r_perceived_volume = r_dac_code_volume.*binary_images;
    g_perceived_volume = g_dac_code_volume.*binary_images;
    b_perceived_volume = b_dac_code_volume.*binary_images;
    
    % nnpx_exp_binary_images = exp_binary_images(:,:,:,iter);
    nnpx_exp_binary_images = zeros([size(r_perceived_volume) 3]);
    nnpx_exp_binary_images(:,:,:,1) = r_perceived_volume;
    nnpx_exp_binary_images(:,:,:,2) = g_perceived_volume;
    nnpx_exp_binary_images(:,:,:,3) = b_perceived_volume;
    nnpx_exp_binary_images(nnpx_exp_binary_images > 0.0039) = 1;
    nnpx_count_exp = squeeze(sum(sum(nnpx_exp_binary_images,4),3));
    
    if(print_images)
        nnpx_count_exp_output = nnpx_count_exp;
        nnpx_count_exp_output(nnpx_count_exp_output < 0) = 0;
        nnpx_count_exp_output(nnpx_count_exp_output > 75) = 75;
        filename = sprintf('%s/NZ_BV_%02d.png', output_dir, iter);
        imwrite( ind2rgb(im2uint8(mat2gray(nnpx_count_exp_output)), parula(256)), filename)
    end

    if(show_images)
        figure; 
        clims = [0 15];
        imagesc(nnpx_count_exp, clims);
        title_str = sprintf('%s - # non-zero binary voxels', string(experiment_names(iter)));
        title(title_str, 'Interpreter', 'None');
    end



    perceived_image = zeros(768, 1024, 3);
    perceived_image(:,:,1) = sum(r_perceived_volume, 3);
    perceived_image(:,:,2) = sum(g_perceived_volume, 3);
    perceived_image(:,:,3) = sum(b_perceived_volume, 3);

    diffImg = RGBImg - perceived_image;
    energyImg = diffImg.*diffImg;
    if(print_images)
        filename = sprintf('%s/PI_BV_%02d.png', output_dir, iter);
        imwrite(diffImg, filename);
    end
    
    if(show_images & false)
        figure; 
        imagesc(diffImg);
        title_str = sprintf('%s - perceived image difference', string(experiment_names(iter)));
        title(title_str, 'Interpreter', 'None');
    end
    
    
    r_variance = var(r_perceived_volume.*depth_planes_volume, 0, 3);
    g_variance = var(g_perceived_volume.*depth_planes_volume, 0, 3);
    b_variance = var(b_perceived_volume.*depth_planes_volume, 0, 3);

    w_variance = zeros(768, 1024, 3);
    w_variance(:,:,1) = r_variance;
    w_variance(:,:,2) = g_variance;
    w_variance(:,:,3) = b_variance;

    added_volume = r_perceived_volume + g_perceived_volume + b_perceived_volume;
    variance = var(added_volume, 0, 3);

    if(show_images & false)
        figure; 
        imagesc(variance); 
        title_str = sprintf('%s - variance', string(experiment_names(iter)));
        title(title_str, 'Interpreter', 'None');
    end
    
    % nz_nnpx_count_exp = (nonzero)_(number of pixels)_(count)_(experiment)
    nz_nnpx_count_exp = nnpx_count_exp(nnpx_count_exp > 0);
    mean_nn_binaryvoxels = mean(nz_nnpx_count_exp);
    currEnergy = sum(energyImg(:));
    totalvariance = sum(variance(:));
    str = sprintf('meannumberofbinaryvoxels = %d \n currEnergy = %f \n totalvariance = %f \n', mean_nn_binaryvoxels, currEnergy, totalvariance)
end
