clear all;
%%

UI=imread('symmetric_USAF_1280_720.png');
UI_new = imresize(UI,[768,1024]);
U=im2bw(UI_new,graythresh(UI_new));
imshow(U,[]);
%%
checker=imread('4kCheckerboard.png');
Ir=imrotate(checker,7);
Ic=imcrop(Ir,[856 566 1023 767]);
Ic=insertText(double(Ic),[220 100;600,400],{'2','0'},'FontSize',150, 'BoxColor','white','TextColor','Black');
I=im2bw(Ic,graythresh(Ic));
imshow(I,[]);
%%
x0=1024/2;
y0=768/2;
k=tan(83/180*pi);
y=(0:767)+0.5;
x=(y-y0)/k+x0;
x=ceil(x);
I=zeros([768 1024]);

for i=1:768
    n=min(x(i),1024);
    n=max(1,n);
    I(i,1:n)=1;
end


imshow(I,[]);

%%
Img=zeros([768,1024,280]);
NumofBP=280;
Img(:,:,140-23:140)=repmat(I,1,1,24);
%%Img(:,:,end)=U;
load('FocusDepth.mat');


%%
Img_order=flipud(Img(:,:,un_order));
%%


for i=1:NumofBP
       
    str = sprintf('MTF_set2/Scene_%03d.png',i);
    imwrite(Img_order(:,:,i),str);  

end