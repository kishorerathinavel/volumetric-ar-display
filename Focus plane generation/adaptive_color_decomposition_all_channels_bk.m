clear all;
close all;

RGBImg=im2double(imread('trial_00_rgb.png'));

load('FocusDepth.mat');
load('trial_00_DepthMap.mat');

NumofBP=280;
colorbit=24;

max_D=max(max(DepthMap));

DepthMap_norm=DepthMapNormlization(DepthMap);
NumofCP=NumofBP-colorbit+1;
DepthList=GenDepthList(NumofBP,NumofCP,colorbit);

DepthSeparater=[0,(DepthList(1:end-1)+DepthList(2:end))/2,1];

windowLength = 4;
residue_rollover = zeros(size(RGBImg(:,:,1)));
imcount = 0;

maxLED = 1;
Energy = [];
Energy_all = [];
LED_ALL = [];
IMG = zeros(size(RGBImg));

for subvolume_append = 1:50 %280-windowLength
    trial = DepthMap_norm;
    trial(trial < DepthSeparater(subvolume_append)) = 0;
    trial(trial > DepthSeparater(subvolume_append+1)) = 0;
    bw = im2double(im2bw(trial,0));

    subvolume = bw.*RGBImg;
    filename = sprintf('adaptive_color_decomposition_images/subvolume_%02d.png', subvolume_append);
    custom_imagesc_save(subvolume, filename);
    

    %% Initialization

    toOptimize = subvolume;
    toOptimize = toOptimize + residue_rollover;
    gray_toOptimize = mean(toOptimize,3);
    
    filename = sprintf('adaptive_color_decomposition_images/toOptimize_%02d.png', subvolume_append);
    custom_imagesc_save(toOptimize, filename);

    LEDs = returnMeanOfChannels(toOptimize);
    LEDs = clampLEDValues(LEDs);
   
    bin_img = im2double(im2bw(gray_toOptimize, mean(LEDs)));
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
        gray_residue = mean(residue,3);
        bin_img = bin_img + gray_residue/mean(LEDs);
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

        lambda = 0.0001;
        denominator = (bin_img.*bin_img + 1e-8);
        
        numerator = (residue(:,:,1).*bin_img);
        delta = numerator./denominator;
        LEDs(1) = LEDs(1) + lambda*sum(delta(:));
        
        numerator = (residue(:,:,2).*bin_img);
        delta = numerator./denominator;
        LEDs(2) = LEDs(2) + lambda*sum(delta(:));
        
        numerator = (residue(:,:,3).*bin_img);
        delta = numerator./denominator;
        LEDs(3) = LEDs(3) + lambda*sum(delta(:));
        
        
        LEDs = returnMeanOfChannels(toOptimize);
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
    Energy = [Energy, currEnergy];
    LED_ALL = [LED_ALL; LEDs];
    
    residue_rollover = residue;
    filename = sprintf('adaptive_color_decomposition_images/residue_rollover_%02d.png', subvolume_append);
    custom_imagesc_save(residue_rollover, filename);

    IMG = IMG + img;
    filename = sprintf('adaptive_color_decomposition_images/IMG_%02d.png', subvolume_append);
    custom_imagesc_save(IMG, filename);
end
