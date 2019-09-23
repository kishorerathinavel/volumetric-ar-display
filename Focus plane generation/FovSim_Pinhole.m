clear all;
warning off;

%%
data_folder_path = get_data_folder_path();
input_dir = sprintf('%s/scene_decomposition_output/current', data_folder_path);

%%

filename = sprintf('%s/%s/FocusDepth.mat',data_folder_path, 'FocusDepth');
load(filename);
filename = sprintf('%s/ImageSeq_Binary.mat',input_dir);
load(filename);