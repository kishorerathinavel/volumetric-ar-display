function [out_img] = normalize(in_img)
out_img = (in_img - min(in_img(:)))./(range(in_img(:)));
