clear all; close all; clc

addpath(genpath('data'), genpath('filters'), genpath('utility'))

%% load RT from Pori 
load('s3_r4_o_DecayFitNet_est.mat')
RT = double(T); 
clear A L norm T % remove uneccesary variables

%% set up some parameters 
fs = 48000; 
fBands = [63, 125, 250, 500, 1000, 2000, 4000, 8000];
fBands = [63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000];

delays = [997., 1153., 1327., 1559., 1801., 2099.];

%% use shelf filter and GEQ 
method = 'shelf';
wc = 300; 
% get the frequency response of the attenuation filter
[HSHE, w, target_mag, h, SOS] = twoFilters(RT, delays(1), fs, method, 300);


