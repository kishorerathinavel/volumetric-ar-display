clear all;
close all;

%% Hanpeng's amazing guess
% d1+o1=0.09 % measure
o1=0.06; % Guess
%o1=0.1;
f1=0.058; % From Email
d1=0.03; % Guess
f3=0.061;

d2=0.12; % measure
%f3=0.09; % Guess
de=0.07; % measure

%% Found from measurement and brute search
% d1+o1=0.09 % measure
o1=0.06; % Guess
f1=0.0585; % From Email
d1=0.03; % Guess


f3=0.0455; % Measured to be 0.053
d2=0.11; % measure
de=0.055; % measure

%% Parameters from graph.m _ ORIGINAL
o1=0.03; % Exhaustive search
f1=0.0296; % From Email
           % o1=0.03; % Exhaustive search
           % f1=0.0296; % From Email
d1=0.03; % Exhaustive search

f3=0.06; % Measured to be 0.053
d2=0.12; % measure
de=0.03; % measure

%% Parameters from graph.m _ Hanpeng's
o1=0.03; % Exhaustive search
f1=0.0296; % From Email
           % o1=0.03; % Exhaustive search
           % f1=0.0296; % From Email
d1=0.03; % Exhaustive search

f3=0.0456; % Measured to be 0.053
d2=0.11; % measure
de=0.06; % measure

%%
OpticsParams.o1 = o1;
OpticsParams.f1 = f1;
OpticsParams.d1 = d1;
OpticsParams.d2 = d2;
OpticsParams.f3 = f3;
OpticsParams.de = de;

data_folder_path = get_data_folder_path();
filename = sprintf('%s/Params/OpticsParams.mat', data_folder_path);
save(filename,'OpticsParams');

%% Hanepng's parameters

num=280; % num of sample depths along z direction(depth direction)
MinOpPower=12; % min optical power of focus tunable lens(in diopters)
% current 87.5
%MaxOpPower=15; % max optical power of focus tunable lens(in diopters)

MaxOpPower=16; % max optical power of focus tunable lens(in diopters)
               % from graph.m
% current 137.5
t=1:num;
p=2;

%% Hanepng's parameters

num=280; % num of sample depths along z direction(depth direction)
MinOpPower=8.5; % min optical power of focus tunable lens(in diopters)
% current 87.5
%MaxOpPower=15; % max optical power of focus tunable lens(in diopters)

MaxOpPower=13; % max optical power of focus tunable lens(in diopters)
               % from graph.m
% current 137.5
t=1:num;
p=2;

%% linear driving singal
f_t_inverse=linspace(MinOpPower,MaxOpPower,num); 
f2=1./f_t_inverse;

%% triangular driving signal
Magnitude=MaxOpPower-MinOpPower;
offset=MinOpPower;
p1=Magnitude*2*p/num*(1:1:ceil(num/2/p));
p2=-p1+max(p1);
p_11=[p2,p1];
p_w=repmat(p_11,1,p);
f_t_inverse=p_w(1:num)+offset;
f2=1./f_t_inverse;

%% finding depthlist using triangular driving signal
t_u=0:58:1e6/60;
delt_t=1e6/60/2;
tan1=(MinOpPower-MaxOpPower)/delt_t;
y1=tan1*t_u+MaxOpPower;

tan2=(MaxOpPower-MinOpPower)/delt_t;
y2=tan2*t_u+2*MinOpPower-MaxOpPower;

index=max(find(t_u<=delt_t));
f_t_inverse=[y1(1:index),y2(index+1:end)];
t=[];
for i=1:p
    offset=1e6/60*(i-1);
    t=[t,t_u+offset];
end

f_t_inverse=repmat(f_t_inverse,1,p);
f2=1./f_t_inverse;

%% sinusoidal driving signal
Magnitude=(MaxOpPower-MinOpPower)/2;
offset=(MaxOpPower+MinOpPower)/2;

