clear all;
warning off;

%%
data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/RGBD_data', data_folder_path);
output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);

%%

filename = sprintf('%s/trial_01_rgb.png',input_dir);
RGBImg=imread(filename);
filename = sprintf('%s/%s/FocusDepth.mat',data_folder_path, 'FocusDepth');
load(filename);
filename = sprintf('%s/trial_01_DepthMap.mat',input_dir);
load(filename);

figure;
imshow(RGBImg,[]);

figure;
imshow(DepthMap,[]);
%%
NumofBP=280;
colorbit=24;


%%

[Image_sequence,Image_CutVol]=GenerateImgSeq3(RGBImg,DepthMap,d_sort,'NumofBP',NumofBP,'colorbit',colorbit);

figure;
imshow(mean(Image_sequence,3),[]);

Image_CutVol=uint8(Image_CutVol);
%% test results


[RGBImg_bit,RGBImg_re]=RGBbitExtract(RGBImg,'colorbit',colorbit);

subplot(3,1,1);
imshow(RGBImg_bit,[]);
title(['First ',num2str(colorbit/3),' bit RGB Img']);

subplot(3,1,2);
imshow(RGBImg_re,[]);
title('Original RGB Img');

subplot(3,1,3);
imshow(RGBImg_re-RGBImg_bit,[]);
title('Difference');
%%
lookuptable=round(2.^(7:-1:0));
ImageSeq_con=zeros([768 1024 3]);
ImageSeq_Binary=zeros([768 1024 3 280]);
%ImageSeq_Perceived=zeros([768 1024 3 280]);

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
    
  %  for k=1:3
  %      ImageSeq_con(:,:,k)=(~Image_sequence(:,:,i)*255);
  %  end
    
    ImageSeq_con(:,:,c)=Image_sequence(:,:,i)*lookuptable(s);
    ImageSeq_Binary(:,:,:,i)=ImageSeq_con;
    
    
   
    
  %  if i==1
  %  ImageSeq_Perceived(:,:,:,i)=ImageSeq_con;
  %  else
  %  ImageSeq_Perceived(:,:,:,i)=ImageSeq_Perceived(:,:,:,i-1)+ImageSeq_con;
  %  end
    
       
end

%%
ImageSeq_con=uint8(ImageSeq_con);

figure;
imshow(uint8(sum(ImageSeq_Binary,4)),[]);


%%
ImageSeq_order=flipud(Image_sequence(:,:,un_order));

%%

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
end

%%
ImageSeq_Binary=uint8(ImageSeq_Binary);

filename = sprintf('%s/ImageSeq_Binary.mat', output_dir);
save(filename, 'ImageSeq_Binary');




