clear all;
close all;

for value = [64,128,191,255]
    % t = 1:1:255;

    % pwm = zeros(size(t));
    % pwm(1:value) = 1;
    % stairs(pwm);
    % xlim([-10,260])
    % ylim([0,1.5])
    % filename = sprintf('binary_pulse_modulation_images/pwm_%03d.png',);
    % print(filename, '-dsvg');
    
    t_dds = 1:1:8;
    bin_value = dec2bin(value,8);
    dds = zeros(size(t_dds));
    for iter=1:1:8
        dds(iter) = 2^(8-iter)*str2num(bin_value(:,iter:iter));
    end

    bar(dds);
    set(gca,'FontSize',30);
    xlim([0,9])
    ylim([0,140])
    filename = sprintf('binary_pulse_modulation_images/dds_%03d.png', value);
    print(filename, '-dpng');

end
