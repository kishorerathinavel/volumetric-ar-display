clear all;
close all;

%% 
data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/RGBD_data', data_folder_path);
output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);


%% Creating a backup of the files that are used to generate each set of results
copyfile adaptive_color_decomposition_all_channels_bk.m adaptive_color_decomposition_images/adaptive_color_decomposition_all_channels_bk.m
copyfile custom_imagesc_save.m adaptive_color_decomposition_images/custom_imagesc_save.m
copyfile DepthMapNormalization.m adaptive_color_decomposition_images/DepthMapNormalization.m
copyfile GenDepthList.m adaptive_color_decomposition_images/GenDepthList.m
copyfile returnNonZeroMeanOfChannels.m adaptive_color_decomposition_images/returnNonZeroMeanOfChannels.m
% copyfile clampLEDValues.m adaptive_color_decomposition_images/clampLEDValues.m
copyfile displayedImage.m adaptive_color_decomposition_images/displayedImage.m

%% Input RGB, depth map, and depth planes

filename = sprintf('%s/trial_00_rgb.png',input_dir);
RGBImg=im2double(imread(filename));

filename = sprintf('%s/%s/FocusDepth.mat',data_folder_path, 'FocusDepth');
load(filename);

% Description of variables:
% d - distance to depth plane in meters ordered in sequence of when each depth plane is displayed.
% d_sort - sorted distanced to depth planes
% order - index for each entry in d_sort in d
% un_order - 1:num
% fov_sort - FoV for each depth plane following same order of d_sort

filename = sprintf('%s/trial_00_DepthMap.mat',input_dir);
load(filename);

%% Display Settings
NumofBP=100;
colorbit=24;

%% What is this?
nonliner=false;
if nonliner
    DepthMap_norm=DepthMapNormalization(DepthMap);
    DepthList=linspace(0,1,NumofBP);
    background=1;
else
    DepthMap_norm=DepthMap;
    DepthList=linspace(d_sort(1),d_sort(end),NumofBP);
    background=max(max(DepthMap));
end

% DepthList=GenDepthList(NumofBP,NumofCP,colorbit);
DepthSeparater=DepthList;
% DepthSeparater=[0,(DepthList(1:end-1)+DepthList(2:end))/2,1];

%% Loop variables

residue_rollover = zeros(size(RGBImg(:,:,:)));  % Document
imcount = 0;
maxLED = 1;
Energy = [];
Energy_all = [];
LED_ALL = [];  % Document
actual_reconstruction = zeros(size(RGBImg));
expected_reconstruction = zeros(size(RGBImg));

