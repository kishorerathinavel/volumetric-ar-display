clear all;
close all;

copyfile adaptive_color_decomposition.m adaptive_color_decomposition_images/adaptive_color_decomposition.m
copyfile custom_imagesc_save.m adaptive_color_decomposition_images/custom_imagesc_save.m
RGBImg=im2double(imread('trial_01_rgb.png'));

load('trial_01_DepthMap.mat');

NumofBP=280;
colorbit=24;

max_D=max(max(DepthMap));

DepthMap_norm=DepthMapNormalization(DepthMap);
NumofCP=NumofBP-colorbit+1;
% DepthList=GenDepthList(NumofBP,NumofCP,colorbit);
DepthList=linspace(0,1,NumofBP);

% DepthSeparater=[0,(DepthList(1:end-1)+DepthList(2:end))/2,1];
DepthSeparater=DepthList;

windowLength = 4;
residue_rollover = zeros(size(RGBImg));
imcount = 0;

maxLED = 1;
Energy = [];
Energy_all = [];
LED_ALL = [];
IMG = zeros(size(RGBImg));
ORIG_IMG = zeros(size(RGBImg));
channel = 1;

penalties = [1,1,1];
penalties_all = [];
channel_energies_all = [];

s = size(RGBImg);
residual_history = zeros(s(1), s(2), s(3), 280);

%% save or load bw_Img_all
savedata = false;
if(savedata)
    s = size(RGBImg);
    bw_Img_all = zeros(s(1), s(2), s(3), 280);

    parfor subvolume_append = 1:280-1 %280-windowLength
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

    save bw_Img_all.mat bw_Img_all -v7.3
else 
    load('bw_Img_all.mat');
end

%%

weights_img_all = zeros(size(bw_Img_all));
repmat_overall_residue = zeros(size(bw_Img_all));
 
Energy = zeros(280,1);
LED_ALL = zeros(280,3);

