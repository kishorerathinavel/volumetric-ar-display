clear all;
close all;

%% Execution parameters
print_images = true;
show_images = false;

%% Setting folder paths
data_folder_path = data_folder_path();
decomposition_output_dir = sprintf('%s/scene_decomposition_output/analysis_input', data_folder_path);
output_dir = sprintf('%s/scene_decomposition_output/analysis_output', data_folder_path);

%% Display Settings
NumofBP = num_binary_planes();
focal_plane_depth_all = [round(1:NumofBP/4:NumofBP) NumofBP];

%% Get color volume
color_volume = color_volume();
size_color_volume = size(color_volume);

filename = sprintf('%s/%s/FocusDepth_%03d.mat', data_folder_path, 'Params', NumofBP);
load(filename);

%% Experiment details
experiment_names = {'fixed_pipeline', 'combinatorial', 'highest_energy_channel', 'projected_gradients', 'heuristic'};
%experiment_names = {'fixed_pipeline', 'heuristic'};
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

%% Generating focal stack for color volume
RGBImg = squeeze(sum(color_volume,4));
filename = sprintf('%s/PI_CV.png', output_dir);
custom_imagesc_save(RGBImg, filename);


%% Difference in weighed mean 

depth_planes = 1:NumofBP;
depth_planes = reshape(depth_planes, [1,1,NumofBP]);
depth_planes_volume = repmat(depth_planes, [768, 1024]);

PSNR_all = [];
SSIM_all = [];

for iter = 1:numel(experiment_names)
    % string(experiment_names(iter))

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
    nnpx_exp_binary_images(nnpx_exp_binary_images > 2*0.0039) = 1;
    nnpx_count_exp = squeeze(sum(sum(nnpx_exp_binary_images,4),3));
    
    if(print_images)
        figure('visible', 'off'); 
        clims = [0 15];
        imagesc(nnpx_count_exp, clims);
        axis off;

        ax = gca;
        outerpos = ax.OuterPosition;
        left = 0;
        bottom = 0;
        ax_width = outerpos(3) - outerpos(1);
        ax_height = outerpos(4) - outerpos(2);
        ax.Position = [left bottom ax_width ax_height];

        filename = sprintf('%s/NZ_BV_%02d.png', output_dir, iter);
        set(gcf, 'PaperPositionMode', 'auto');
        saveas(gcf, filename, 'png');
    end

    if(show_images)
        figure; 
        clims = [0 15];
        imagesc(nnpx_count_exp, clims);
    end

    perceived_image = zeros(768, 1024, 3);
    perceived_image(:,:,1) = sum(r_perceived_volume, 3);
    perceived_image(:,:,2) = sum(g_perceived_volume, 3);
    perceived_image(:,:,3) = sum(b_perceived_volume, 3);
    
    peaksnr = psnr(perceived_image, RGBImg);
    ssimval = ssim(perceived_image, RGBImg);
    PSNR_all = [PSNR_all; peaksnr];
    SSIM_all = [SSIM_all; ssimval];

    diffImg = RGBImg - perceived_image;
    energyImg = diffImg.*diffImg;
    if(print_images)
        filename = sprintf('%s/PI_BV_%02d.png', output_dir, iter);
        imwrite(perceived_image, filename);
        
        filename = sprintf('%s/DI_BV_%02d.png', output_dir, iter);
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
    % str = sprintf('meannumberofbinaryvoxels = %d \n currEnergy = %f \n totalvariance = %f \n', mean_nn_binaryvoxels, currEnergy, totalvariance)
end

pinhole_PSNR = PSNR_all;
filename = sprintf('%s/pinhole_PSNR.mat', output_dir);
save(filename, 'pinhole_PSNR', '-v7.3');

pinhole_SSIM = SSIM_all;
filename = sprintf('%s/pinhole_SSIM.mat', output_dir);
save(filename, 'pinhole_SSIM', '-v7.3');




