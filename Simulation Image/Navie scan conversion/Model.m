%% Triangle Model 1
linewidth=3;
NumofP=280;
depthRange=[-42,42];
triangle1=[-400,-350,38;
            300,-350,38;
            0, 200, 38];
     
triangle2=RigidTransform(triangle1*0.4,[0,0,pi],[250,50,-50],[1,2,3,4]);
triangle1=RigidTransform(triangle1*0.4,[0,0,pi],[-100,50,25],[1,2,3,4]);
verts=[triangle1;triangle2];

faces=[1,2,3;4,5,6];
%% Triangle Model 2
linewidth=3;
NumofP=280;
depthRange=[-42,42];
triangle1=[-400,-350,38;
            300,-350,30;
            0, 200, 25];
     
triangle2=RigidTransform(triangle1*0.4,[0,0,pi],[250,-50,-50],[1,2,3,4]);
triangle1=RigidTransform(triangle1*0.4,[0,0,pi],[-100,-50,25],[1,2,3,4]);
verts=[triangle1;triangle2];

faces=[1,2,3;4,5,6];

%% Triangle Model 3
linewidth=3;
NumofP=280;
depthRange=[-42,42];
triangle1=[400,300,39; 
         -350,300,20; 
         200,-280,30];
     
triangle2=RigidTransform(triangle1*0.6,[0,0,0],[-150,-100,-20],[1,2,3,4]);

triangle3=RigidTransform(triangle1*0.2,[0,0,0],[-300,-200,-40],[1,2,3,4]);

verts=[triangle1;triangle2;triangle3];

faces=[1,2,3;4,5,6;7,8,9];
%% Teapot Model 1
linewidth=1;
NumofP=280;
[v,f,cindex]=teapotGeometry;
v(:,3)=v(:,3)-max(v(:,3))/2;
v=v(:,[1,3,2]);
depthRange=[-400,400];
teapot1=RigidTransform(v*50,[7/6*pi,pi/12,0],[120,30,200],[2,1,3,4]);
f1=f;



teapot2=RigidTransform(v*50,[7/6*pi,pi/12,0],[-150,30,-200],[2,1,3,4]);
f2=f1+size(v,1);

verts=[teapot1;teapot2];
faces=[f1;f2];
%% cube model
linewidth=5;
NumofP=280;
depthRange=[-42,42];
square1=[-100,100,41;
        0,100,35;
        0,0,35;
        -100,0,41];
    
square2=RigidTransform(square1,[0,0,0],[300,-50,-75],[1,2,3,4]);

verts=[square1;square2];

faces=[1,2,3,4;
       5,6,7,8;
       1,2,6,5;
       2,3,7,6;
       4,3,7,8;
       1,4,8,5];


%%
Image_sequence=ScanConvert3D(verts,faces,'DepthRange',depthRange,'NumofP',280,'linewidth',linewidth);

figure;
imshow(sum(Image_sequence,3),[]);
%%

h = ones(5,5) / 25;
for i=1:NumofP
    I1 = imfilter(Image_sequence(:,:,i),h);
    Image_sequence(:,:,i)=im2bw(I1,0);
        
end
%% save image
n=0;
for i=NumofP:-2:2
    n=n+1;
    str = sprintf('Model Set/Teapot_model1/Triangle_%03d.png', n);
    imwrite(Image_sequence(:,:,i),str);    
end

for i=1:2:279
    n=n+1;
    str = sprintf('Model Set/Teapot_model1/Triangle_%03d.png', n);
    imwrite(Image_sequence(:,:,i),str);    
end


%% Test Seq

n=0;
Image_sequence=zeros([768,1024,280]);
Image_sequence(:,:,1)=1;

for i=1:NumofP
    n=n+1;
    str = sprintf('TestSeq/Seq1/TestImg_%03d.png',n);
    imwrite(Image_sequence(:,:,i),str);  
end
