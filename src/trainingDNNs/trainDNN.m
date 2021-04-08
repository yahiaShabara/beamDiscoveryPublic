% Deep Neural Network (DNN) Model Training
% <nr> is the number of receive  antennas
% <nt> is the number of transmit antennas
% <n_paths> is the number of channel paths (non-zero components)
% <SNR_dB> is the SNR value in dB. Set this to 'Inf' for noise-free
% measurements
% <quantizationBits> is the ADC resolution in bits. Set this to 'Inf' for
% infinite ADC resolutionn.
% <Error_corr> is either set to '1' or '0' to enable or disable the error
% correction capcability of channel measurements.
function trainDNN(nr, nt, n_paths, SNR_dB, quantizationBits, Error_corr, ...
    pythonX)

addpath(strcat(pwd,'/../helperFunctions'));
addpath(strcat(pwd,'/../helperScripts'));

% -------------------------------------------------------------------------
% Part I: Generate training data if not present already
% -------------------------------------------------------------------------

% Each possible k-sparse vector is repeated <rep> times.
% For each one, random non-zero components are generated.
% There exists (n choose 0 + n choose 1 + ... + n choose k) different
% support vectors.
rep = 300;

maxGain = sqrt(nr*nt);
mr = size( generatorMatrix(nr, n_paths, Error_corr) ,1);
mt = size( generatorMatrix(nt, n_paths, Error_corr) ,1);

mode = "train";

[trainingDataExist, ~] = doesTrainingDataExist(nr, nt, n_paths, ...
    mr, mt, SNR_dB, quantizationBits);

if ( (nr ~= nt) && (trainingDataExist.rx == 0 || trainingDataExist.tx == 0))
    if (trainingDataExist.rx == 0)
        % generate file name of rx training data
        fname_rx = sprintf('/trainData_v1_%dto%d_%dP_%ddB.mat',...
            mr, nr, n_paths, SNR_dB);
        % generate rx training data
        [qr , ys_r] = genTrainingData(nr, n_paths, maxGain, rep, ...
            SNR_dB, quantizationBits, Error_corr, mode);
        
        % store rx training data
        q  = qr; %#ok<NASGU>
        ys = ys_r; %#ok<NASGU>
        clear qr ys_r;
        storeFileName = fname_rx; %#ok<NASGU>
        fprintf('\tstoring RX training data ... ');
        storeTrainingData
    else
        fprintf('\tsuccessfully located RX training data\n');
    end
    if (trainingDataExist.tx == 0)
        % generate file name of tx training data
        fname_tx = sprintf('/trainData_v1_%dto%d_%dP_%ddB.mat',...
            mt, nt, n_paths, SNR_dB);
        % generate tx training data
        [qt , ys_t] = genTrainingData(nt, n_paths, maxGain, rep, ...
            SNR_dB, quantizationBits, Error_corr, mode);
        
        % store tx training data
        q  = qt; %#ok<NASGU>
        ys = ys_t; %#ok<NASGU>
        clear qt ys_t;
        storeFileName = fname_tx; %#ok<NASGU>
        fprintf('\tstoring TX training data ... ');
        storeTrainingData;
    else
        fprintf('\tsuccessfully located TX training data\n');
    end
elseif ( nr == nt && trainingDataExist.rx == 0 )
    m = mr;
    n = nr;
    trainingData_fname = sprintf('/trainData_v1_%dto%d_%dP_%ddB.mat',...
        m, n, n_paths, SNR_dB);
    
    [q , ys] = genTrainingData(n, n_paths, maxGain, rep, ...
        SNR_dB, quantizationBits, Error_corr, mode); %#ok<ASGLU>

	storeFileName = trainingData_fname; %#ok<NASGU>
    fprintf('\tstoring training data ... ');
    storeTrainingData;
else
    fprintf('successfully located training data\n');
end


% -------------------------------------------------------------------------
% Part II: Generate test data if not present already
% -------------------------------------------------------------------------

mode = "test";
[testDataExist, ~] = doesTestingDataExist(nr, nt, n_paths, ...
    mr, mt, SNR_dB, quantizationBits);

if ( (nr ~= nt) && (testDataExist.rx == 0 || testDataExist.tx == 0))
    if (testDataExist.rx == 0)
        % generate file name of rx test data
        test_fname_rx = sprintf('/testData_v1_%dto%d_%dP_%ddB.mat',...
            mr, nr, n_paths, SNR_dB);
        % generate rx training data
        [qr , ys_r] = genTrainingData(nr, n_paths, maxGain, rep, ...
            SNR_dB, quantizationBits, Error_corr, mode);
        
        % store rx test data
        q  = qr; %#ok<NASGU>
        ys = ys_r; %#ok<NASGU>
        clear qr ys_r;
        storeFileName = test_fname_rx; %#ok<NASGU>
        fprintf('\tstoring RX test data ... ');
        storeTrainingData;
    else
        fprintf('\tsuccessfully located RX test data\n');
    end
    if (testDataExist.tx == 0)
        % generate file name of tx test data
        test_fname_tx = sprintf('/testData_v1_%dto%d_%dP_%ddB.mat',...
            mt, nt, n_paths, SNR_dB);
        % generate tx training data
        [qt , ys_t] = genTrainingData(nt, n_paths, maxGain, rep, ...
            SNR_dB, quantizationBits, Error_corr, mode);
        
        % store tx test data
        q  = qt; %#ok<NASGU>
        ys = ys_t; %#ok<NASGU>
        clear qt ys_t;
        storeFileName = test_fname_tx; %#ok<NASGU>
        fprintf('\tstoring TX test data ... ');
        storeTrainingData;
    else
        fprintf('\tsuccessfully located TX test data\n');
    end
