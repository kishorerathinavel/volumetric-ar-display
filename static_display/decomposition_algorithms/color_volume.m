function [color_volume] = color_volume()
    %% 
    data_folder_path = data_folder_path();
    input_dir = sprintf('%s/RGBD_data', data_folder_path);
    output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);
    %rgbd_names = {'trial_01', 'trial_08'};
    rgbd_names = {'trial_01', 'trial_05'};
    % rgbd_names = {'trial_08'};
    %rgbd_names = {'trial_04'};

    %% Display parameters
    NumofBP=num_binary_planes();

    %% Input RGB, depth map, and depth planes

    RGB_images = zeros(768, 1024, 3, numel(rgbd_names));
    depthmaps = zeros(768, 1024, numel(rgbd_names));
    for iter = 1:numel(rgbd_names)
        filename = sprintf('%s/%s_rgb.png',input_dir, rgbd_names{iter});
        RGBImg=im2double(imread(filename));
        RGB_images(:,:,:,iter) = RGBImg;

        % Description of variables:
        % d - distance to depth plane in meters ordered in sequence of when each depth plane is displayed.
        % d_sort - sorted distanced to depth planes
        % order - index for each entry in d_sort in d
        % un_order - 1:num
        % fov_sort - FoV for each depth plane following same order of d_sort

        filename = sprintf('%s/%s_DepthMap.mat',input_dir, rgbd_names{iter});
        load(filename);
        % figure;
        % imshow(DepthMap);
        depthmaps(:,:,iter) = DepthMap;
    end
    
    filename = sprintf('%s/%s/FocusDepth_%03d.mat', data_folder_path, 'Params', NumofBP);
    load(filename);

    %% Assuming that depth map is linearized
    DepthList=linspace(0,1,NumofBP);
    DepthSeparater=DepthList;

    %% Normalizing and Removing zeros from depth map
    s = size(RGBImg);
    bw_Img_all = zeros(s(1), s(2), s(3), NumofBP);
    color_volume = zeros([size(RGBImg) NumofBP]);
    
    for iter = 1:numel(rgbd_names)
        DepthMap = depthmaps(:,:,iter);
        RGBImg = RGB_images(:,:,:,iter);
        
        DepthMap_norm=depth_map_normalizaion(DepthMap);
        unique_DM_values = unique(sort(reshape(DepthMap_norm, 1, [])));
        indices = find(DepthMap_norm == 1);
        if(iter == 2)
            DepthMap_norm = DepthMap_norm - 0.04;
            DepthMap_norm(DepthMap_norm < 0.0) = 0.0;
            DepthMap_norm(DepthMap_norm > 1.0) = 1.0;
        end
        for iter = 1:numel(indices)
            [r,c] = ind2sub(size(DepthMap), indices(iter));
            RGBImg(r,c,:) = 0;
        end
        DepthMap_norm(DepthMap_norm == 0) = unique_DM_values(1,2);

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
            subvolume = bw_Img_all(:,:,:,subvolume_append).*RGBImg;
            color_volume(:,:,:,subvolume_append) = color_volume(:,:,:,subvolume_append) + subvolume;
        end
    end
    
    % for subvolume_append = 1:NumofBP-1
    %     subvolume = color_volume(:,:,:,subvolume_append);

    %     if(mod(subvolume_append, 1) == 0)
    %         filename = sprintf('%s/target_%03d.png', output_dir, subvolume_append);
    %         custom_imagesc_save(subvolume, filename);
    %     end
    % end
end


