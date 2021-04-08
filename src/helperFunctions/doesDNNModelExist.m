% <n> is the number of antennas at TX or RX (length of sparse vector)
% <m> is the number of measurements
% <n_paths> is the (maximum) number of channel paths
% <SNR_dB> is the SNR level at the transmitter in dB
% <quantizationBits> is the resolution of the employed ADC

function [isModel, modelAbsPath] = doesDNNModelExist(nr, nt, n, m, ...
    n_paths, SNR_dB, quantizationBits)


quantizeLevels = 2^quantizationBits + 1;
% Create DNN model name and path

[currentDir, ~, ~] = fileparts(which('doesDNNModelExist.m'));
modelName = sprintf('dnnModel_%dto%d_%dP_%ddB.h5',m,n,n_paths,SNR_dB);
modelDir = strcat(currentDir, "/../../dnnModels", ...
    sprintf("/beamD_%dx%dChannels_%dPaths", nr, nt, n_paths), ...
    sprintf("/beamD_%dLevels", quantizeLevels));

dummy = what(modelDir);
if isempty(dummy), mkdir(modelDir); else, modelDir = dummy.path; end
modelAbsPath = fullfile(modelDir, modelName);
if (exist(modelAbsPath,'file')==2), isModel=true; else, isModel=false; end
end