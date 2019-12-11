%% Display Simulation
% For a given triple(x_d, y_d, c_d), where x_d, y_d is the pixel location
% on diplay chip, c_d implicates the wanted depth.(By driving focus tunable 
% lens with different current). 
% Note that c_d are discrete from a set of lens states.
% This simulation calculates (x, y, z), where (x, y, z) denotes the
% displayed pixel in world space.
% The world space: x and y as horizontal and vertical axes respectively, z 
% as viewing direction perpendicular to the vitual images planes. And
% origin at a predefined eye location

%%
clearAll = true;

if(clearAll)
clear all;
else
clear clearAll;
end

%% manage data path
data_path_folder = get_data_folder_path();
addpath('library');
%% load necessary data

filename = sprintf('%s/Params/OpticsParams.mat', data_path_folder);
load(filename);
%% Generate input triple (x_d, y_d, c_d)
% (x_d, y_d) are pixel locations on 768*1024 display
%  c_d is the driving current

%define variable
m = 768; %height
n = 1024; %width
d = 280; %depth

current_low = 87.5;
current_high = 137.5;


% generate (x_d, y_d, c_d)
% A display pattern is a 768*1024*280 matrix in which non-zero values are
% displayed
% (x_d, y_d, c_d) are extracted from the display pattern

Display_Pattern = zeros([m n d]);

SampleNum = 10*8*5;
SampleIndex = randperm(m*n*d,SampleNum);
Display_Pattern(SampleIndex) = 1;

% providing display pattern, lower and upper current bound and driving wave
% type get (x_d, y_d, c_d)
[x_d,y_d,c_d] = ExtractFromPattern(Display_Pattern,current_low,current_high,0);

% compute the corresponding (x,y,z) from (x_d, y_d, c_d)




