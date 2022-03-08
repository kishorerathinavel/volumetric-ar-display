clear all;
close all;

%% Execution parameters
debug = false;
calc_CV_FS = true;
calc_psnr_ssim = true;
[descending, rgb] = fixed_pipeline_settings();

%% Setting folder paths
data_folder_path = data_folder_path();
decomposition_output_dir = sprintf('%s/scene_decomposition_output/analysis_input', data_folder_path);
output_dir = sprintf('%s/scene_decomposition_output/analysis_output', data_folder_path);

%% Display Settings
NumofBP = num_binary_planes();
pupil_radius = 2;

%% Get color volume
color_volume = color_volume();
size_color_volume = size(color_volume);

filename = sprintf('%s/%s/FocusDepth_%03d.mat', data_folder_path, 'Params', NumofBP);
load(filename);

%% Display Settings
min_diopter = 1/d_sort(end);
max_diopter = 1/d_sort(1);
focal_plane_diopters = [min_diopter:(max_diopter - min_diopter)/3:max_diopter];
focal_plane_depth_all = 1./focal_plane_diopters;
focal_plane_depth_all = fliplr(focal_plane_depth_all);

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

%% Calculating convolution kernel size

conv_kernel_img_all = cell(numel(focal_plane_depth_all), numel(1:NumofBP));
conv_kernel_all = [];
defocus_plane_depth_all = [];

for focal_plane_iter = 1:size(focal_plane_depth_all,2)
    conv_kernel_row = [];
    defocus_plane_depth_row = [];
    for defocus_plane_number = 1:NumofBP
        focal_plane_depth = focal_plane_depth_all(1,focal_plane_iter);
        defocus_plane_depth = d_sort(defocus_plane_number);
        
        conv_kernel_px_radius = defocus_kernel_size(pupil_radius/1000, 40, defocus_plane_depth, focal_plane_depth);
        defocus_plane_depth_row = [defocus_plane_depth_row defocus_plane_depth];
        conv_kernel_row = [conv_kernel_row conv_kernel_px_radius];
        conv_kernel_px_radius = round(conv_kernel_px_radius);

        if(conv_kernel_px_radius ~= 0)
            conv_kernel = fspecial('disk', conv_kernel_px_radius);
            conv_kernel_img_all{focal_plane_iter, defocus_plane_number} = conv_kernel;
        end
    end
    conv_kernel_all = [conv_kernel_all; conv_kernel_row];
    defocus_plane_depth_all = [defocus_plane_depth_all; defocus_plane_depth_row];
end


%% Generating focal stack for color volume
if(calc_CV_FS)
    CV_FS = zeros([size_color_volume(1:3) numel(focal_plane_depth_all)]);

    for focal_plane_iter = 1:size(focal_plane_depth_all,2)
        reconstructed_focal_image = zeros(size_color_volume(1:3));
        for defocus_plane_number = 1:NumofBP
            subvolume = color_volume(:,:,:,defocus_plane_number);
            conv_kernel_px_radius = round(conv_kernel_all(focal_plane_iter, defocus_plane_number));
            
            perceived_image = zeros(size_color_volume(1:3));
            if(conv_kernel_px_radius == 0)
                perceived_image = subvolume;
            else
                conv_kernel = conv_kernel_img_all{focal_plane_iter, defocus_plane_number};
                perceived_image(:,:,1) = conv2(subvolume(:,:,1), conv_kernel,'same');
                perceived_image(:,:,2) = conv2(subvolume(:,:,2), conv_kernel,'same');
                perceived_image(:,:,3) = conv2(subvolume(:,:,3), conv_kernel,'same');
            end
            reconstructed_focal_image = reconstructed_focal_image + perceived_image;
        end
        CV_FS(:,:,:,focal_plane_iter) = reconstructed_focal_image;

        filename = sprintf('%s/CV_FS_%03d.png', output_dir, focal_plane_iter);
        custom_imagesc_save(reconstructed_focal_image, filename);
    end

end

%% Generating focal stack for binary volume

