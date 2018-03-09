clear all;
warning off;

RGBImg=imread('Bench00.png');
DepthImg=imread('Bench_depthmap00.png');
load('FocusDepth.mat');
figure;
imshow(RGBImg,[]);

figure;
imshow(DepthImg,[]);
%%
NumofBP=280;
colorbit=9;


%%

Image_sequence=GenerateImgSeq(RGBImg,DepthImg,'NumofBP',NumofBP,'colorbit',colorbit);

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
    
    if order(i)==104
    ImageSeq_con(:,:,c)=Image_sequence(:,:,i)*lookuptable(s); 
    end
    
    ImageSeq_con=uint8(ImageSeq_con);
    str = sprintf('Test/BenchImg_%03d.png',order(i));
    
    imwrite(flipud(ImageSeq_con),str);
end

%%

ImageSeq_con=uint8(ImageSeq_con);

figure;
imshow(ImageSeq_con,[]);

%%
ImageSeq_order=flipud(Image_sequence(:,:,un_order));

%%
n=0;
for i=1:NumofBP
    n=n+1;
    
    str = sprintf('Test/BenchImg_%03d.png',n);
    
    if n==104;
    imwrite(ImageSeq_order(:,:,i),str);  
    else
    imwrite(zeros([768 1024]),str);  
    end
end