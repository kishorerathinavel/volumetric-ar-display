clear all;
I=imread('Calibration.jpg');
h=figure();
imshow(I,[]);
Image=imcrop(I);
close(h);

R=Image(:,:,1);
G=Image(:,:,2);
B=Image(:,:,3);

r=mean2(R);
g=mean2(G);
b=mean2(B);

gray=(r+g+b)/3;
kr=gray/r;
kg=gray/g;
kb=gray/b;

%%
save ColorCalibration.mat kr kg kb