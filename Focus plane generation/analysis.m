clear all;
close all;

%% Setting folder paths
data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/scene_decomposition_output', data_folder_path);
output_dir = sprintf('%s/analysis', data_folder_path);

%% Inputting data

experiment_names = {'ColorDC_edit3', 'adaptive_color_decomposition', ...
                    'heuristic_adaptive_decomposition_0.7', 'heuristic_adaptive_decomposition_1.1'};

exp_binary_images = zeros(768, 1024, 280, numel(experiment_names));
exp_dac_codes = zeros(280, 3, numel(experiment_names));

for iter = 1:numel(experiment_names)
    filename = sprintf('%s/%s/%s_binary_images.mat', input_dir, string(experiment_names(iter)), ...
                       string(experiment_names(iter)));
    load(filename);

    filename = sprintf('%s/%s/%s_dac_codes.mat', input_dir, string(experiment_names(iter)), ...
                       string(experiment_names(iter)));
    load(filename);
    
    exp_binary_images(:,:,:,iter) = binary_images;
    exp_dac_codes(:,:,iter) = dac_codes/256;
end

filename = sprintf('%s/RGBD_data/trial_01_rgb.png',data_folder_path);
RGBImg=im2double(imread(filename));

%% Number of binary voxels used to represent color voxels

% for iter = 1:numel(experiment_names)
%     nnpx_exp_binary_images = exp_binary_images(:,:,:,iter);
%     nnpx_exp_binary_images(nnpx_exp_binary_images > 0) = 1;
%     nnpx_count_exp = sum(nnpx_exp_binary_images, 3);

%     figure; imagesc(nnpx_count_exp);
% end


%% Difference in weighed mean 


depth_planes = 1:280;
depth_planes = reshape(depth_planes, [1,1,280]);
depth_planes_volume = repmat(depth_planes, [768, 1024]);

for iter = 1:numel(experiment_names)
    nnpx_exp_binary_images = exp_binary_images(:,:,:,iter);
    nnpx_exp_binary_images(nnpx_exp_binary_images > 0) = 1;
    nnpx_count_exp = sum(nnpx_exp_binary_images, 3);
    figure; 
    imagesc(nnpx_count_exp);
    title_str = sprintf('%s - # non-zero binary voxels', string(experiment_names(iter)));
    title(title_str, 'Interpreter', 'None');

    dac_codes = exp_dac_codes(:,:,iter);
    binary_images = exp_binary_images(:,:,:,iter);
    
    r_dac_z_column = reshape(dac_codes(:,1), [1,1,280]);
    r_dac_code_volume = repmat(r_dac_z_column, [768, 1024]);
    
    g_dac_z_column = reshape(dac_codes(:,2), [1,1,280]);
    g_dac_code_volume = repmat(g_dac_z_column, [768, 1024]);

    b_dac_z_column = reshape(dac_codes(:,3), [1,1,280]);
    b_dac_code_volume = repmat(b_dac_z_column, [768, 1024]);

    r_perceived_volume = r_dac_code_volume.*binary_images;
    g_perceived_volume = g_dac_code_volume.*binary_images;
    b_perceived_volume = b_dac_code_volume.*binary_images;

    perceived_image = zeros(768, 1024, 3);
    perceived_image(:,:,1) = sum(r_perceived_volume, 3);
    perceived_image(:,:,2) = sum(g_perceived_volume, 3);
    perceived_image(:,:,3) = sum(b_perceived_volume, 3);

    figure; 
    imagesc(RGBImg./max(RGBImg(:)) - perceived_image./max(perceived_image(:))); 
    title_str = sprintf('%s - perceived image difference', string(experiment_names(iter)));
    title(title_str, 'Interpreter', 'None');
    

    r_variance = var(r_perceived_volume.*depth_planes_volume, 0, 3);
    g_variance = var(g_perceived_volume.*depth_planes_volume, 0, 3);
    b_variance = var(b_perceived_volume.*depth_planes_volume, 0, 3);

    w_variance = zeros(768, 1024, 3);
    w_variance(:,:,1) = r_variance;
    w_variance(:,:,2) = g_variance;
    w_variance(:,:,3) = b_variance;

    added_volume = r_perceived_volume + g_perceived_volume + b_perceived_volume;
    variance = var(added_volume, 0, 3);

    
    % figure; imagesc(r_variance - exp2_r_variance);
    % figure; imagesc(g_variance - exp2_g_variance);
    % figure; imagesc(b_variance - exp2_b_variance);
    figure; 
    imagesc(variance); 
    title_str = sprintf('%s - variance', string(experiment_names(iter)));
    title(title_str, 'Interpreter', 'None');
end
