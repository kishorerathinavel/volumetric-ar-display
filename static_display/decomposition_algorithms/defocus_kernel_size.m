function [conv_kernel_px_radius] = defocus_kernel_size(pupil_radius, field_of_view, defocus_depth, focal_depth)
conv_kernel_phy_radius = pupil_radius*(abs(defocus_depth - focal_depth))/ focal_depth;
defocus_plane_image_size = defocus_depth*tan(degtorad(field_of_view/2));
conv_kernel_px_radius = 512*conv_kernel_phy_radius/defocus_plane_image_size;


