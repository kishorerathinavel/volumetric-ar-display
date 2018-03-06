clear all;
NumofBP=280;
colorbit=24;
RGBImg=imread('Bench00.png');
DepthImg=imread('Bench_depthmap00.png');
figure;
imshow(RGBImg,[]);

figure;
imshow(DepthImg,[]);

%%
Image_sequence=GenerateImgSeq(RGBImg,DepthImg,'NumofBP',NumofBP,'colorbit',colorbit);

figure;
imshow(mean(Image_sequence,3),[]);