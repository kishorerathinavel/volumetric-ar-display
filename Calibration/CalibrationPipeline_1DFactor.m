%% Calibration pipeline
% calibration pipeline for FOV change
% Approximate a 1D function: the size respect to the image plane depth
% (represented as image plane number)
clear all;
%% get the path where all data are stored
addpath('library');
data_folder_path =  get_data_folder_path();

%% red captured image
inputdir = sprintf('%s/Calibration/CalibratedRect_20/Capture',data_folder_path);
num = 20;
for i=1:num
    filename = sprintf('%s/set%d.png',inputdir,i);
    images{i} = imread(filename);
end



use_old_data = true;

if use_old_data == true
load('edge_location');
else
    
% manually select an edge for deciding the relative size of each image
% plane
% (x,y) coord of end points
% edge_location(i,:,1) and edge_location(i,:,2) are two points of ith image
edge_location = zeros([num,2,2]);

for i =1:num
    imshow(images{i},[]); hold on;
    imagetitle = sprintf('Image %d',i);
    title(imagetitle);

    % selet two end points of each edge
    for k = 1:2  
     [x,y] = ginput(1,'Color',[1,1,1]);
     % hold on;
     plot(x,y,'marker','o','color','r','markersize',10);
     plot(x,y,'marker','+','color','r','markersize',10);
     drawnow
     edge_location(i,:,k) = [x,y];     
    end  
end
end
%%
save edge_location.mat edge_location
%%
Diff = abs(edge_location(:,:,1) - edge_location(:,:,2));
index = find(max(mean(Diff)));


RelativeFactor = Diff(:,index)./Diff(1,index);


Location = double(int64(linspace(1,280,num)));


p = polyfit(Location,RelativeFactor',3);
z = 1:280;
S_z = polyval(p,z);

plot(Location,RelativeFactor,'o','LineWidth',3,'FontSize',10); hold on;
plot(z,S_z,'LineWidth',5);


save data Location RelativeFactor z S_z

save Factor_z S_z
