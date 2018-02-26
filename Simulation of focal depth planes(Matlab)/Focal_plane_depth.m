% This code simulates the focal plane depth changes as a fucntion of
% driving signal. optical set up diagram is shown inoverleaf appendix.
% Simulation assume that virtual images are generated by both lens.

% basic setting parameters of the set up in meters.
%(For now,these parameters are just assumptions)
% chaning these parameters may cause problem by violating the virtual image
% assumption.

o=0.08; % obejct distance from DMD to focus-tunable lens
l=0.15; % distance between focus-tunable lens and eyepiece
f=0.60; % focal length of eyepiece
num=154; % num of sample depths along z direction(depth direction)
MinOpPower=4; % min optical power of focus tunable lens(in diopters)
MaxOpPower=20 % max optical power of focus tunable lens(in diopters)
p=1; % num of cycles shown when using periodical driving signal
t=1:1:num;

%% linear driving singal
% f_t_inverse is the optical power of  focus-tunable lens as a function of
% time.(In diopters)
f_t_inverse=linspace(MinOpPower,MaxOpPower,num); 

%% sinusoidal driving signal
Magnitude=(MaxOpPower-MinOpPower)/2;
offset=(MaxOpPower+MinOpPower)/2

f_t_inverse=Magnitude*sin(t*2*p*pi/num)+offset;

%% triangular driving signal
Magnitude=MaxOpPower-MinOpPower;
offset=MinOpPower;
p1=Magnitude*2*p/num*(1:1:ceil(num/2/p));
p2=-p1+max(p1);
p_11=[p1,p2];
p_w=repmat(p_11,1,p);
f_t_inverse=p_w(1:num)+offset;

%%
I1=(l*o-f*o)*f_t_inverse+f-l-o;
I2=-f*l*o*f_t_inverse+f*o+l*f;

D=I1./I2; % depth of focal planes in diopter(derivation seen overleaf)

subplot(3,1,1)
plot(t,f_t_inverse,'r*');
title('Focus-tunable Lens Driving signal');
xlabel('time/s');
ylabel('Optical power/diopter');


subplot(3,1,2)
plot(t,D,'r*');
title('Focal plane depth changes in diopter');
xlabel('time/s');
ylabel('Focal plane depth/diopter');

subplot(3,1,3)
plot(t,1./D,'r*');
title('Focal plane depth changes in meter');
xlabel('time/s');
ylabel('Focal plane depth/m');