f_t_inverse=Magnitude*sin(t*2*p*pi/num)+offset;
f2=1./f_t_inverse;

%% finding depthlist using sin driving signal
t=0:58:1e6/60*p;
Magnitude=(MaxOpPower-MinOpPower)/2;
offset=(MaxOpPower+MinOpPower)/2;
f_t_inverse=Magnitude*cos(2*pi*60/1e6*t)+offset;
f2=1./f_t_inverse;

%% considering three lens separately
i1=f1*o1/(o1-f1);
o2=i1-d1;


i2=f2*o2./(o2+f2);
%i2=f2*o2./(o2-f2);
o3=d2-i2;


i3=f3*o3./(o3-f3);
ie=-i3+de;

%% Field of View

O_1 = 0.01778; % meters. O_1 = 0.7 inches
M1 = -i1/o1;
M2 = -i2./o2;
M3 = -i3./o3;
I_e = M1 .* M2 .* M3 .* O_1;
theta = 2*rad2deg(atan(I_e./ie/2));
%figure; plot(theta);

figure;
subplot(2,2,1)
plot(t,f_t_inverse,'r*'); hold on;
title('Focus-tunable Lens Driving signal');
xlabel('time/us');
ylabel('Optical power/diopter');


subplot(2,2,2)
plot(t,1./ie,'r*');
title('Focal plane depth changes in diopter');
xlabel('time/us');
ylabel('Focal plane depth/diopter');

subplot(2,2,3)
plot(t,ie,'r*');
title('Focal plane depth changes in meter');
xlabel('time/us');
ylabel('Focal plane depth/m');

subplot(2,2,4)
plot(t,theta,'r*');
title('Field of view');
xlabel('time/us');
ylabel('Field of view');

%% phase correction

phaseNum=100;

t_phase=t(phaseNum:phaseNum+num-1);
f_t_inverse_phase=f_t_inverse(phaseNum:phaseNum+num-1);
ie_phase=ie(phaseNum:phaseNum+num-1);
theta_phase = theta(phaseNum:phaseNum+num-1);

figure;
subplot(2,2,1)
plot(t,f_t_inverse,'b-',t_phase,f_t_inverse_phase,'r*'); hold on;
title('Focus-tunable Lens Driving signal');
xlabel('time/us');
ylabel('Optical power/diopter');


subplot(2,2,2)
plot(t,1./ie,'b-',t_phase,1./ie_phase,'r*');
title('Focal plane depth changes in diopter');
xlabel('time/us');
ylabel('Focal plane depth/diopter');

subplot(2,2,3)
plot(t,ie,'b-',t_phase,ie_phase,'r*');
title('Focal plane depth changes in meter');
xlabel('time/us');
ylabel('Focal plane depth/m');

subplot(2,2,4)
plot(t,theta,'b-',t_phase, theta_phase,'r*');
title('Field of view');
xlabel('time/us');
ylabel('Field of view');

%%
d=ie_phase;



[d_sort,order]=sort(d);
un_order(order)=1:num;



fov_sort = theta_phase(order);


figure;
plot(d_sort, fov_sort,'r*');
title('FOV Changes');
xlabel('distance/m');
ylabel('FOV/degree');


figure;
plot(1:length(fov_sort), fov_sort,'r*');
title('FOV Changes');
xlabel('Binary plane number(from near to far)');
ylabel('FOV/degree');

%[f_sort,forder]=sort(f_t_inverse(1:280));

%%
data_folder_path = get_data_folder_path();
output_dir = sprintf('%s/Params', data_folder_path);
filename = sprintf('%s/FocusDepth_sin.mat', output_dir);
save(filename, 'd', 'd_sort', 'order', 'un_order','fov_sort');

% Description of variables:
% d - distance to depth plane in meters ordered in sequence of when each depth plane is displayed.
% d_sort - sorted distanced to depth planes
% order - index for each entry in d_sort in d
% un_order - 1:num
% fov_sort - FoV for each depth plane following same order of d_sort