%%
for subvolume_iter = 1:NumofBP-1%50 %280-windowLength
    trial = DepthMap_norm;
    trial(trial < DepthSeparater(subvolume_iter)) = 0;
    trial(trial > DepthSeparater(subvolume_iter+1)) = 0;
    trial(trial ==background) = 0;
    
    bw = im2double(im2bw(trial,0));

    subvolume = bw.*RGBImg;
    expected_reconstruction = expected_reconstruction + subvolume;
    % filename = sprintf('adaptive_color_decomposition_images/subvolume_%02d.png', subvolume_iter);
    % custom_imagesc_save(subvolume, filename);
    

    %% Initialization
    
    relaxP=1;

    toOptimize = subvolume;
    toOptimize = toOptimize + relaxP*residue_rollover;  % Document
    gray_toOptimize = mean(toOptimize,3);  % Document
    
    % filename = sprintf('adaptive_color_decomposition_images/toOptimize_%02d.png', subvolume_iter);
    % custom_imagesc_save(toOptimize, filename);

    LEDs = returnNonZeroMeanOfChannels(toOptimize); % Document
    LEDs(isnan(LEDs)) = 0;
    % LEDs = clampLEDValues(LEDs);   % Document
    bin_img=zeros(size(gray_toOptimize));

    delta_bin_img = toOptimize(:,:,1)/LEDs(1) + toOptimize(:,:,2)/LEDs(2) + ...
        toOptimize(:,:,3)/LEDs(3);
    delta_bin_img(isnan(delta_bin_img)) = 0;
    bin_img = bin_img + delta_bin_img;
    bin_img(bin_img < 3.0) = 0.0;
    bin_img(bin_img >= 3.0) = 1.0;
    
    % bin_img = im2double(im2bw(gray_toOptimize, mean(LEDs)));
    % filename = sprintf('adaptive_color_decomposition_images/bin_img_%03d_%02d.png', subvolume_iter, imcount);
    % custom_imagesc_save(bin_img, filename);

    img = displayedImage(LEDs, bin_img);
    % filename = sprintf('adaptive_color_decomposition_images/img_%03d_%02d.png', subvolume_iter, imcount);
    % custom_imagesc_save(img, filename);

    residue = expected_reconstruction - (actual_reconstruction + img);
    % residue = toOptimize - img;
    % filename = sprintf('adaptive_color_decomposition_images/residue_%03d_%02d.png', subvolume_iter, imcount);
    % custom_imagesc_save(residue, filename);
    imcount = imcount + 1;

    currEnergy = residue.*residue;
    currEnergy = sum(currEnergy(:));
    Energy_all = [Energy_all currEnergy];

    %% Optimization
    for iter = 1:5

        % Method 1
        % gray_residue = mean(residue,3);
        % bin_img = bin_img + gray_residue/mean(LEDs);

        % Method 2
        % numerator=LEDs(1)*toOptimize(:,:,1)+LEDs(2)*toOptimize(:,:,2)+LEDs(3)*toOptimize(:,:,3);
        % denominator=sum(LEDs.^2)+ 1e-8;
        % bin_img=numerator/denominator;
       
        % Method 3
        delta_bin_img = residue(:,:,1)/LEDs(1) + residue(:,:,2)/LEDs(2) + ...
            residue(:,:,3)/LEDs(3);
        delta_bin_img(isnan(delta_bin_img)) = 0;
        bin_img = bin_img + delta_bin_img;
        bin_img(bin_img < 3.0) = 0.0;
        bin_img(bin_img >= 3.0) = 1.0;
        
        % filename = sprintf('adaptive_color_decomposition_images/bin_img_%03d_%02d.png', subvolume_iter, imcount);
        % custom_imagesc_save(bin_img, filename);

        img = displayedImage(LEDs, bin_img);
        % filename = sprintf('adaptive_color_decomposition_images/img_%03d_%02d.png', subvolume_iter, imcount);
        % custom_imagesc_save(img, filename);
        
        residue = expected_reconstruction - (actual_reconstruction + img);
        % residue = toOptimize - img;
        % filename = sprintf('adaptive_color_decomposition_images/residue_%03d_%02d.png', subvolume_iter, imcount);
        % custom_imagesc_save(residue, filename);
        currEnergy = residue.*residue;
        currEnergy = sum(currEnergy(:));
        Energy_all = [Energy_all currEnergy];
        imcount = imcount + 1;

        lambda = 1.0;
        denominator = (bin_img.*bin_img + 1e-8);
        
        numerator = (residue(:,:,1).*bin_img);
        %delta = numerator./denominator;
        delta = sum(numerator(:))/sum(denominator(:));
        LEDs(1) = LEDs(1) + lambda*sum(delta(:));
        if(LEDs(1) < 0)
            LEDs(1) = 0;
        end
        
        
        numerator = (residue(:,:,2).*bin_img);
        %delta = numerator./denominator;
        delta = sum(numerator(:))/sum(denominator(:));
        LEDs(2) = LEDs(2) + lambda*sum(delta(:));
        if(LEDs(2) < 0)
            LEDs(2) = 0;
        end
        
        numerator = (residue(:,:,3).*bin_img);
        %delta = numerator./denominator;
        delta = sum(numerator(:))/sum(denominator(:));
        LEDs(3) = LEDs(3) + lambda*sum(delta(:));
        if(LEDs(3) < 0)
            LEDs(3) = 0;
        end
        
        
        %LEDs = returnMeanOfChannels(toOptimize);
        % LEDs = clampLEDValues(LEDs);
        img = displayedImage(LEDs, bin_img);
        % filename = sprintf('adaptive_color_decomposition_images/img_%03d_%02d.png', subvolume_iter, imcount);
        % custom_imagesc_save(img, filename);
        residue = expected_reconstruction - (actual_reconstruction + img);
        % residue = toOptimize - img;
        % filename = sprintf('adaptive_color_decomposition_images/residue_%03d_%02d.png', subvolume_iter, imcount);
        % custom_imagesc_save(residue, filename);
        currEnergy = residue.*residue;
        currEnergy = sum(currEnergy(:));
        Energy_all = [Energy_all currEnergy];
        imcount = imcount + 1;
    end
    
    %bin_img = im2double(im2bw(bin_img,0.5));
    %LEDs = clampLEDValues(LEDs);
    img = displayedImage(LEDs, bin_img);
    residue = expected_reconstruction - (actual_reconstruction + img);
    % residue = toOptimize - img;
    currEnergy = residue.*residue;
    currEnergy = sum(currEnergy(:));
    Energy_all = [Energy_all currEnergy];
    imcount = imcount + 1;
    
    
    Energy = [Energy, currEnergy];
    LED_ALL = [LED_ALL; LEDs];
    
    residue_rollover = residue; % using 1.01*residue has the effect of making LSB more
                                % important. Distorts color
    if(mod(subvolume_iter, 1) == 0||subvolume_iter==279)
        filename = sprintf('adaptive_color_decomposition_images/residue_rollover_%02d.png', subvolume_iter);
        custom_imagesc_save(residue_rollover, filename);
    end

    actual_reconstruction = actual_reconstruction + img;
    if(mod(subvolume_iter, 10) == 0||subvolume_iter==279)
        filename = sprintf('adaptive_color_decomposition_images/reconstructed_%02d.png', subvolume_iter);
        custom_imagesc_save(actual_reconstruction, filename);
    end
    
    if(mod(subvolume_iter, 1) == 0||subvolume_iter==279)
        filename = sprintf('adaptive_color_decomposition_images/displayed_%02d.png', subvolume_iter);
        custom_imagesc_save(imresize(img, 1.0), filename);
    end
    
    if(mod(subvolume_iter, 1) == 0||subvolume_iter==279)
        filename = sprintf('adaptive_color_decomposition_images/binary_%02d.png', subvolume_iter);
        custom_imagesc_save(imresize(bin_img, 1.0), filename);
    end
end
