clear all;
%%
inputdir = 'D:\whp17\Google Drive\Praneeth_Hanpeng\12_16_2019_10_50';

filename = sprintf('%s/dotpattern_2_2_target.png',inputdir);
I_target{1} = imread(filename);



filename = sprintf('%s/red_dotpattern2.JPG',inputdir);
I_captured{1} = imread(filename);

filename = sprintf('%s/green_dotpattern2.JPG',inputdir);
I_captured{2} = imread(filename);


filename = sprintf('%s/blue_dotpattern2.JPG',inputdir);
I_captured{3} = imread(filename);

%% detect points in target image
[m,n] = size(I_target{1});
points_target = featureDetect(I_target,'ROI',{[1,1,n,m]});

imshow(I_target{1},[]); hold on;
title(sprintf('Image %d',i));
plot(points_target{1}.Location(:,1),points_target{1}.Location(:,2),'color','g','marker','o','markersize',14,'linestyle','none');
plot(points_target{1}.Location(:,1),points_target{1}.Location(:,2),'color','g','marker','+','markersize',18,'linestyle','none');

%% reshape the  target points
featureSize = [8, 10];
fixedPoints = ReshapeFeatures(points_target,featureSize);

%% capatured image
for i=1:3
imshow(I_captured{i},[]);
ROI{i} = getrect;
rectangle('Position',ROI{i},'EdgeColor','r');
end


I_processed = PreProcessing(I_captured,'Pattern','dot','Disksize',10);
subplot(3,1,1)
imshow(I_processed{1},[]); title('red');
subplot(3,1,2)
imshow(I_processed{2},[]); title('green');
subplot(3,1,3)
imshow(I_processed{3},[]); title('blue');

points_captured = featureDetect(I_processed,'ROI',ROI);
%%

for i=1:3
subplot(3,1,i)
imshow(I_processed{i},[]); hold on;
title(sprintf('Image %d',i));
plot(points_captured {i}.Location(:,1),points_captured {i}.Location(:,2),'color','g','marker','o','markersize',14,'linestyle','none');
plot(points_captured {i}.Location(:,1),points_captured {i}.Location(:,2),'color','g','marker','+','markersize',18,'linestyle','none');
end
%% reshape the captured image points
MovingPoints = ReshapeFeatures(points_captured,featureSize);
%%
% cpselect(I_captured{1},I_target{1},MovingPoints{1}.Location,fixedPoints{1}.Location);

target_ref  = imref2d(size(I_target{1}));
target_ref2 = imref2d([1404, 2496]);
target_ref2.XWorldLimits = target_ref2.XWorldLimits-200;
target_ref2.YWorldLimits = target_ref2.YWorldLimits-200;

for i =1:3

fix = fixedPoints{1}.Location;
mov = MovingPoints{i}.Location;

index = find(mov(:,1)==-1);
fix(index,:)=[];
mov(index,:) = [];

tform{i} = fitgeotrans(mov,fix,'projective');

[I_warped{i},warped_ref{i}] = imwarp(I_captured{i}, tform{i}, 'OutputView',target_ref);
[I_warped2{i},warped_ref2{i}] = imwarp(I_captured{i}, tform{i}, 'OutputView',target_ref2);

end
%%

for i=1:3
subplot(3,1,i)
imshow(I_warped2{i},[]); hold on;
title(sprintf('Image %d',i));
end



A = imadjust(rgb2gray(I_warped2{1}));
B = imadjust(rgb2gray(I_warped2{2}));
C = imadjust(rgb2gray(I_warped2{3}));
overlay_im = cat(3,C, A, B);
imshow(overlay_im);

imshowpair(B,I_target{1},'falsecolor');
