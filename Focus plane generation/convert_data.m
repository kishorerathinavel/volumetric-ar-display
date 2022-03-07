clear all;
close all;
%%

data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/RGBD_data', data_folder_path);
output_dir = input_dir;

%%
filename = sprintf('%s/trial_00_depth.png', input_dir);

data = importdata(filename, 'png');

alpha = data.alpha;
cdata = data.cdata;


r_img = cdata(:,:,1);
g_img = cdata(:,:,2);
b_img = cdata(:,:,3);
a_img = alpha;
figure; imagesc(a_img); colorbar;
figure; imagesc(r_img); colorbar;
% figure; imagesc(g_img); colorbar;
% figure; imagesc(b_img); colorbar;

%%

a_img_16 = uint16(a_img);
r_img_16 = uint16(r_img);
g_img_16 = uint16(g_img);
b_img_16 = uint16(b_img);

depth_img = 256*a_img_16 + r_img_16;
figure; imagesc(depth_img); colorbar;


%%
f_depth_img = im2double(depth_img);
f_a_img_16 = im2double(a_img_16);
figure; imshow(normalize(f_depth_img));
figure; imshow(normalize(f_a_img_16));

DepthMap=normalize(f_depth_img);
figure;imagesc(DepthMap);colorbar;
%%

filename = sprintf('%s/trial_00_DepthMap.mat', output_dir);

save(filename, 'DepthMap');
