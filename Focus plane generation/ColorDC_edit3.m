clear all;
close all;
warning off;

%%
data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/RGBD_data', data_folder_path);
output_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);

%%
filename = sprintf('%s/trial_00_rgb.png',input_dir);
RGBImg=imread(filename);
filename = sprintf('%s/%s/FocusDepth.mat',data_folder_path, 'FocusDepth');
load(filename);
filename = sprintf('%s/trial_00_DepthMap.mat',input_dir);
load(filename);

figure;
imshow(RGBImg,[]);

figure;
imshow(DepthMap,[]);
%%
NumofBP=280;
colorbit=24;


%%

[Image_sequence,Image_CutVol]=GenerateImgSeq2(RGBImg,DepthMap,'NumofBP',NumofBP,'colorbit',colorbit);

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
title(['Original RGB Img']);

subplot(3,1,3);
imshow(RGBImg_re-RGBImg_bit,[]);
title(['Difference']);



%%
lookuptable=round(2.^(7:-1:0)/128*(255-32)+32);
lookuptable=255:-32:30;
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
    
    
   
    
    if i==1
    ImageSeq_Perceived(:,:,:,i)=ImageSeq_con;
    else
    ImageSeq_Perceived(:,:,:,i)=ImageSeq_Perceived(:,:,:,i-1)+ImageSeq_con;
    end
    
       
end

%%
ImageSeq_con=uint8(ImageSeq_con);

figure;
imshow(ImageSeq_con,[]);


%%
ImageSeq_order=flipud(Image_sequence(:,:,un_order));

%%

for i=1:NumofBP
    filename = sprintf('%s/Scene_%03d.png', output_dir, i);
    imwrite(ImageSeq_order(:,:,i),filename);  
end

%%
ImageSeq_Binary=uint8(ImageSeq_Binary);

filename = sprintf('%s/ImageSeq_Binary.mat', output_dir);
save(filename, 'ImageSeq_Binary');


