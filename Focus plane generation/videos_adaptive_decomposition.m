clear all;
close all;

input_dir = sprintf('adaptive_color_decomposition_images');

full = zeros(2*768, 2*1024, 3, 48);

for subvolume_append = 1:48
    filename = sprintf('adaptive_color_decomposition_images/bin_colorized_%02d.png', subvolume_append);
    colorized = im2double(imread(filename));
        
    filename = sprintf('adaptive_color_decomposition_images/IMG_%02d.png', subvolume_append);
    reconstructed = im2double(imread(filename));
    
    filename = sprintf('adaptive_color_decomposition_images/overall_residue_%02d.png', ...
                       subvolume_append);
    residue = im2double(imread(filename));
   
    filename = 'RGB_Depth/reference.png';
    reference = im2double(imread(filename));
    
    full(1:768, 1:1024,:,subvolume_append) = colorized;
    full(769:end,1:1024,:,subvolume_append) = reconstructed;
    full(1:768, 1025:end,:,subvolume_append) = residue;
    full(769:end,1025:end,:,subvolume_append) = reference;
end

v = VideoWriter('trial.avi');
v.FrameRate = 5;
open(v);
writeVideo(v, full);
close(v);




