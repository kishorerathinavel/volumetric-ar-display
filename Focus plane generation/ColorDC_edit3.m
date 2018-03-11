clear all;
warning off;

RGBImg=imread('trial_03_rgb.png');
load('FocusDepth.mat');
load('trial_03_DepthMap.mat');

figure;
imshow(RGBImg,[]);

figure;
imshow(DepthMap,[]);
%%
NumofBP=280;
colorbit=24;


%%

Image_sequence=GenerateImgSeq2(RGBImg,DepthMap,'NumofBP',NumofBP,'colorbit',colorbit);

figure;
imshow(mean(Image_sequence,3),[]);

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
lookuptable=2.^(7:-1:0);
ImageSeq_con=zeros([768 1024 3]);

for i=1:280
    
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
    
    
    ImageSeq_con(:,:,c)=ImageSeq_con(:,:,c)+Image_sequence(:,:,i)*lookuptable(s); 
    
    
end

%%

ImageSeq_con=uint8(ImageSeq_con);

figure;
imshow(ImageSeq_con,[]);


%%
ImageSeq_order=flipud(Image_sequence(:,:,un_order));

%%

order_new=[1:140,140:-1:1];

ImageSeq_order=order_new(:,:,order_new);

n=40;
for i=1:NumofBP
    n=n+1;
    
    str = sprintf('Model8/Scene_%03d.png',mod(n,280));
    imwrite(ImageSeq_order(:,:,i),str);  

end


