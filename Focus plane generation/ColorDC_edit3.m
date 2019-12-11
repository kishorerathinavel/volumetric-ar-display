clear all;
close all;
warning off;

%% Setting folder paths
data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/RGBD_data', data_folder_path);
output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);

%% Inputting data
filename = sprintf('%s/trial_01_rgb.png',input_dir);
RGBImg=imread(filename);

filename = sprintf('%s/%s/FocusDepth.mat',data_folder_path, 'FocusDepth');
load(filename);
% Description of variables:
% d - distance to depth plane in meters ordered in sequence of when each depth plane is
%     displayed (temporally)
% d_sort - sorted distance to depth planes
% order - index for each entry of d_sort in d
% un_order - index for each entry of d in d_sort
% fov_sort - FoV for each depth plane following same order of d_sort

filename = sprintf('%s/trial_01_DepthMap.mat',input_dir);
load(filename);
% Inputs the depth map of the scene. We avoid inputing a png image as the depth map
% because we want a single channel image with distance in meters instead of a 4-channel
% image with pixel values whose correspondence to actual distances is not clear. Where
% is this mat file created?

% figure;
% imshow(RGBImg,[]);

% figure;
% imshow(DepthMap,[]);

%% Display parameters
NumofBP=size(d,2);
colorbit=24;


%%

[Image_sequence,Image_CutVol]=GenerateImgSeq2(RGBImg,DepthMap,'NumofBP',NumofBP, ...
                                              'colorbit',colorbit);
% Kishore: What is Image_CutVol?

Image_CutVol=uint8(Image_CutVol);

%% test results

show_test_results = false;
if(show_test_results == true)
    [RGBImg_bit,RGBImg_re]=RGBbitExtract(RGBImg,'colorbit',colorbit);

    subplot(3,1,1);
    imshow(RGBImg_bit,[]);
    title(['First ',num2str(colorbit/3),' bit RGB Img']);

    subplot(3,1,2);
    imshow(RGBImg_re,[]);
    title(['Original RGB Img']);

    subplot(3,1,3);
    imshow(RGBImg_re-RGBImg_bit,[]);
    title(['Difference']);
end



%% Kishore: What does this section do? It makes no difference if this section is there
%% or not
lookuptable=round(2.^(7:-1:0)/128*(255-32)+32); % Kishore: What is this?
lookuptable=255:-32:30; % Kishore: Where does -32 come from?
ImageSeq_con=zeros([768 1024 3]); % Kishore: What is this?
ImageSeq_Binary=zeros([768 1024 3 280]); % Kishore: What is this? Why does something
                                         % called 'binary' have three color channels?
ImageSeq_Perceived=zeros([768 1024 3 280]); % Kishore: What is this?

for i=1:280
    
    ImageSeq_con=zeros([768 1024 3]);
    s=mod(i,colorbit);
    if s==0
        s=colorbit;
    end
    
    switch s
      case num2cell(1:colorbit/3)
        c=1;
      case num2cell(colorbit/3+1:colorbit/3*2)
        c=2;
      case num2cell(colorbit/3*2+1:colorbit)
        c=3;
    end
    
    s=mod(i,colorbit/3);    
    if s==0
        s=colorbit/3;
    end
    
    ImageSeq_con(:,:,c)=Image_sequence(:,:,i)*lookuptable(s);
    ImageSeq_Binary(:,:,:,i)=ImageSeq_con;
    
    if i==1
        ImageSeq_Perceived(:,:,:,i)=ImageSeq_con;
    else
        ImageSeq_Perceived(:,:,:,i)=ImageSeq_Perceived(:,:,:,i-1)+ImageSeq_con;
    end
end

ImageSeq_con=uint8(ImageSeq_con);

% figure;
% imshow(ImageSeq_con,[]);

%% 
ImageSeq_order=flipud(Image_sequence(:,:,un_order));

%% Saves binary images

% Kishore: Why are we not saving the LED values also here? Where are we saving the LED values?

use_temporal_order = false;
if(use_temporal_order == true)
    for i=1:NumofBP
        filename = sprintf('%s/Scene_%03d.png', output_dir, i);
        imwrite(ImageSeq_order(:,:,i),filename);  
    end
else
    for i=1:NumofBP
        filename = sprintf('%s/binary_%03d.png', output_dir, i);
        imwrite(Image_sequence(:,:,i),filename);  
    end

    binary_images = Image_sequence;
    filename = sprintf('%s/ColorDC_edit3_binary_images.mat', output_dir);
    save(filename, 'binary_images', '-v7.3');
    
    DDS_values = [128, 64, 32, 16, 8, 4, 2, 1];
    LEDs_24_planes = zeros(24, 3);
    LEDs_24_planes(1:8, 1) = DDS_values';
    LEDs_24_planes(9:9+7, 2) = DDS_values';
    LEDs_24_planes(9+7+1:9+7+1+7, 3) = DDS_values';
    LEDs_ALL = repmat(LEDs_24_planes, [ceil(280/24), 1]);
    LEDs_ALL(281:end, :) = [];
    
    dac_codes = LEDs_ALL/256;
    
    filename = sprintf('%s/ColorDC_edit3_dac_codes.mat', output_dir);
    save(filename, 'dac_codes', '-v7.3');
end

%%
ImageSeq_Binary=uint8(ImageSeq_Binary);

filename = sprintf('%s/ImageSeq_Binary.mat', output_dir);
save(filename, 'ImageSeq_Binary');


