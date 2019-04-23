%% adding path
addpath(genpath('D:\whp17\volumetricfocalstack\Focus plane generation'));

%% GPU encoding
RGBImg = imread('trial_10_rgb.png');
load('trial_10_DepthMap.mat');