BV_FS = zeros([size_color_volume(1:3) numel(focal_plane_depth_all) numel(experiment_names)]);
for exp_iter = 1:numel(experiment_names)
    for focal_plane_iter = 1:size(focal_plane_depth_all,2)
        reconstructed_focal_image = zeros(size_color_volume(1:3));
        for defocus_plane_number = 1:NumofBP
            conv_kernel_px_radius = round(conv_kernel_all(focal_plane_iter, defocus_plane_number));
            
            defocus_binary_slice = exp_binary_images(:,:,defocus_plane_number,exp_iter);
            color_image = zeros(size_color_volume(1:3));
            color_image(:,:,1) = defocus_binary_slice*exp_dac_codes(defocus_plane_number,1,exp_iter);
            color_image(:,:,2) = defocus_binary_slice*exp_dac_codes(defocus_plane_number,2,exp_iter);
            color_image(:,:,3) = defocus_binary_slice*exp_dac_codes(defocus_plane_number,3,exp_iter);
            
            perceived_image = zeros(size_color_volume(1:3));
            if(conv_kernel_px_radius == 0)
                perceived_image = color_image;
            else
                conv_kernel = conv_kernel_img_all{focal_plane_iter, defocus_plane_number};
                perceived_image(:,:,1) = conv2(color_image(:,:,1), conv_kernel,'same');
                perceived_image(:,:,2) = conv2(color_image(:,:,2), conv_kernel,'same');
                perceived_image(:,:,3) = conv2(color_image(:,:,3), conv_kernel,'same');
            end
            reconstructed_focal_image = reconstructed_focal_image + perceived_image;

            if(debug == true)
                filename = sprintf('%s/details/binary_image_%02d_%03d_%03d.png', output_dir, exp_iter, focal_plane_iter, defocus_plane_number);
                custom_imagesc_save(defocus_binary_slice, filename);
                
                filename = sprintf('%s/details/color_image_%02d_%03d_%03d.png', output_dir, exp_iter, focal_plane_iter, defocus_plane_number);
                custom_imagesc_save(color_image, filename);
                
                filename = sprintf('%s/details/perceived_image_%02d_%03d_%03d.png', output_dir, exp_iter, focal_plane_iter, defocus_plane_number);
                custom_imagesc_save(perceived_image, filename);

                filename = sprintf('%s/details/reconstructed_%02d_%03d_%03d.png', output_dir, exp_iter, focal_plane_iter, defocus_plane_number);
                custom_imagesc_save(reconstructed_focal_image, filename);
            end
        end
        if(debug)
            waitforbuttonpress
        end
        
        BV_FS(:,:,:,focal_plane_iter,exp_iter) = reconstructed_focal_image;

        filename = sprintf('%s/BV_FS_%02d_%03d.png', output_dir, exp_iter, focal_plane_iter);
        custom_imagesc_save(reconstructed_focal_image, filename);
        
        if(strcmp(experiment_names{exp_iter}, 'fixed_pipeline'))
            filename = sprintf('%s/BV_FS_%02d_%03d_%1d_%1d.png', output_dir, exp_iter, focal_plane_iter, 2-descending, 2-rgb);
            custom_imagesc_save(reconstructed_focal_image, filename);
        end
    end
end

%% Calculating PSNR and SSIM images

if(calc_psnr_ssim)
    PSNR_all = [];
    SSIM_all = [];
    for exp_iter = 1:numel(experiment_names)
        PSNR_row = [];
        SSIM_row = [];
        for iter = 1:size(focal_plane_depth_all,2)
            ssimval = ssim(BV_FS(:,:,:,iter,exp_iter), CV_FS(:,:,:,iter));
            peaksnr = psnr(BV_FS(:,:,:,iter,exp_iter), CV_FS(:,:,:,iter));
            PSNR_row = [PSNR_row peaksnr];
            SSIM_row = [SSIM_row ssimval];
        end
        PSNR_all = [PSNR_all; PSNR_row];
        SSIM_all = [SSIM_all; SSIM_row];
    end
    
    FS_PSNR = PSNR_all;
    filename = sprintf('%s/FS_PSNR.mat', output_dir);
    save(filename, 'FS_PSNR', '-v7.3');

    FS_SSIM = SSIM_all;
    filename = sprintf('%s/FS_SSIM.mat', output_dir);
    save(filename, 'FS_SSIM', '-v7.3');
end


