function img = displayed_image(LEDs, bin_img)
s = size(bin_img);
img = zeros(s(1), s(2), 3);

img(:,:,1) = LEDs(1)*bin_img;
img(:,:,2) = LEDs(2)*bin_img;
img(:,:,3) = LEDs(3)*bin_img;