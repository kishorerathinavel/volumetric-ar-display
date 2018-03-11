%%
% d1+o1=0.09
o1=0.06;
f1=0.058;
d1=0.03;
d2=0.12; % measure
f3=0.061;
de=0.07; % measure
num=280; % num of sample depths along z direction(depth direction)
MinOpPower=12; % min optical power of focus tunable lens(in diopters)
MaxOpPower=16; % max optical power of focus tunable lens(in diopters)
t=1:num;
p=1;
%% linear driving singal
f_t_inverse=linspace(MinOpPower,MaxOpPower,num); 
f2=1./f_t_inverse;


%% sinusoidal driving signal
Magnitude=(MaxOpPower-MinOpPower)/2;
offset=(MaxOpPower+MinOpPower)/2;

f_t_inverse=Magnitude*sin(t*2*p*pi/num)+offset;
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
t=0:58:1e6/60;
delt_t=1e6/60/2;
tan1=(MinOpPower-MaxOpPower)/delt_t;
y1=tan1*t+MaxOpPower;

tan2=(MaxOpPower-MinOpPower)/delt_t;
y2=tan2*t+2*MinOpPower-MaxOpPower;

index=max(find(t<=delt_t));
f_t_inverse=[y1(1:index),y2(index+1:end)];
f2=1./f_t_inverse;
%% considering three lens separately
i1=f1*o1/(o1-f1);
o2=i1-d1;


i2=f2*o2./(o2+f2);
o3=d2-i2;


i3=f3*o3./(o3-f3);
ie=-i3+de;



%%
figure;
subplot(3,1,1)
plot(t,f_t_inverse,'r*'); hold on;
title('Focus-tunable Lens Driving signal');
xlabel('time/s');
ylabel('Optical power/diopter');


subplot(3,1,2)
plot(t,1./ie,'r*');
title('Focal plane depth changes in diopter');
xlabel('time/s');
ylabel('Focal plane depth/diopter');

subplot(3,1,3)
plot(t,ie,'r*');
title('Focal plane depth changes in meter');
xlabel('time/s');
ylabel('Focal plane depth/m');
%%
d=ie(1:280);
[d_sort,order]=sort(d);
un_order(order)=1:280;

[f_sort,forder]=sort(f_t_inverse(1:280));
%%
save FocusDepth.mat d d_sort order un_order;