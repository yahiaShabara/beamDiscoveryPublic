% sc_beamD() is the engine for the simulation.
% sc_beamD stands for "Source-Coding-based Beam Discovery".
%--------------------------------------------------------------------------
% <nRuns> is the number of simulated channel instances. The performance
% results is avergaed across this number.
%--------------------------------------------------------------------------
% <nr> and <nt> are the numbers of receive and transmit antennas,
% respectively.
%--------------------------------------------------------------------------
% <n_paths> is the maximum number of channel paths between TX and RX.
%--------------------------------------------------------------------------
% <SNR_dB> is the SNR value in dB.
%--------------------------------------------------------------------------
% <quantizationBits> sets the resolution of the ADCs.
%--------------------------------------------------------------------------
% <Error_corr> set this number to an integer number 1 to enable the Error
% Correction Capability - i.e., it adds redundant measurements to increase
% the reliability against errors.
%--------------------------------------------------------------------------
% <add_noise> set this number to an integer number 1 to add channel noise
% to the obtained measurements.
%--------------------------------------------------------------------------
% <perfect_ADC> set this number to an integer number 1 to simulate a
% perfect, infinite resoluion ADC. Otherwise, set it to the ineteger 0 to
% quantize the measurements.
%--------------------------------------------------------------------------
% <decodingMethod> should be set to either "search" to indicate the search
% method or "dnn" to indicate Deep Neural Networks method.
%--------------------------------------------------------------------------
% <pathOnGrid> set to 1 to force the angular directions of the channel
% paths to fall on the "grid" created by the angular directions of the DFT
% matrices, which are used to obtain the angular channel Ha from the
% regular channel H
%--------------------------------------------------------------------------
function [channel_config, AllHa, AllQa, perfEval] = sc_beamD(...
    nRuns, nr, nt, n_paths, SNR_dB, quantizationBits, add_noise, ...
    perfect_ADC, Error_corr, decodingMethod, noiseDefense, minGain, ...
    pythonX, pathOnGrid)

% channel configurations
channel_config.nr               = nr;
channel_config.nt               = nt;
channel_config.n_paths          = n_paths;
channel_config.SNR_dB           = SNR_dB;
channel_config.Delta_r          = 0.5;        % Normalized Rx antennas Separation
channel_config.Delta_t          = 0.5;
channel_config.Lr               = nr * channel_config.Delta_r;  % Normalized length of Rx antennas.
channel_config.Lt               = nt * channel_config.Delta_t;  % Normalized length of Rx antennas.
channel_config.Lambda_c         = 3*10^-3;
channel_config.PL_dB            = 130;           % Path loss in dB
channel_config.max_PathGain     = 1;
channel_config.antenna_gain     = sqrt(nr*nt);
channel_config.antennaGain_dB   = 20*log10(channel_config.antenna_gain);
channel_config.a_min            = 0.1;
channel_config.a_max            = 1;
channel_config.a                = channel_config.max_PathGain * ( (channel_config.a_max-channel_config.a_min) * rand(n_paths,nRuns) + channel_config.a_min );           % Gain along path i
channel_config.quantizationBits = quantizationBits;
channel_config.quantizeLevels   = 2^quantizationBits+1;
channel_config.quantizeStep     = channel_config.max_PathGain * channel_config.antenna_gain * n_paths * 2 / channel_config.quantizeLevels;
channel_config.d                = normrnd(100,10,n_paths,nRuns);
channel_config.a_b              = (channel_config.a).* sqrt(nr*nt).* exp(-1j * 2*pi*(channel_config.d)./channel_config.Lambda_c);

% Part I - Channel Establishment
% The channel has a maximum of <n_paths> possible paths
% Each path has a random TX and RX directions
% Path gains are random


% Average received SNR
rx_SNRdB = SNR_dB + channel_config.antennaGain_dB ...
    + 20*log10( (channel_config.a_min + channel_config.a_max)/2 );
rx_SNR_linear = 10^(rx_SNRdB/10);
noisePower = (((channel_config.a_min + channel_config.a_max)/2)^2) * ...
    (channel_config.antenna_gain^2) / rx_SNR_linear;


[channel_config.Angles_tx, channel_config.Angles_rx] = generateAngles(...
    nr, nt, channel_config.Lr, channel_config.Lt);

[channel_config.Ut, channel_config.Ur] = DFT_matrices(...
    nr, nt, channel_config.Delta_r, channel_config.Delta_t,...
    channel_config.Lr, channel_config.Lt);

fprintf('\tgenerating channels ... ');
[AllH, AllHa] = generateChannels(nr, nt, n_paths, nRuns, ...
    channel_config.a_b, channel_config.Delta_r, channel_config.Delta_t, ...
    channel_config.Ur, channel_config.Ut, ...
    channel_config.Angles_rx, channel_config.Angles_tx, pathOnGrid);
fprintf('done\n');

% Part II - Channel Estimation
% In this part, we assume a receiver structure that consists of 1 RF chain
% with nr antennas , each of which is connected to a phase-shifter (PS) and
% a variable gain amplifier (VGA). The antenna + PS + VGA terminals are
% combined using an adder and fed to an RF chain. Each RF chain has two
% ADCs for both I and Q channels.

% Generator Matrices (Encoders of corresponding Source Codes)
G_RX = generatorMatrix(nr,n_paths,Error_corr);
G_TX = generatorMatrix(nt,n_paths,Error_corr);

m1 = size(G_RX,1); % Number of RX measurements
m2 = size(G_TX,1); % Number of TX measurements


% This generates the rx-combiners w_i for all i = 0,1,...,m1-1 and tx
% precoders f_j for all j = 0,1,...,m2-1 and places them in
% W = [w_0, w_1, ... , w_{m1-1}] AND F = [f_0, f_1, ... , f_{m2-1}]
[W, F] = combinersAndPrecoders(nr, nt,...
    channel_config.Delta_r, channel_config.Delta_t, ...
    channel_config.Angles_rx, channel_config.Angles_tx, G_RX, G_TX);


% Encode the channels. In other words, obtain measurements.
fprintf('\tencoding channels ... ');
AllY  = channelEncoder(AllH, m1, m2, W, F, add_noise, noisePower, ...
    perfect_ADC, channel_config.quantizeLevels, channel_config.quantizeStep);
fprintf('done\n');

% Decode the measurements. In other words, find the channels' estimates.
fprintf('\tdecoding channels ... ');
[rc, AllQa] = channelDecoder(AllY, n_paths, G_RX, G_TX, W, F, ...
    channel_config.Ur, channel_config.Ut, decodingMethod, ...
    noiseDefense, SNR_dB, quantizationBits, pythonX);
if (rc < 0)
    fprintf('ERROR decoding channels.\n')
    return;
elseif (rc == 0)
    if ( strcmpi( decodingMethod, "dnn" ) )
        fprintf("done\n\tmeasurements successfully decoded\n");
    elseif (strcmpi( decodingMethod, "search") || ...
			strcmpi( decodingMethod, "joint-search") )
        fprintf('done\n');
    end
end

% Performance Evaluation
fprintf('\tEvaluating performance ... ');
perfEval = performanceEval(AllHa, AllQa, n_paths, minGain, SNR_dB);
fprintf('done\n');