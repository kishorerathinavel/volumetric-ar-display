clear all;
close all;

%% Generating graphs to go into the paper

o1=0.07; % Guess
f1=0.068; % From Email
d1=0.03; % Guess

f3=0.06; % Measured to be 0.053
d2=0.12; % measure
de=0.07; % measure

num=280; % num of sample depths along z direction(depth direction)
MinOpPower=12; % min optical power of focus tunable lens(in diopters)
MaxOpPower=16; % max optical power of focus tunable lens(in diopters)
t=1:num;
p=1;


t=0:0.058:1e3/60;

%% Triangular wave

delt_t=1e3/60/2;
tan1=(MinOpPower-MaxOpPower)/delt_t;
y1=tan1*t+MaxOpPower;

tan2=(MaxOpPower-MinOpPower)/delt_t;
y2=tan2*t+2*MinOpPower-MaxOpPower;

index=max(find(t<=delt_t));
f_t_inverse=[y1(1:index),y2(index+1:end)];
f2=1./f_t_inverse;

figure; plot(t, f2, '+');
title('f2 vs t');

figure; plot(t, o1, '+');
title ('o1 vs t');

i1=f1*o1/(o1-f1);
figure; plot(t, i1, '+');
title ('i1 vs t');
m1 = i1/o1;
figure; plot(t, m1, '+');
title ('m1 vs t');

o2=i1-d1;
figure; plot(t, o2, '+');
title('o2 vs t');

i2=f2*o2./(o2+f2);
figure; plot(t, i2, '+');
title('i2 vs t');
m2 = i2/o2;
figure; plot(t, m2, '+');
title ('m2 vs t');

%i2=f2*o2./(o2-f2);
o3=d2-i2;
figure; plot(t, o3, '+');
title('o3 vs t');

i3=f3*o3./(o3-f3);
figure; plot(t, i3, '+');
title('i3 vs t');
m3 = i3./o3;
figure; plot(t, m3, '+');
title ('m3 vs t');

m = m1*(m2.*m3);
figure; plot(t, m, '+');
title ('m vs t');

O_1 = 0.01778; % meters. O_1 = 0.7 inches
I_e = m*O_1;

ie=-i3+de;

linewidth = 3;

return;

filename = sprintf('./graphs/triangular_lens_power_vs_time.svg');
custom_plot_save(t, f_t_inverse, filename);

% figure('units','normalized','outerposition', [0 0 0.99 0.98], 'visible', 'on');
% plot(t,f_t_inverse, '+', 'LineWidth', linewidth);
% set(gcf, 'PaperPositionMode', 'auto');
% set(gca, 'FontSize', 30);
% print(filename, '-dsvg')


% figure('units','normalized','outerposition', [0 0 0.99 0.98], 'visible', 'on');
% plot(t,1./ie, '+', 'LineWidth', linewidth);
% set(gcf, 'PaperPositionMode', 'auto');
% set(gca, 'FontSize', 30);
% print(filename, '-dsvg')

filename = sprintf('./graphs/triangular_virtual_image_dioptres_vs_time.svg');
custom_plot_save(t, 1./ie, filename);


