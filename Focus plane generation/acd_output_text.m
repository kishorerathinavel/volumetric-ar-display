nFS_PSNR = FS_PSNR';
nFS_SSIM = FS_SSIM';
nFS_PSNR = [pinhole_PSNR'; nFS_PSNR];
nFS_SSIM = [pinhole_SSIM'; nFS_SSIM];

experiment_names = {'All (pinhole aperture)', '15 cm / 6.67 D', '20 cm / 4.0 D', '50 cm / 2.0 D', '450 cm / 0.22 D'};


str = '';
for iter_1 = 1:5
    str = sprintf('%s%s & ', str, experiment_names{iter_1});
    for iter_2 = 1:5
        str = sprintf('%s %2.2f &', str, nFS_PSNR(iter_1, iter_2));
    end
    str = sprintf('%s \b\b \\\\ \n \\hline \n', str);
end
str

str = '';
for iter_1 = 1:5
    str = sprintf('%s%s & ', str, experiment_names{iter_1});
    for iter_2 = 1:5
        str = sprintf('%s %2.3f &', str, nFS_SSIM(iter_1, iter_2));
    end
    str = sprintf('%s \b\b \\\\ \n \\hline \n', str);
end
str



