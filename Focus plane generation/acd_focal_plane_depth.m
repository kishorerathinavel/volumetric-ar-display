clear all;
close all;

%% 
showFigures = false;
sinusoidal = false;
triangular = true;
apply_phase_correction = false;

%% Parameters
o1=0.03; % Exhaustive search
f1=0.0296; % From Email
           % o1=0.03; % Exhaustive search
           % f1=0.0296; % From Email
d1=0.03; % Exhaustive search

f3=0.06; % Measured to be 0.053
d2=0.12; % measure
de=0.03; % measure

num=acd_get_num_binary_planes(); % num of sample depths along z direction(depth direction)
MinOpPower=12; % min optical power of focus tunable lens(in diopters)
MaxOpPower=16; % max optical power of focus tunable lens(in diopters)
               % from graph.m

p=2;
t=1:p*num;
frequency = 60;


%% sinusoidal driving signal
if(sinusoidal == true)
    t=(t/num)*(1/frequency);
    %t=0:58:1e6/60*p;
    Magnitude=(MaxOpPower-MinOpPower)/2;
    offset=(MaxOpPower+MinOpPower)/2;
    f_t_inverse=Magnitude*sin(2*pi*frequency*t + pi/2)+offset;
    %f_t_inverse=Magnitude*sin(t*2*p*pi/num)+offset;
    f2=1./f_t_inverse;
end

%% triangular driving signal
if(triangular == true)
    t_u=(t/num)*(1/frequency);
    delt_t=(1/2)*(1/frequency);
    
    Magnitude=MaxOpPower-MinOpPower;
    offset=MinOpPower;
    p1=Magnitude*2*p/num*(1:1:ceil(num/2/p));
    p2=-p1+max(p1);
    p_11=[p2,p1];
    p_w=repmat(p_11,1,p);
    f_t_inverse=p_w(1:num)+offset;
    f2=1./f_t_inverse;

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
end

%% considering three lens separately
i1=f1*o1/(o1-f1);
o2=i1-d1;

i2=f2*o2./(o2+f2);
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

if(showFigures == true)
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
end


%% phase correction

if(apply_phase_correction == true)
    phaseNum=100;
    t_phase=t(phaseNum:phaseNum+num-1);
    f_t_inverse_phase=f_t_inverse(phaseNum:phaseNum+num-1);
    ie_phase=ie(phaseNum:phaseNum+num-1);
    theta_phase = theta(phaseNum:phaseNum+num-1);
else
    phaseNum=1;
    t_phase=t(phaseNum:phaseNum+num-1);
    f_t_inverse_phase=f_t_inverse(phaseNum:phaseNum+num-1);
    ie_phase=ie(phaseNum:phaseNum+num-1);
    theta_phase = theta(phaseNum:phaseNum+num-1);
end

if(showFigures == true)
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
end

%%
d=ie_phase;

[d_sort,order]=sort(d);
un_order(order)=1:num;

fov_sort = theta_phase(order);

if(showFigures)
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

end

%% Save parameters
OpticsParams.o1 = o1;
OpticsParams.f1 = f1;
OpticsParams.d1 = d1;
OpticsParams.d2 = d2;
OpticsParams.f3 = f3;
OpticsParams.de = de;

data_folder_path = get_data_folder_path();

filename = sprintf('%s/Params/OpticsParams.mat', data_folder_path);
save(filename,'OpticsParams', '-v7.3');

filename = sprintf('%s/Params/FocusDepth_%03d.mat', data_folder_path, num);
save(filename, 'd', 'd_sort', 'order', 'un_order','fov_sort');
%save(filename, 'd_sort', '-v7.3');

% Description of variables:
% d - distance to depth plane in meters ordered in sequence of when each depth plane is displayed.
% d_sort - sorted distanced to depth planes
% order - index for each entry in d_sort in d
% un_order - 1:num
% fov_sort - FoV for each depth plane following same order of d_sort

