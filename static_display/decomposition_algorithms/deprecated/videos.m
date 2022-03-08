NumofBP=280;
load('Image_CutVol.mat');
%%
n=10;
full=zeros([768+3*n 1024+3*n 3 280]);

labels = true;

%%

if(labels == true)
    count = 1;
    for i=NumofBP-11:NumofBP
        str=['Color Volume Slice: ', num2str(count)];
        Image_CutVol(:,:,:,i)=insertText(Image_CutVol(:,:,:,i),[10 10],str,'FontSize',40, 'BoxColor','Yellow','TextColor','Black');
        count = count + 1;
    end

    for i=1:NumofBP-12
        str=['Color Volume Slice: ', num2str(count)];
        Image_CutVol(:,:,:,i)=insertText(Image_CutVol(:,:,:,i),[10 10],str,'FontSize',40, 'BoxColor','Yellow','TextColor','Black');
        count = count + 1;
    end
end

%%
count = 1;
for i=NumofBP-11:NumofBP
    full(n+1:n+384,n+1:n+512,:,count)=imresize(Image_CutVol(:,:,:,i),0.5,'nearest');
    count = count + 1;
end

for i=1:NumofBP-12
    full(n+1:n+384,n+1:n+512,:,count)=imresize(Image_CutVol(:,:,:,i),0.5,'nearest');
    count = count + 1;
end

%%
clear Image_CutVol;
load('ImageSeq_Perceived.mat');

%%
if(labels == true)
    for i=1:NumofBP
        str='Time Integrated Perceived Volume';
        ImageSeq_Perceived(:,:,:,i)=insertText(ImageSeq_Perceived(:,:,:,i),[10 10],str,'FontSize',40, 'BoxColor','Yellow','TextColor','Black');
    end
end

%%
for i=1:NumofBP
    full(2*n+385:end-n,n+1:n+512,:,i)=imresize(ImageSeq_Perceived(:,:,:,i),0.5,'nearest');
end



%%
clear ImageSeq_Perceived;
load('ImageSeq_Binary.mat');
%%
if(labels == true)
    for i=1:NumofBP
        str=['Binary Volume Slice: ', num2str(i)];
        ImageSeq_Binary(:,:,:,i)=insertText(ImageSeq_Binary(:,:,:,i),[10 10],str,'FontSize',40, 'BoxColor','Yellow','TextColor','Black');
    end
end

%%
for i=1:NumofBP
    full(n+1:n+384,2*n+513:end-n,:,i)=imresize(ImageSeq_Binary(:,:,:,i),0.5,'nearest');
end

%%
clear ImageSeq_Binary;

RGBImg=imread('RGB_Depth/trial_08_rgb.png');
load('RGB_Depth/trial_08_DepthMap.mat');
%%
Index=find(DepthMap<1);
I=zeros([768 1024]);
I(Index)=1;
filter=uint8(repmat(I,1,1,3));
img=filter.*RGBImg;

if(labels == true)
    img=insertText(img,[10 10],'GroundTruth','FontSize',40, 'BoxColor','Yellow','TextColor','Black');
end

%%
for i=1:NumofBP
    full(2*n+385:end-n,2*n+513:end-n,:,i)=imresize(img,0.5);
end

if(labels == true)
    save full.mat full -v7.3
else
    save full_wo_labels.mat full -v7.3
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

%% 

v = VideoWriter('trial.avi');
v.FrameRate = 5;
open(v);
writeVideo(v, full);
close(v);

%% 

v = VideoWriter('trial2.avi');
v.FrameRate = 5;
open(v);
pfull = permute(full, [2 4 3 1]);
writeVideo(v, pfull);
close(v);


%% 

v = VideoWriter('trial3.avi');
v.FrameRate = 5;
open(v);
pfull = permute(full, [1 4 3 2]);
writeVideo(v, pfull);
close(v);








