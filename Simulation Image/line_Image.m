% coordinates are in mm
depthR=[0,40];
Isize=[480,320];
NumofP=100;
radius=1;

% line equation start + t*dir
% CV coordinates tradition applied
start=[30,30,0];
dir=[20,23,3];

t=(linspace(depthR(1),depthR(2),NumofP)-start(3))/dir(3);
x=start(1)+t*dir(1);
y=start(2)+t*dir(2);

points2D=round([x;y])';
mask=find(points2D(:,1)>0 & points2D(:,2)>0 & points2D(:,1)<=Isize(2) & points2D(:,2)<=Isize(1));
points2D=points2D(mask,:);
Image_sequence=zeros([Isize,NumofP]);

for i=1:length(mask)
Image_sequence(points2D(i,2)-radius:points2D(i,2)+radius, points2D(i,1)-radius:points2D(i,1)+radius,mask(i))=1;
end

figure;
imshow(Image_sequence(:,:,100),[]);



