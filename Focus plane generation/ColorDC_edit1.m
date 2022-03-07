clear all;
NumofBP=280;
colorbit=9;
NumofCP=NumofBP-colorbit+1;
DepthList=linspace(0,1,NumofCP);
%%


%% Read Image
RGBImg=imread('TexturedBunny00.png');
DepthImg=imread('TexturedBunny_depthmap00.png');


[m,n,q]=size(RGBImg);

figure;
imshow(RGBImg,[]);

figure;
imshow(DepthImg,[]);

%% resize to 768*1024

RGBImg=imresize(RGBImg,[768 1024]);
DepthImg=imresize(DepthImg,[768 1024]);
DepthImgB=double(DepthImg(:,:,1))/255;
%% crop to 768*1024
m_s=floor((m-768)/2);
n_s=floor((n-1024)/2);
RGBImg=RGBImg(m_s:m_s+767,n_s:n_s+1023,:);
DepthImg=DepthImg(m_s:m_s+767,n_s:n_s+1023,:);
DepthImgB=double(DepthImg(:,:,1))/255; % normalize to range [0, 1]

figure;
imshow(DepthImgB,[]);

figure;
imshow(RGBImg,[]);
%%
RB=double(de2bi(RGBImg(:,:,1),8));
GB=double(de2bi(RGBImg(:,:,2),8));
BB=double(de2bi(RGBImg(:,:,3),8));
RGB_BR=[RB,GB,BB];

%%
ValidIndex=find(DepthImgB>0);
DepthSeparater=[0,DepthList(1:end-1)+DepthList(2:end),1];
FocalPlanes=zeros([768 1024 NumofBP]);

for i=1:NumofCP
    index=find(DepthImgB>=DepthSeparater(i)&DepthImgB<DepthSeparater(i+1));
    index=intersect(index,ValidIndex);
    
    if~isempty(index)
        
        for j=1:numel(index)
            [a,b]=ind2sub([768 1024], index(j));
            s=mod(i,colorbit);
            
            if s==0
                s=colorbit;
            end
            
            FocalPlanes(a,b,i:(i+colorbit-1))=[RGB_BR(index(j),s:end),RGB_BR(index(j),1:s-1)];
        end
          
    end
    
end


%%
figure;
imshow(mean(FocalPlanes,3),[]);

c=find(mean(FocalPlanes,3)>0);
test=zeros([768 1024]);
test(c)=1;
imshow(test,[]);