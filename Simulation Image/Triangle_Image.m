% opengl coordinates formula
Isize=[768,1024];
NumofP=100;
depthRange=[-20,20];
triangle=[-300,-200,15; -250,200,0; -50,0,-15
           350, -150,18; 350,300,-15; 20,-20,0];

Image_sequence=TriangleDepthImage(triangle,depthRange,Isize,NumofP);


figure;
imshow(sum(Image_sequence,3),[]);





       