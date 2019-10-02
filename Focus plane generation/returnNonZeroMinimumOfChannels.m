function LEDs=returnNonZeroMinimumOfChannels(img)
LEDs = [];

r_img = img(:,:,1); 
g_img = img(:,:,2);
b_img = img(:,:,3);

nz_r = r_img(r_img > 0);
nz_g = g_img(g_img > 0);
nz_b = b_img(b_img > 0);

if(isempty(nz_r))
    r_min = 0;
else
    r_min = min(nz_r(:));
end

if(isempty(nz_g))
    g_min = 0;
else
    g_min = min(nz_g(:));
end

if(isempty(nz_b))
    b_min = 0;
else
    b_min = min(nz_b(:));
end

LEDs = [r_min, g_min, b_min];


