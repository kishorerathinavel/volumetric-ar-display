clear all;
close all;

%% Setting folder paths
data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/scene_decomposition_output', data_folder_path);
output_dir = sprintf('%s/analysis', data_folder_path);

%% Inputting data

experiment_names = {'ColorDC_edit3', 'heuristic_adaptive_decomposition'};


filename = sprintf('%s/%s/%s_binary_images.mat', input_dir, string(experiment_names(1)), ...
                   string(experiment_names(1)));
load(filename);

filename = sprintf('%s/%s/%s_dac_codes.mat', input_dir, string(experiment_names(1)), ...
                   string(experiment_names(1)));
load(filename);

exp1_binary_images = binary_images;
exp1_dac_codes = dac_codes/256;

filename = sprintf('%s/%s/%s_binary_images.mat', input_dir, string(experiment_names(2)), ...
                   string(experiment_names(2)));
load(filename);

filename = sprintf('%s/%s/%s_dac_codes.mat', input_dir, string(experiment_names(2)), ...
                   string(experiment_names(2)));
load(filename);

exp2_binary_images = binary_images;
exp2_dac_codes = dac_codes;

%% Difference in the number of binary voxels used to represent color voxels

nnpx_exp1_binary_images = exp1_binary_images;
nnpx_exp1_binary_images(nnpx_exp1_binary_images > 0) = 1;
nnpx_count_exp1 = sum(nnpx_exp1_binary_images, 3);
% min(nnpx_count_exp1(:))
% max(nnpx_count_exp1(:))
% mean(nnpx_count_exp1(:))

nnpx_exp2_binary_images = exp2_binary_images;
nnpx_exp2_binary_images(nnpx_exp2_binary_images > 0) = 1;
nnpx_count_exp2 = sum(nnpx_exp2_binary_images, 3);
% min(nnpx_count_exp2(:))
% max(nnpx_count_exp2(:))
% mean(nnpx_count_exp2(:))

nnpx_diff = nnpx_count_exp1 - nnpx_count_exp2;
figure; imagesc(nnpx_diff);

%% Difference in weighed mean 
exp1_r_dac_z_column = reshape(exp1_dac_codes(:,1), [1,1,280]);
exp1_r_dac_code_volume = repmat(exp1_r_dac_z_column, [768, 1024]);

exp1_g_dac_z_column = reshape(exp1_dac_codes(:,2), [1,1,280]);
exp1_g_dac_code_volume = repmat(exp1_g_dac_z_column, [768, 1024]);

exp1_b_dac_z_column = reshape(exp1_dac_codes(:,3), [1,1,280]);
exp1_b_dac_code_volume = repmat(exp1_b_dac_z_column, [768, 1024]);

exp1_r_perceived_volume = exp1_r_dac_code_volume.*exp1_binary_images;
exp1_g_perceived_volume = exp1_g_dac_code_volume.*exp1_binary_images;
exp1_b_perceived_volume = exp1_b_dac_code_volume.*exp1_binary_images;

exp1_perceived_image = zeros(768, 1024, 3);
exp1_perceived_image(:,:,1) = sum(exp1_r_perceived_volume, 3);
exp1_perceived_image(:,:,2) = sum(exp1_g_perceived_volume, 3);
exp1_perceived_image(:,:,3) = sum(exp1_b_perceived_volume, 3);

% figure;
% imshow(exp1_perceived_image, []);

exp1_r_variance = var(exp1_r_perceived_volume, 0, 3);
exp1_g_variance = var(exp1_g_perceived_volume, 0, 3);
exp1_b_variance = var(exp1_b_perceived_volume, 0, 3);

exp1_w_variance = zeros(768, 1024, 3);
exp1_w_variance(:,:,1) = exp1_r_variance;
exp1_w_variance(:,:,2) = exp1_g_variance;
exp1_w_variance(:,:,3) = exp1_b_variance;

exp1_added_volume = exp1_r_perceived_volume + exp1_g_perceived_volume + exp1_b_perceived_volume;
exp1_variance = var(exp1_added_volume, 0, 3);


exp2_r_dac_z_column = reshape(exp2_dac_codes(:,1), [1,1,280]);
exp2_r_dac_code_volume = repmat(exp2_r_dac_z_column, [768, 1024]);

exp2_g_dac_z_column = reshape(exp2_dac_codes(:,2), [1,1,280]);
exp2_g_dac_code_volume = repmat(exp2_g_dac_z_column, [768, 1024]);

exp2_b_dac_z_column = reshape(exp2_dac_codes(:,3), [1,1,280]);
exp2_b_dac_code_volume = repmat(exp2_b_dac_z_column, [768, 1024]);

exp2_r_perceived_volume = exp2_r_dac_code_volume.*exp2_binary_images;
exp2_g_perceived_volume = exp2_g_dac_code_volume.*exp2_binary_images;
exp2_b_perceived_volume = exp2_b_dac_code_volume.*exp2_binary_images;

exp2_perceived_image = zeros(768, 1024, 3);
exp2_perceived_image(:,:,1) = sum(exp2_r_perceived_volume, 3);
exp2_perceived_image(:,:,2) = sum(exp2_g_perceived_volume, 3);
exp2_perceived_image(:,:,3) = sum(exp2_b_perceived_volume, 3);

% figure;
% imshow(exp2_perceived_image, []);

exp2_r_variance = var(exp2_r_perceived_volume, 0, 3);
exp2_g_variance = var(exp2_g_perceived_volume, 0, 3);
exp2_b_variance = var(exp2_b_perceived_volume, 0, 3);

exp2_w_variance = zeros(768, 1024, 3);
exp2_w_variance(:,:,1) = exp2_r_variance;
exp2_w_variance(:,:,2) = exp2_g_variance;
exp2_w_variance(:,:,3) = exp2_b_variance;

exp2_added_volume = exp2_r_perceived_volume + exp2_g_perceived_volume + exp2_b_perceived_volume;
exp2_variance = var(exp2_added_volume, 0, 3);

figure; imagesc(exp1_r_variance - exp2_r_variance);
figure; imagesc(exp1_g_variance - exp2_g_variance);
figure; imagesc(exp1_b_variance - exp2_b_variance);
figure; imagesc(exp1_variance - exp2_variance);