% figure('units','normalized','outerposition', [0 0 0.99 0.98], 'visible', 'on');
% plot(t,ie', 'LineWidth', 5);
% set(gcf, 'PaperPositionMode', 'auto');
% set(gca, 'FontSize', 30);
% print(filename, '-dsvg')

filename = sprintf('./graphs/triangular_virtual_image_distance_vs_time.svg');
custom_plot_save(t, ie, filename);


Magnitude=(MaxOpPower-MinOpPower)/2;
offset=(MaxOpPower+MinOpPower)/2;

f_t_inverse=Magnitude*sin(t*2*pi/(1e3/60))+offset;
f2=1./f_t_inverse;



i1=f1*o1/(o1-f1);

o2=i1-d1;


i2=f2*o2./(o2+f2);

%i2=f2*o2./(o2-f2);
o3=d2-i2;


i3=f3*o3./(o3-f3);

ie=-i3+de;

% figure('units','normalized','outerposition', [0 0 0.99 0.98], 'visible', 'on');
% plot(t,f_t_inverse, 'LineWidth', 5);
% set(gcf, 'PaperPositionMode', 'auto');
% set(gca, 'FontSize', 30);
% print(filename, '-dsvg')

filename = sprintf('./graphs/sinusoidal_ens_power_vs_time.svg');
custom_plot_save(t, f_t_inverse, filename);


% figure('units','normalized','outerposition', [0 0 0.99 0.98], 'visible', 'on');
% plot(t,1./ie, 'LineWidth', 5);
% set(gcf, 'PaperPositionMode', 'auto');
% set(gca, 'FontSize', 30);
% print(filename, '-dsvg')

filename = sprintf('./graphs/sinusoidal_virtual_image_dioptres_vs_time.svg');
custom_plot_save(t, 1./ie, filename);


% figure('units','normalized','outerposition', [0 0 0.99 0.98], 'visible', 'on');
% plot(t,ie', 'LineWidth', 5);
% set(gcf, 'PaperPositionMode', 'auto');
% set(gca, 'FontSize', 30);
% print(filename, '-dsvg')

filename = sprintf('./graphs/sinusoidal_virtual_image_distance_vs_time.svg');
custom_plot_save(t, ie, filename);



return;


% figure('units','normalized','outerposition', [0 0 0.48 0.64], 'visible', 'on');
% plot(t,theta);
% set(gcf, 'PaperPositionMode', 'auto');
% filename = sprintf('./graphs/fov_vs_time.png');
% saveas(gcf, filename, 'png');

%% Searching for the right set of parameters
% d1+o1=0.09 % measure

printgraphs = false;
ie_all = [];
fov_all = [];
parameters = [];
index = 0;
o2_all = [];
diff_o2_f1 = [];
i2_all = [];


% f1=0.07; % From Email
% d1=0.03; % Guess
% f3=0.04; % Guess
d2=0.12; % measure
de=0.07; % measure
f3 = 0.053; %measured

for f3 = 0.055:0.001:0.06
    for o1=0.04:0.01:0.07
        for f1=(o1 - 0.03):0.001:o1
            
            if(o1 <= f1 || o1 >= 2*f1)
                continue;
            end
            for d1 = 0.01:0.01:0.035
                
                
                % o1 has to lie between f1 and 2*f1
                
                
                
                
                % d2=0.12; % measure
                % de=0.07; % measure
                
                % o1=0.04; % Guess
                % f1=0.03; % From Email
                % d1=0.05; % Guess
                % f3=0.09; % Guess
                
                %
                num=280; % num of sample depths along z direction(depth direction)
                MinOpPower=12; % min optical power of focus tunable lens(in diopters)
                MaxOpPower=16; % max optical power of focus tunable lens(in diopters)
                t=1:num;
                p=1;
                
                % finding depthlist using triangular driving signal
                t=0:58:1e6/60;
                delt_t=1e6/60/2;
                tan1=(MinOpPower-MaxOpPower)/delt_t;
                y1=tan1*t+MaxOpPower;
                
                tan2=(MaxOpPower-MinOpPower)/delt_t;
                y2=tan2*t+2*MinOpPower-MaxOpPower;
                
                index=max(find(t<=delt_t));
                f_t_inverse=[y1(1:index),y2(index+1:end)];
                f2=1./f_t_inverse;
                
                % considering three lens separately
                i1=f1*o1/(o1-f1);
                o2=i1-d1;
                
                i2=f2*o2./(o2+f2);
                %i2=f2*o2./(o2-f2);
                
                o2_all = [o2_all; o2];
                diff_o2_f1 = [diff_o2_f1 (o2 + f1)];
                i2_all = [i2_all i2];
                o3=d2-i2;
                
                % o3 has to lie within f3
                
                
                %                 if(abs(o3) > abs(f3))
                %                     break;
                %                 end
                
                
                i3=f3*o3./(o3-f3);
                ie=-i3+de;
                
                % Field of View
                
                O_1 = 0.01778; % meters. O_1 = 0.7 inches
                I_e = - (ie/o3) * (i2/o2) * (i1/o1) * O_1;
                theta = 2*rad2deg(atan((I_e/2)./ie));
                
                ie_all = [ie_all; ie];
                fov_all = [fov_all; theta];
                
                %
                parameters = [parameters; [index o1 f1 d1 f3]];
                
                if(printgraphs)
                    figure('units','normalized','outerposition', [0 0 0.48 0.64], 'visible', 'on');
                    subplot(2,2,1)
                    plot(t,f_t_inverse,'r*'); hold on;
                    title('Focus-tunable Lens Driving signal');
                    xlabel('time/s');
                    ylabel('Optical power/diopter');
                    
                    
                    subplot(2,2,2)
                    plot(t,1./ie,'r*');
                    title('Focal plane depth changes in diopter');
                    xlabel('time/s');
                    ylabel('Focal plane depth/diopter');
                    
                    subplot(2,2,3)
                    plot(t,ie,'r*');
                    title('Focal plane depth changes in meter');
                    xlabel('time/s');
                    ylabel('Focal plane depth/m');
                    
                    subplot(2,2,4)
                    plot(t,theta,'r*');
                    title('Field of view');
                    xlabel('time/s');
                    ylabel('Field of view');
                    
                    set(gcf, 'PaperPositionMode', 'auto');
                    filename = sprintf('./graphs/%1.2f_%1.2f_%1.2f_%1.2f.png', f3, o1, f1, d1);
                    
                    saveas(gcf, filename, 'png');
                    %close(gcf);
                end
            end
        end
    end
end


ie_subset = ie_all;
ie_subset(ie_subset < 0) = 0;
ie_subset(ie_subset > 4) = 4;
figure; imagesc(ie_subset); colorbar;
figure; plot(i2_all);

mean_fov = mean(abs(fov_all), 2);

