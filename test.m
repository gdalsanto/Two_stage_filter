clear all; close all; clc

addpath(genpath('data'), genpath('filters'), genpath('utility'))

fs = 48000; 
irLen = 3*fs; 



%% set up some parameters 

fBands = [63, 125, 250, 500, 1000, 2000, 4000, 8000];
% fBands = [63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000];

delays = [997., 1153., 1327., 1559., 1801., 2099.];


%% load RT from Pori 

load('s3_r4_o_DecayFitNet_est.mat')
est.T = double(T);  est.A = double(A); est.N = double(N); est.norm = double(norm); 
est = transposeAllFields(est);
[est.L, est.A, est.N] = decayFitNet2InitialLevel(est.T, est.A, est.N, est.norm, fs, irLen, fBands);
RT = double(est.T); 

N = length(delays);
%% construct filters 
% attenuation filter
method = 'shelf';
wc = 300; 
% get the frequency response of the attenuation filter
SOS = zeros(N, 1, length(fBands)+3, 6);
for i = 1:N
    [HSHE, w, target_mag, h, iSOS, pads] = twoFilters(RT, delays(i), fs, method, wc);
    SOS(i, 1, :, :) = iSOS(1:end-1, :);
end

zAbsortion = zSOS(SOS,'isDiagonal',true);

% tone control filter 
targetLevel = mag2db(est.L([1 1:end end]));  % dB
targetLevel = targetLevel - [5 0 0 0 0 0 0 0 5 30];
equalizationSOS = designGEQ(targetLevel);

%% construct FDN 

A = fdnMatrixGallery(N, 'orthogonal');
B = ones(N,1);
C = ones(1,N);
C = zSOS(permute(equalizationSOS,[3 4 1 2]) .*  C);
ir = dss2impz(irLen, delays, A, B, C, zeros(1,1), 'absorptionFilters', zAbsortion);
audiowrite('test.wav', ir/max(abs(ir)), fs)