elseif ( nr == nt && testDataExist.rx == 0 )
    m = mr;
    n = nr;
    testData_fname = sprintf('/testData_v1_%dto%d_%dP_%ddB.mat',...
        m, n, n_paths, SNR_dB);
    
    [q , ys] = genTrainingData(n, n_paths, maxGain, rep, ...
        SNR_dB, quantizationBits, Error_corr, mode); %#ok<ASGLU>

	storeFileName = testData_fname; %#ok<NASGU>
    fprintf('\tstoring test data ... ');
    storeTrainingData;
else
    fprintf('successfully located test data\n');
end

% -------------------------------------------------------------------------
% Part III: Train DNN model
% -------------------------------------------------------------------------

% Extract Conda Installation Folder
[parentDir, folderName] = fileparts(pythonX);
while(~strcmp(folderName,'envs'))
    [parentDir, folderName] = fileparts(parentDir);
end
condaFolder = parentDir;

if (~exist('pythonX', 'var')), pythonX = 'python'; end
if ( ~checkPythonEnv(pythonX) ), return, end
modelTrainingScript = 'trainAndEvaluate.py';

% find absolute path to training data
[~, trainingAbsPath] = doesTrainingDataExist(nr, nt, n_paths, mr, mt, ...
    SNR_dB, quantizationBits);

% find absolute path to testing data
[~, testingAbsPath] = doesTestingDataExist(nr, nt, n_paths, mr, mt, ...
    SNR_dB, quantizationBits);

if (nr ~= nt) % will train separate models
    % i) RX model training.
    % check if a DNN model already exists
    [isModel_rx, modelAbsPath_rx] = doesDNNModelExist(nr, nt, nr, mr, ...
        n_paths, SNR_dB, quantizationBits);
    
    skipRXModelTraining = false;
    if (isModel_rx)
        fprintf('A DNN model for the provided configuration already exists.\n');
        fprintf('Do you wish to <strong>overwrite</strong> the existing Model?\n');
        userInput = getYesNo();
        if (strcmpi(userInput, 'n')), skipRXModelTraining = true; end
    end
    if (~skipRXModelTraining)
        fprintf('training model for decoding RX measurements ... \n');
        systemCallCMD = sprintf('%s %s %s %s %s', pythonX, ...
            modelTrainingScript, trainingAbsPath.rx, testingAbsPath.rx, ...
            modelAbsPath_rx);
        systemCallCMD = sprintf('%s/Scripts/activate test && %s', condaFolder, systemCallCMD);
        [status, ~] = system( systemCallCMD, '-echo' );
        if (status ~= 0)
            fprintf('<strong>DNN model training failed</strong>\n');
        else
            fprintf('DNN training was successful\n');
        end
    end
    % ii) TX model training.
    % check if a DNN model already exists
    [isModel_tx, modelAbsPath_tx] = doesDNNModelExist(nr, nt, nt, mt, ...
        n_paths, SNR_dB, quantizationBits);
    
    if (isModel_tx)
        fprintf('A DNN model for the provided configuration already exists.\n');
        fprintf('Do you wish to <strong>overwrite</strong> the existing Model?\n');
        userInput = getYesNo();
        if (strcmpi(userInput, 'n'))
            fprintf('terminating program...\n');
            return;
        end
    end
    fprintf('training model for decoding TX measurements ... \n');
    systemCallCMD = sprintf('%s %s %s %s %s', pythonX, ...
        modelTrainingScript, trainingAbsPath.tx, testingAbsPath.tx, ...
        modelAbsPath_tx);
    systemCallCMD = sprintf('%s/Scripts/activate test && %s', condaFolder, systemCallCMD);
    [status, ~] = system( systemCallCMD, '-echo' );
    if (status ~= 0)
        fprintf('<strong>DNN model training failed</strong>\n');
    else
        fprintf('DNN training was successful\n');
    end
else % will train one model
    % Create DNN model name/path and check if a dnn Model already exists
    [isModel, modelAbsPath] = doesDNNModelExist(nr, nt, nr, mr, ...
        n_paths, SNR_dB, quantizationBits);
    if (isModel)
        fprintf('A DNN model for the provided configuration already exists.\n');
        fprintf('Do you wish to <strong>overwrite</strong> the existing Model?\n');
        userInput = getYesNo();
        if (strcmpi(userInput, 'n'))
            fprintf('terminating program...\n');
            return;
        end
    end
    systemCallCMD = sprintf('%s %s %s %s %s', pythonX, ...
        modelTrainingScript, trainingAbsPath.rx, testingAbsPath.rx, ...
        modelAbsPath);
    systemCallCMD = sprintf('%s/Scripts/activate test && %s', condaFolder, systemCallCMD);
    [status, ~] = system( systemCallCMD, '-echo' );
    if (status ~= 0)
        fprintf('<strong>training failed</strong>\n');
    end
end

%id = 'MATLAB:rmpath:DirNotFound';
%warning('off',id);
rmpath(strcat(pwd,'/../helperFunctions'));
rmpath(strcat(pwd,'/../helperScripts'));
%warning('on',id);
end