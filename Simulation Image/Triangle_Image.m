% opengl coordinates formula
radius=1;
Isize=[768,1024];
NumofP=200;
depthRange=[-20,20];
triangle=[-300,-200,15; -250,200,0; -50,0,-15
           350, -150,18; 350,300,-15; 20,-20,0];
Colorvalue=[130;255;100;100;100;100];

Image_sequence=TriangleDepthImage(triangle,depthRange,Colorvalue,'NumofP',NumofP,'radius',radius);





figure;
imshow(sum(Image_sequence,3),[]);


