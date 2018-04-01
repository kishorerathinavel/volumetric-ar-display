NumofBP=280;
load('Image_CutVol.mat');
%%
n=10;
full=zeros([768+3*n 1024+3*n 3 280]);

%%
for i=1:NumofBP
    str=['Color Volume Slice: ', num2str(i)];
    Image_CutVol(:,:,:,i)=insertText(Image_CutVol(:,:,:,i),[10 10],str,'FontSize',40, 'BoxColor','Yellow','TextColor','Black');
end
%%
for i=1:NumofBP
    full(n+1:n+384,n+1:n+512,:,i)=imresize(Image_CutVol(:,:,:,i),0.5,'nearest');
end

%%
clear Image_CutVol;
load('ImageSeq_Binary.mat');

%%
for i=1:NumofBP
    str=['Binary Volume Slice: ', num2str(i)];
    ImageSeq_Binary(:,:,:,i)=insertText(ImageSeq_Binary(:,:,:,i),[10 10],str,'FontSize',40, 'BoxColor','Yellow','TextColor','Black');
end
%%
for i=1:NumofBP
    full(n+1:n+384,2*n+513:end-n,:,i)=imresize(ImageSeq_Binary(:,:,:,i),0.5,'nearest');
end
%%
clear ImageSeq_Binary;
load('ImageSeq_Perceived.mat');
%%
for i=1:NumofBP
    str='Time Integrated Perceived Image';
    ImageSeq_Perceived(:,:,:,i)=insertText(ImageSeq_Perceived(:,:,:,i),[10 10],str,'FontSize',40, 'BoxColor','Yellow','TextColor','Black');
end
%%
for i=1:NumofBP
    full(2*n+385:end-n,n+1:n+512,:,i)=imresize(ImageSeq_Perceived(:,:,:,i),0.5,'nearest');
end

%%
clear ImageSeq_Perceived;

RGBImg=imread('RGB_Depth/trial_08_rgb.png');
load('RGB_Depth/trial_08_DepthMap.mat');
%%
Index=find(DepthMap<1);
I=zeros([768 1024]);
I(Index)=1;
filter=uint8(repmat(I,1,1,3));
img=filter.*RGBImg;

 img=insertText(img,[10 10],'GroundTruth','FontSize',40, 'BoxColor','Yellow','TextColor','Black');
%%
for i=1:NumofBP
    full(2*n+385:end-n,2*n+513:end-n,:,i)=imresize(img,0.5);
end

%%
c=240;
full(1:n,1:end,:,:)=c;
full(end-(n-1):end,1:end,:,:)=c;
full(1:end,1:n,:,:)=c;
full(1:end,end-(n-1):end,:,:)=c;
full(n+385:2*n+384,:,:,:)=c;
full(:,n+513:2*n+512,:,:)=c;
full=uint8(full);