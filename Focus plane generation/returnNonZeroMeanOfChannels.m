function LEDs=returnNonZeroMeanOfChannels(img)
LEDs = [];

r_img = img(:,:,1); 
g_img = img(:,:,2);
b_img = img(:,:,3);

nz_r = r_img(r_img > 0);
nz_g = g_img(g_img > 0);
nz_b = b_img(b_img > 0);

if(isempty(nz_r))
    r_mean = 0;
else
    r_mean = mean(nz_r);
end

if(isempty(nz_g))
    g_mean = 0;
else
    g_mean = mean(nz_g);
end

if(isempty(nz_b))
    b_mean = 0;
else
    b_mean = mean(nz_b);
end

LEDs = [r_mean, g_mean, b_mean];
LEDs(isnan(LEDs)) = 0;
LEDs(LEDs < 0) = 0;






