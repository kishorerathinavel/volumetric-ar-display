function LEDs=returnNonZeroMeanOfChannels(img)
LEDs = [];

r_img = img(:,:,1); 
g_img = img(:,:,2);
b_img = img(:,:,3);

nz_r = r_img(r_img > 0);
nz_g = g_img(g_img > 0);
nz_b = b_img(b_img > 0);

r_mean = mean(nz_r);
g_mean = mean(nz_g);
b_mean = mean(nz_b);
LEDs = [r_mean, g_mean, b_mean];

