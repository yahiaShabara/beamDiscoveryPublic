% This is the main script that users should run.
%-----------------------------------------------

% Channel configurations
nr = 23;
nt = 23;
n_paths = 3;


% Simulation Flags
add_noise   = 1;
perfect_ADC = 0;
Error_corr  = 0;
pathOnGrid  = 1;

% Parameters
nRuns            = 100;
quantizationBits = 7;
SNR_dB           = -20:5:20;
decodingMethod   = "search";
% This parameter (<noiseDefense>) is relevant for DNN-based decoding only.
% Set <noiseDefense>
% == 'false' to use DNN models trained using noise-free samples
% == 'true'  to use DNN models trained for the specific SNR being simulated
noiseDefense = true;
% The minimum value of the path gain magnitude such that a path is counted
% as a "strong" path.
minPathGain = 0.1; % set minPathGain = 0 to count any path as a "strong" path

% default python command as called in terminal (cmd) window
% pythonX = 'C:\Users\shabara.1\Miniconda3\envs\test\python.exe';
pythonX = 'C:\ProgramData\Miniconda3\envs\dnn\python.exe';

% Set <quantizationBits> to 'Inf' if a perfect ADC is assumed
if perfect_ADC == 1
    quantizationBits = Inf;
end

% This adds the folders "helperFunctions" and "helperScripts" under the
% project's home directory to the MATLAB search path
addpath(strcat(pwd,'/helperFunctions'));
addpath(strcat(pwd,'/helperScripts'));

% Check parameter values

if ( strcmpi( decodingMethod, "dnn") )
    % check python environment
    if ( ~checkPythonEnv(pythonX) ), return, end
    % Skipping the model check for now! This, I beleieve, is taken care of
    % in a later stage in the code execution.
    % TODO: Need to make sure that the check happens before any attemp to
    % use the DNN model.
%     % Check DNN model
%     dnnModelCheck;
%     if ( ~isValidDNNModel ), return; end % Stop simulation if DNN model check failed
end

%---------------
% Run simulation
%---------------
fprintf('<strong>Starting simulation</strong>...\n');
for i_SNR_dB = SNR_dB % iterates through SNR_dB array
    fprintf('<strong>Simulating channels at SNR = %d dB</strong>\n',i_SNR_dB);
    [channel_config, AllHa, AllQa, perfEval] = sc_beamD( nRuns, nr, nt, ...
        n_paths, i_SNR_dB, quantizationBits, add_noise, perfect_ADC, ...
        Error_corr, decodingMethod, noiseDefense, minPathGain, pythonX, ...
        pathOnGrid);
    
    fprintf('\tstoring data ... ');
    storeSimData;
end
fprintf('<strong>Simulation completed</strong>\n');

% This removes the folders "helperFunctions" and "helperScripts" under the
% project's home directory from the MATLAB search path
rmpath(strcat(pwd,'/helperFunctions'));
rmpath(strcat(pwd,'/helperScripts'));