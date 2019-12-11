function [x_d,y_d,c_d] = ExtractFromPattern(DisplayPattern, current_low, current_high,type)
% This function extract the triple (x_d, y_d, c_d) from a display pattern
% Input: DisplayPattern: 768*1024*280
%        current_low: lower bound of the lens driving current
%        current_high: upper bound of the lens driving current
%        type: what form of driving signal to use
%              0 sinusoidal
%              1 triangular
%
% c_d are generated according to the optotune focal length vs current
% manual and the driving signal type
% The default driving signal type is a sinusoidal signal defined by lower
% and upper bound magnitude, running at 60Hz. The time interval between
% adjacent c_d samples depends on the DLP frame rate.
% According to TI-ALP, the minimum picture time(time interval) is 58 us


[m,n,d] = size(DisplayPattern);


num = 280;



t=0:58:1e6/60*2;
Magnitude=(current_high - current_low)/2;
offset=(current_high + current_low)/2;

if type ==1 
% triangular wave
current_t = Magnitude*sawtooth(2*pi*60/1e6*t, 0.5) + offset;
else
% sinusoidal wave
current_t = Magnitude*cos(2*pi*60/1e6*t) + offset;
end

phaseNum=100;
current_t_phase=current_t(phaseNum:phaseNum+num-1);
current_t_sort = sort(current_t_phase);






linear_index = find(DisplayPattern);
[x_d, y_d, I3] = ind2sub([m,n,d],linear_index);

c_d = current_t_sort(I3)';

end