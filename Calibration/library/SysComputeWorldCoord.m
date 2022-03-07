function [x,y,z] = SysComputeWorldCoord(x_d,y_d,c_d,OpticsParams)
% This function takes in triple (x_d, y_d, c_d) and compute corresponding 
% (x, y, z).
% The Optics parameters are consistent with Focal_plane_depth2.m
% Input: (x_d,y_d,c_d) 
%        OpticsParams: the parameters of the optical setup
%
% The optical power of the focus tunable lens in the setup are determined
% from the driving current according to the Focal length vs current plot
% from optotune.(This is not necessarily correct cause the optical power of 
% the focus tunable is dependent on the frenquency response when running by 
% sinusoidal or triangular input).




% optical power vs current function plot
% two points reading from the plot
x_current = [50,225];
y_power = [10,20];
p = polyfit(x_current,y_power,1);

f2_dpt = ployval(p,c_d);
f2 = 1./f2_dpt;

o1 = OpticsParams.o1;
f1 = OpticsParams.f1; 
d1 = OpticsParams.d1;
d2 = OpticsParams.d2;
f3 = OpticsParams.f3;
de = OpticsParams.de;

% calculations from thin lens equation
i1=f1*o1/(o1-f1);
o2=i1-d1;

i2=f2*o2./(o2+f2);
o3=d2-i2;

i3=f3*o3./(o3-f3);
ie=-i3+de;

z = ie;

% magnification factor
M1 = -i1/o1;
M2 = -i2./o2;
M3 = -i3./o3;

M = M1.* M2.* M3;

%convvert pixel location (x_d, y_d) to (x_o,y_o) in optical center
%coordinates





end