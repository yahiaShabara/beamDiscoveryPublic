% <AllY> is a 3D matrix that contains all the encoded channel
% (measurements). It has dimensions <nRuns>-by-<mr>-by<mt>.
%--------------------------------------------------------------------------
% <n_paths> is the maximum number of (strong) paths in the channel between
% the TX and RX.
%--------------------------------------------------------------------------
% <G_RX> and <G_TX> are the transmit and receive Generator matrices that
% were originally used for encoding.
%--------------------------------------------------------------------------
% <decodingMethod> should be set to either "search" to indicate the search
% method or "dnn" to indicate Deep Neural Networks method.
%--------------------------------------------------------------------------
function [returnCall, AllQa] = channelDecoder(AllY, n_paths, G_RX, G_TX,...
	W, F, Ur, Ut, decodingMethod, noiseDefense, SNR_dB, ...
	quantizationBits, pythonX)

nRuns = size(AllY,1); % Number of simulated channels
nr = size(G_RX , 2);  % Number of receive antennas
nt = size(G_TX , 2);  % Number of transmit antennas
mr = size(G_RX , 1);  % Number of measurements at RX
mt = size(G_TX , 1);  % Number of measurements at TX

% Search-based decoding
if ( strcmpi(decodingMethod, "search") )
    % do search-method-based decoding here
    
    % Place holder for all the estimated channels
    AllQa = zeros(nRuns, nr, nt);
    
    % Compute PINV_RX and PINV_TX. These will be needed for further
    % processing.
    nCr_RX = nchoosek(1:nr,n_paths);
    PINV_RX = zeros( n_paths , mr , size(nCr_RX,1) );
    for i = 1:size(nCr_RX,1)
        PINV_RX(:,:,i) = pinv(G_RX(:,nCr_RX(i,:)));
    end
    
    nCr_TX = nchoosek(1:nt,n_paths);
    PINV_TX = zeros( n_paths , mt , size(nCr_TX,1) );
    for i = 1:size(nCr_TX,1)
        PINV_TX(:,:,i) = pinv(G_TX(:,nCr_TX(i,:)));
    end
    
    parfor runI = 1:nRuns
        Y  = squeeze(AllY(runI,:,:));
        
        Estimated_Channel_soft_RX = xi(Y,G_RX,nr,n_paths,PINV_RX);
        
        allZeroRxSyndromes = find(ismember(Estimated_Channel_soft_RX,zeros(1,mt),'rows'));
        RX_AoA = setdiff(1:nr,allZeroRxSyndromes);
        
        TX_syndromes = Estimated_Channel_soft_RX.';
        
        Qa = zeros(nr,nt);
        for i = RX_AoA
            temp = xi(TX_syndromes(:,i),G_TX,nt,n_paths,PINV_TX);
            Qa(i,:) = temp.';
        end
        AllQa(runI,:,:) = Qa;
    end
    returnCall = 0;
elseif (strcmpi(decodingMethod, "joint-search"))
	% Sensing Matrix
	SM = kron(F.', W') * kron(conj(Ut), Ur);

	AllQa = zeros(nRuns, nr, nt);

	[M, N] = size(SM);
	nCr = nchoosek(1:N,n_paths);
	PINV = zeros( n_paths , M, size(nCr,1) );
	for i = 1:size(nCr,1)
		PINV(:,:,i) = pinv(SM(:,nCr(i,:)));
	end

	parfor runI = 1:nRuns
		Y = AllY(runI,:);
		y = Y(:);
		qa = xi(y,SM,N,n_paths,PINV);
		Qa = reshape(qa, nr,nt);
		AllQa(runI,:,:) = Qa;
	end
	returnCall = 0;
