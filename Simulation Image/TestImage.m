Isize=[768,1024];
Image=zeros([Isize,3]);
R_index=1;
G_index=2;
B_index=3;


a=floor(768/3);
b=floor(768/3*2);

Image(:,1:256,R_index)=repmat(255:-1:0,768,1);
Image(:,256+1:256+255+1,G_index)=repmat(255:-1:0,768,1);
Image(:,256+255+1+1:256+255+255+2,B_index)=repmat(255:-1:0,768,1);

Image=uint8(Image);

figure;
imshow(Image,[]);
%%
imwrite(Image,'C:\Users\whp17\Google Drive\graphics pipeline\NELFD\test6.png');

