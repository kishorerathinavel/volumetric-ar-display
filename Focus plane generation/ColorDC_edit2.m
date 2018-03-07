clear all;
NumofBP=280;
colorbit=24;
RGBImg=imread('Bench00.png');
DepthImg=imread('Bench_depthmap00.png');
load('FocusDepth.mat');
figure;
imshow(RGBImg,[]);

figure;
imshow(DepthImg,[]);

%%

Image_sequence=GenerateImgSeq(RGBImg,DepthImg,'NumofBP',NumofBP,'colorbit',colorbit);

figure;
imshow(mean(Image_sequence,3),[]);

%% test results



RB=fliplr(double(de2bi(RGBImg(:,:,1),8)));
GB=fliplr(double(de2bi(RGBImg(:,:,2),8)));
BB=fliplr(double(de2bi(RGBImg(:,:,3),8)));
m=colorbit/3;
RB_con=zeros(size(RB));
GB_con=zeros(size(GB));
BB_con=zeros(size(BB));
RB_con(:,1:m)=RB(:,1:m);
GB_con(:,1:m)=GB(:,1:m);
BB_con(:,1:m)=BB(:,1:m);

R_con=bi2de(fliplr(RB_con));
G_con=bi2de(fliplr(GB_con));
B_con=bi2de(fliplr(BB_con));

R=reshape(R_con,size(RGBImg,1),size(RGBImg,2));
G=reshape(G_con,size(RGBImg,1),size(RGBImg,2));
B=reshape(B_con,size(RGBImg,1),size(RGBImg,2));
RGBImg_con=uint8(cat(3,R,G,B));

figure;
imshow(RGBImg_con,[]);
figure;
imshow(double(RGBImg-RGBImg_con)/255,[]);

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