%**************************************************************************
%**************************************************************************
% DNN-based decoding
elseif ( strcmpi(decodingMethod, "dnn") )
    % do DNN-based decodning here
    
    % Create a temp folder in which data that will be exchanged between
    % MATLAB and python applications will be stored.
    tempFolder = strcat(pwd,"/../temp");
    if (exist(tempFolder, 'dir') ~= 7)
        mkdir(tempFolder);
    end
    
    % Extract Conda Installation Folder
    [parentDir, folderName] = fileparts(pythonX);
    while(~strcmp(folderName,'envs'))
        [parentDir, folderName] = fileparts(parentDir);
    end
    condaFolder = parentDir;
    
    snr_name = num2str(SNR_dB);
    
    % Save the measurements (AllY) in a .mat file under "/temp" directory
    measurements_fname = sprintf('measurements_%dx%d_%dP_%sdB_SNR.mat',nr,nt,n_paths,snr_name);
    measurementsPath = strcat(tempFolder,'/',measurements_fname);
    % This line concatenates all channel measurements side by side.
    AllY4python = reshape(shiftdim(AllY,1),mr,mt*nRuns);
    AllY4pythonReal = real(AllY4python); % real parts of concatened measurements
    AllY4pythonImag = imag(AllY4python); % imaginary parts of concatened measurements
    save ( measurementsPath, 'AllY4pythonReal', 'AllY4pythonImag', ...
        'mr', 'mt', 'nr', 'nt', 'nRuns', 'n_paths', 'SNR_dB');
    
    
    % DNN models' filename
    %dnnModelRX = sprintf('dnnModel_%dto%d_%dP.h5',mr,nr,n_paths);
    %dnnModelRXPath = strcat(pwd,'/../','dnnModels/',dnnModelRX);
    if (~noiseDefense), SNR_dB = Inf; end
    [isRXModel, dnnModelRXPath] = doesDNNModelExist(nr, nt, nr, mr, ...
    n_paths, SNR_dB, quantizationBits);
    
    %dnnModelTX = sprintf('dnnModel_%dto%d_%dP.h5',m2,nt,n_paths);
    %dnnModelTXPath = strcat(pwd,'/../','dnnModels/',dnnModelTX);
    [isTXModel, dnnModelTXPath] = doesDNNModelExist(nr, nt, nt, mt, ...
    n_paths, SNR_dB, quantizationBits);
    
    % If the TX or RX models could not be located, return error code -1)
    if ~(isRXModel && isTXModel)
        AllQa = [];
        returnCall = -1;
        if ~isRXModel
            fprintf("\n\t\tDNN model for RX side not found!\n");
        end
        if ~isTXModel
            fprintf("\t\tDNN model for TX side not found\n!");
        end
        return;
    end
    
    % python command to be used for system call
    pythonCommand = sprintf('%s dnnChannelDecode.py %s %s %s', ...
        pythonX, measurementsPath, dnnModelRXPath, dnnModelTXPath);

    fprintf('running python code for DNN-based decoding ...\n');
    systemCallCMD = sprintf('%s/Scripts/activate dnn && %s', condaFolder, pythonCommand);
    [status, result] = system(systemCallCMD, '-echo');
    if (status ~= 0)
        fprintf("python failed");
        fprintf(result);
        returnCall = -1;
        AllQa = [];
        return;
    end
    
    fprintf('\treturned to MATLAB ... \n');
    measurements_fname = sprintf('decodedMeasurements_%dx%d_%dP_%sdB_SNR.mat',nr,nt,n_paths,snr_name);
    decodedMeasurementsPath = strcat(tempFolder,'/',measurements_fname);
    fprintf('\tloading DNN-based decoded measurements ... ');
    load (decodedMeasurementsPath, 'AllQaFromPythonReal', 'AllQaFromPythonImag');
    AllQaFromPythonReal = shiftdim( reshape(AllQaFromPythonReal , [nr,nt,nRuns]), 2);
    AllQaFromPythonImag = shiftdim( reshape(AllQaFromPythonImag , [nr,nt,nRuns]), 2);
    AllQa = complex(AllQaFromPythonReal, AllQaFromPythonImag);
    
    % delete files used for exchanging variables between MATLAB and python
    delete(measurementsPath, decodedMeasurementsPath);
    
    returnCall = 0;

elseif ( strcmpi(decodingMethod, "joint-dnn") )
    % Do Joint DNN-Based Measurement Decoding here
    
    % Create a temp folder in which data that will be exchanged between
    % MATLAB and python applications will be stored.
    tempFolder = strcat(pwd,"/../temp");
    if (exist(tempFolder, 'dir') ~= 7)
        mkdir(tempFolder);
    end
    
    snr_name = num2str(SNR_dB);
    
    % Save the measurements (AllY) in a .mat file under "/temp" directory
    measurements_fname = sprintf('measurements_%dx%d_%dP_%sdB_SNR.mat',nr,nt,n_paths,snr_name);
    measurementsPath = strcat(tempFolder,'/',measurements_fname);
    % This line concatenates all channel measurements side by side.
    AllY4python = reshape(AllY,nRuns, mr*mt);
    AllY4pythonReal = real(AllY4python); % real parts of concatened measurements
    AllY4pythonImag = imag(AllY4python); % imaginary parts of concatened measurements
    save ( measurementsPath, 'AllY4pythonReal', 'AllY4pythonImag', ...
        'mr', 'mt', 'nr', 'nt', 'nRuns', 'n_paths', 'SNR_dB');
    
    % DNN models' filename
    if (~noiseDefense), SNR_dB = Inf; end
    [isModel, dnnModelPath] = doesJointDNNModelExist(nr, nt, mr, mt, ...
        n_paths, SNR_dB, quantizationBits);
    
    if ~isModel
        fprintf("\t\tDNN model for Joint Decoding NOT Found\n!");
        return
    end
    
    % python command to be used for system call
    pythonCommand = sprintf('%s jointDnnChannelDecode.py %s %s %s', ...
        pythonX, measurementsPath, dnnModelPath);

    fprintf('running python code for Joint-DNN-based decoding ...\n');
    [status, result] = system(pythonCommand, '-echo');
    if (status ~= 0)
        fprintf("python failed");
        fprintf(result);
        returnCall = -1;
        AllQa = [];
        return;
    end
    
    fprintf('\treturned to MATLAB ... \n');
    measurements_fname = sprintf('jointlyDecodedMeasurements_%dx%d_%dP_%sdB_SNR.mat',nr,nt,n_paths,snr_name);
    decodedMeasurementsPath = strcat(tempFolder,'/',measurements_fname);
    fprintf('\tloading Jointly-DNN-based decoded measurements ... ');
    load (decodedMeasurementsPath, 'AllQaFromPythonReal', 'AllQaFromPythonImag');
    
    
    AllQaFromPythonReal = reshape(AllQaFromPythonReal , [nRuns,nr,nt]);
    AllQaFromPythonImag = reshape(AllQaFromPythonImag , [nRuns,nr,nt]);
    AllQa = complex(AllQaFromPythonReal, AllQaFromPythonImag);
    
    % delete files used for exchanging variables between MATLAB and python
    delete(measurementsPath, decodedMeasurementsPath);
    
    returnCall = 0;
    
else
    printf('<strong>ERROR:</strong> Unrecognized decoding method\n');
    AllQa = [];
    returnCall = -1;
end