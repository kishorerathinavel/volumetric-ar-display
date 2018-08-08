function LEDs=returnMeanOfChannels(img)
LEDs = [];




r_img = img(:,:,1); 
g_img = img(:,:,2);
b_img = img(:,:,3);

r_mean = mean(r_img(:));
g_mean = mean(g_img(:));
b_mean = mean(b_img(:));
LEDs = [r_mean, g_mean, b_mean];