for subvolume_append = 1:280-1 %280-windowLength
    subvolume = bw_Img_all(:,:,:,subvolume_append).*RGBImg;
    
    ORIG_IMG = ORIG_IMG + subvolume;
    % filename = sprintf('adaptive_color_decomposition_images/subvolume_%02d.png', subvolume_append);
    % custom_imagesc_save(subvolume, filename);
    

    %% Initialization

    toOptimize = subvolume;
    toOptimize = toOptimize + residue_rollover;
    channel_toOptimize = toOptimize(:,:,channel);
    
    % filename = sprintf('adaptive_color_decomposition_images/toOptimize_%02d.png', subvolume_append);
    % custom_imagesc_save(toOptimize, filename);

    LEDs = [0,0,0];
    LEDs(channel) = mean(channel_toOptimize(:));
    LEDs = clampLEDValues(LEDs);
   
    bin_img = im2double(im2bw(channel_toOptimize, LEDs(channel)));
    % filename = sprintf('adaptive_color_decomposition_images/bin_img_%03d_%02d.png', subvolume_append, imcount);
    % custom_imagesc_save(bin_img, filename);

    img = displayedImage(LEDs, bin_img);
    % filename = sprintf('adaptive_color_decomposition_images/img_%03d_%02d.png', subvolume_append, imcount);
    % custom_imagesc_save(img, filename);

    residue = toOptimize - img;
    % filename = sprintf('adaptive_color_decomposition_images/residue_%03d_%02d.png', subvolume_append, imcount);
    % custom_imagesc_save(residue, filename);
    imcount = imcount + 1;

    currEnergy = residue.*residue;
    currEnergy = sum(currEnergy(:));
    Energy_all = [Energy_all currEnergy];

    for iter = 1:2
        bin_img = bin_img + residue(:,:,channel)/LEDs(channel);
        % bin_img = bin_img + residue(:,:,1)/LEDs(1);
        bin_img = im2double(im2bw(bin_img,0));
        % filename = sprintf('adaptive_color_decomposition_images/bin_img_%03d_%02d.png', subvolume_append, imcount);
        % custom_imagesc_save(bin_img, filename);

        
        img = displayedImage(LEDs, bin_img);
        % filename = sprintf('adaptive_color_decomposition_images/img_%03d_%02d.png', subvolume_append, imcount);
        % custom_imagesc_save(img, filename);
        
        residue = toOptimize - img;
        % filename = sprintf('adaptive_color_decomposition_images/residue_%03d_%02d.png', subvolume_append, imcount);
        % custom_imagesc_save(residue, filename);
        currEnergy = residue.*residue;
        currEnergy = sum(currEnergy(:));
        Energy_all = [Energy_all currEnergy];
        imcount = imcount + 1;

        lambda = 0.01;
        denominator = (bin_img.*bin_img + 1e-8);
        numerator = (residue(:,:,channel).*bin_img);
        delta = sum(numerator(:))./sum(denominator(:));
        
        LEDs(channel) = LEDs(channel) + lambda*delta;
        LEDs = clampLEDValues(LEDs);
        
        img = displayedImage(LEDs, bin_img);
        % filename = sprintf('adaptive_color_decomposition_images/img_%03d_%02d.png', subvolume_append, imcount);
        % custom_imagesc_save(img, filename);
        residue = toOptimize - img;
        % filename = sprintf('adaptive_color_decomposition_images/residue_%03d_%02d.png', subvolume_append, imcount);
        % custom_imagesc_save(residue, filename);
        currEnergy = residue.*residue;
        currEnergy = sum(currEnergy(:));
        Energy_all = [Energy_all currEnergy];
        imcount = imcount + 1;
    end
    
    filename = sprintf('adaptive_color_decomposition_images/bin_img_%02d.png', subvolume_append);
    custom_imagesc_save(bin_img, filename);
    
    bin_colorized = zeros(size(RGBImg));
    bin_colorized(:,:,channel) = bin_img;
    if(mod(subvolume_append, 10) == 0)
        filename = sprintf('adaptive_color_decomposition_images/bin_colorized_%02d.png', subvolume_append);
        custom_imagesc_save(bin_colorized, filename);
    end
    
    Energy(subvolume_append) = currEnergy;
    LED_ALL(subvolume_append,:) = LEDs;
    
    IMG = IMG + img;
    if(mod(subvolume_append, 10) == 0)
        filename = sprintf('adaptive_color_decomposition_images/IMG_%02d.png', subvolume_append);
        custom_imagesc_save(IMG, filename);
    end
    

   
    
    % residual_history(:,:,:,subvolume_append) = residue;
    residual_factor = 2;
    residue_rollover = zeros(size(RGBImg));
    overall_residue = ORIG_IMG - IMG;
    if(mod(subvolume_append, 10) == 0)
        filename = sprintf('adaptive_color_decomposition_images/overall_residue_%02d.png', subvolume_append);
        custom_imagesc_save(abs(overall_residue), filename);
    end
    
    % repmat_overall_residue = repmat(overall_residue, [1 1 1 280]);
    for iter =1:280
        repmat_overall_residue(:,:,:,iter) = overall_residue;
    end
    
    residual_history = bw_Img_all.*repmat_overall_residue;
    % weights = 280:1:1;
    % weights = weights - subvolume_append*ones(size(weights));
    % weights(weights < 0) = 0;
    % weights = weights*residual_factor;
    % residue_rollover = 
    
    for iter = 1:subvolume_append
        % trial = DepthMap_norm;
        % trial(trial < DepthSeparater(iter)) = 0;
        % trial(trial > DepthSeparater(iter+1)) = 0;
        % bw = im2double(im2bw(trial,0));
        
        % bw_Img = zeros(size(RGBImg));
        % bw_Img(:,:,1) = bw;
        % bw_Img(:,:,2) = bw;
        % bw_Img(:,:,3) = bw;

        % residual_history(:,:,:,iter) = bw_Img.*(overall_residue);
        residue_rollover = residue_rollover + residual_factor*(subvolume_append - iter + 1)*residual_history(:,:,:,iter);
    end
    if(mod(subvolume_append, 10) == 0)
        filename = sprintf('adaptive_color_decomposition_images/residue_rollover_%02d.png', subvolume_append);
        custom_imagesc_save(residue_rollover, filename);
    end

    
    channel = channel + 1;
    if(channel > 3)
        channel = 1;
    end

    % % penalties(channel) = penalties(channel)/2;
    % r_residue = residue(:,:,1);
    % r_energy = r_residue.*r_residue;
    % r_energy = sum(r_energy(:));
    
    % g_residue = residue(:,:,2);
    % g_energy = g_residue.*g_residue;
    % g_energy = sum(g_energy(:));
    
    % b_residue = residue(:,:,3);
    % b_energy = b_residue.*b_residue;
    % b_energy = sum(b_energy(:));
  
    % pentalFactor = 1;
    % channel_energies = [r_energy, g_energy, b_energy];
    % % channel_energies = channel_energies.*penalties;
    % channel_energies_all = [channel_energies_all; channel_energies];
    
    % % old_channel = channel;
    % [vals, idx] = sort(channel_energies, 'descend');
    % channel = idx(1);
    % % penalties(idx(1)) = penalties(idx(1))/2;
    % % penalties(idx(2)) = min(penalties(idx(2))*2,4);
    % % penalties(idx(3)) = min(penalties(idx(3))*2,4);
    
    % % penalties_all = [penalties_all; penalties];
    % % if(channel == old_channel)
    % %     channel = idx(2);
    % % end
    
end

save 'adaptive_color_decomposition_images/dac_codes.mat' LED_ALL -v7.3
