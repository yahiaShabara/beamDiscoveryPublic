% checks whether DNN testing data for the specific configuration is
% available
% <nr>: number of rx antennas
% <nt>: number of tx antennas
% <n_paths>: number of channel paths
% <mr>: Number of RX measurements
% <mt>: Number of TX measurements
% <SNR_dB>: Signal to Noise ratio in dB
% <quantizationBits>: ADC resolution
% The return value is a structure with members:
% <result.rx> = 0 if RX training data does NOT exist, and non-zero otherwise
% <result.tx> = 0 if TX training data does NOT exist, and non-zero otherwise
function [result, testingAbsPath] = doesTestingDataExist(nr, nt, ...
    n_paths, mr, mt, SNR_dB, quantizationBits)

quantizeLevels = 2^quantizationBits + 1;
quantizeLevels_name = num2str(quantizeLevels);

fname_tx = sprintf('testData_v1_%dto%d_%dP_%ddB.mat',mt,nt,n_paths,SNR_dB);
fname_rx = sprintf('testData_v1_%dto%d_%dP_%ddB.mat',mr,nr,n_paths,SNR_dB);

dirPath = strcat(pwd,"/../../data/training_data", ...
    sprintf("/beamD_%dx%dChannels_%dPaths", nr, nt, n_paths), ...
    sprintf("/beamD_%sLevels", quantizeLevels_name));

result.rx = exist(strcat(dirPath, '/', fname_rx), 'file');
result.tx = exist(strcat(dirPath, '/', fname_tx), 'file');

dummy = what(dirPath);
if (~isempty(dummy))
    absDir = dummy.path;
    testingAbsPath.rx = fullfile(absDir, fname_rx);
    testingAbsPath.tx = fullfile(absDir, fname_tx);
else
    testingAbsPath.rx = [];
    testingAbsPath.tx = [];
end
end