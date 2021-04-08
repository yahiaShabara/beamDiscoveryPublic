% variable to be saved
varSave = {'q', 'ys', 'timeStamp'};
% Generate variable names as string variables (needed for creating
% meaningful file names)

quantizeLevels = 2^quantizationBits + 1;
quantizeLevels_name = num2str(quantizeLevels);
snr_name = num2str(SNR_dB);

% create a "data" folder (if it does not already exist) to store data
dataFolder = strcat(pwd,"/../../data");
if (exist(dataFolder, 'dir') ~= 7)
    mkdir(dataFolder);
end

% create a "training_data" folder (if it does not already exist)
trainDataFolder = strcat(dataFolder,"/training_data");
if (exist(trainDataFolder, 'dir') ~= 7)
    mkdir(trainDataFolder);
end

% create a folder (if it does not already exist) for the specific
% <nr>-by-<nt> channels with a maximum of <n_paths> paths between TX and RX
channelFolder = sprintf("/beamD_%dx%dChannels_%dPaths", nr, nt, n_paths);
channelFolder = strcat(trainDataFolder, channelFolder);
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


% create .mat storage file name
storeFileName = strcat(nquantizeFolder, storeFileName);
% Time at which data is saved (for future reference)
timeStamp = datestr(now);

if ( exist(storeFileName, 'file') == 2)
    [~, fName, ext] = fileparts(storeFileName);
    fprintf("\n==> A file with name <strong>%s%s</strong> already exists in the default directory.\n", fName, ext);
    fprintf("==> <strong>Do you want to overwrite the existing file?</strong>\n");
    fprintf("==> Note: If you do not wish to overwrite it, you can still choose another directory in the next step.\n");
    userInput = getYesNo();
    if (userInput == 'y' || userInput == 'Y')
        save(storeFileName, varSave{:});
        fprintf("... ");
        if (strcmpi(mode,"train")), fprintf("training");
        elseif (strcmpi(mode,"test")), fprintf("testing"); end
        fprintf(" data has been successfully stored\n");
    else
        while(1)
            fprintf("==> If you still want to save the file in another");
            fprintf(" directory, please enter the complete directory path,\n");
            userInput = input("    otherwise, enter n(N) to skip saving: ", 's');
            if ( strcmpi(userInput,'n') ) % this is case insensitive comparison
                fprintf("\tdata will not be stored\n");
                break;
            elseif (exist(userInput, 'dir') == 7)
                newFileName = strcat(userInput, "/", fName, ext);
                save(newFileName, varSave{:});
                fprintf("... ");
                if (strcmpi(mode,"train")), fprintf("training");
                elseif (strcmpi(mode,"test")), fprintf("testing"); end
                fprintf(" data has been successfully stored\n");
                break;
            end
        end
    end
else
    save(storeFileName, varSave{:});
    fprintf("done\n");
end