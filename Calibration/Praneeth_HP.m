inputdir = 'D:\whp17\Google Drive\Praneeth_Hanpeng';

filename = sprintf('%s/circles_1_target.png',inputdir);
I_target{1} = imread(filename);

filename = sprintf('%s/IMG_0766.JPG',inputdir);
I_captured{1} = imread(filename);


%%
imshow(I_target{1},[]);
ROI = getrect;
rectangle('Position',ROI,'EdgeColor','r');




points_target = featureDetect(I_target,'ROI',ROI);

imshow(I_target{1},[]); hold on;
title(sprintf('Image %d',i));
plot(points_target{1}.Location(:,1),points_target{1}.Location(:,2),'color','g','marker','o','markersize',14,'linestyle','none');
plot(points_target{1}.Location(:,1),points_target{1}.Location(:,2),'color','g','marker','+','markersize',18,'linestyle','none');

%%
imshow(I_captured{1},[]);
ROI = getrect;
rectangle('Position',ROI,'EdgeColor','r');

I_gray{1} = rgb2gray(I_captured{1});

points_captured = featureDetect(I_gray,'ROI',ROI);
%%
imshow(I_gray{1},[]); hold on;
title(sprintf('Image %d',i));
plot(points_captured {1}.Location(:,1),points_captured {1}.Location(:,2),'color','g','marker','o','markersize',14,'linestyle','none');
plot(points_captured {1}.Location(:,1),points_captured {1}.Location(:,2),'color','g','marker','+','markersize',18,'linestyle','none');