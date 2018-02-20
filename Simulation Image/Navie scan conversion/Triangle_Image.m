% opengl coordinates formula
radius=10;
Isize=[768,1024];
NumofP=280;
depthRange=[-40,40];
triangle=[-400,-300,39; 
           350,-300,20; 
           -200,280,30;
           100,50,-39; 
           400,100,-25; 
           150,300,-30];
Colorvalue=[1;1;1;1;1;1];

Image_sequence=TriangleDepthImage(triangle,depthRange,Colorvalue,'NumofP',NumofP,'radius',radius);





figure;
imshow(sum(Image_sequence,3),[]);

%%
n=0;
for i=NumofP:-2:2
    n=n+1;
    str = sprintf('Triangle_all/Triangle_%03d.png', n);
    imwrite(Image_sequence(:,:,i),str);    
end

for i=1:2:279
    n=n+1;
    str = sprintf('Triangle_all/Triangle_%03d.png', n);
    imwrite(Image_sequence(:,:,i),str);    
end