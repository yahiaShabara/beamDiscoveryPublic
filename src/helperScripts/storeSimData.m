% variable to be saved
% varSave = {'AllHa', 'AllQa', 'perfEval', 'channel_config', 'timeStamp'};
varSave = {'perfEval', 'channel_config', 'timeStamp'};
% Generate variable names as string variables (needed for creating
% meaningful file names)
if perfect_ADC == 0
    quantizeLevels_name = num2str(channel_config.quantizeLevels);
elseif perfect_ADC == 1
    quantizeLevels_name = 'Inf';
end
if add_noise == 1
    snr_name = num2str(i_SNR_dB);
elseif add_noise == 0
    snr_name = 'Inf';
end
nr_name             = num2str(nr);
nt_name             = num2str(nt);
nPaths_name         = num2str(n_paths);


% create a "data" folder (if it does not already exist) to store data
dataFolder = strcat(pwd,"/../data");
if (exist(dataFolder, 'dir') ~= 7)
    mkdir(dataFolder);
end

% create a "simulation_results" folder (if it does not already exist) to
% store simulation data
simResultsFolder = strcat(dataFolder,"/simulation_results");
if (exist(simResultsFolder, 'dir') ~= 7)
    mkdir(simResultsFolder);
end

% create a "sourceCoding" folder (if it does not already exist) to
% store simulation data
simResultsFolder = strcat(simResultsFolder,"/sourceCoding");
if (exist(simResultsFolder, 'dir') ~= 7)
    mkdir(simResultsFolder);
end

% create a folder (if it does not already exist) for the specific
% <nr>-by-<nt> channels with a maximum of <n_paths> paths between TX and RX
channelFolder = sprintf("/beamD_%sx%sChannels_%sPaths", ...
    nr_name, nt_name, nPaths_name);
channelFolder = strcat(simResultsFolder, channelFolder);
if (exist(channelFolder, 'dir') ~= 7)
    mkdir(channelFolder);
end

% create a folder (if it does not already exist) for the specific
% number of ADC's quantization levels.
nquantizeFolder = sprintf("/beamD_%sLevels", quantizeLevels_name);
nquantizeFolder = strcat(channelFolder, nquantizeFolder);
if (exist(nquantizeFolder, 'dir') ~= 7)
    mkdir(nquantizeFolder);
end


% create a folder (if it does not already exist) for the specific
% decoding method.
decodingMethodFolder = sprintf("/%s", decodingMethod);
decodingMethodFolder = strcat(nquantizeFolder, decodingMethodFolder);
if (exist(decodingMethodFolder, 'dir') ~= 7)
    mkdir(decodingMethodFolder);
end


if (strcmp(decodingMethod, "dnn"))
    % create a folder (if it does not already exist) for the specific
    % dnn model used (either no noise defense vs. selective noise defense).
    if (noiseDefense)
        dnnModelTypeFolder = "/selectiveDefense";
    else
        dnnModelTypeFolder = "/noDefense";
    end
    decodingMethodFolder = strcat(decodingMethodFolder, dnnModelTypeFolder);
    if (exist(decodingMethodFolder, 'dir') ~= 7)
        mkdir(decodingMethodFolder);
    end
end


% create .mat storage file name
storeFileName = sprintf('/beamD_%sdB_SNR.mat',snr_name);
storeFileName = strcat(decodingMethodFolder, storeFileName);
% Time at which data is saved (for future reference)
timeStamp = datestr(now);

if ( exist(storeFileName, 'file') == 2)
    fprintf("\n==> A file with name <strong>""beamD_%sdB_SNR.mat""</strong> already exists in the default directory.\n",snr_name);
    fprintf("==> <strong>Do you want to overwrite the old simulation data?</strong>\n");
    fprintf("==> Note: If you do not wish to overwrite it, you can still choose another directory in the next step.\n");
    while (1)
        userInput = input("\n==> Enter y(Y) for Yes, and n(N) for No: ", 's');
        if ( strcmpi(userInput, 'y') || strcmpi(userInput, 'n'))
            break;
        else
            fprintf("Invalid input ...");
        end
    end
    if (userInput == 'y' || userInput == 'Y')
        save(storeFileName, varSave{:});
        fprintf("... simulation data has been successfully stored\n");
    else
        while(1)
            fprintf("==> If you still want to save the file in another");
            fprintf(" directory, please enter the complete directory path,\n");
            userInput = input("    otherwise, enter n(N) to skip saving: ", 's');
            if ( strcmpi(userInput,'n') ) % this is case insensitive comparison
                fprintf("    simulation data will not be stored\n");
                break;
            elseif (exist(userInput, 'dir') == 7)
                newFileName = strcat(userInput, ...
                    sprintf("/beamD_%ddB_SNR.mat",SNR_dB));
                save(newFileName, varSave{:});
                fprintf("... simulation data has been successfully stored\n");
                break;
            end
        end
    end
else
    save(storeFileName, varSave{:});
    fprintf("done\n");
end