% Check python interpreter if "dnn" decoding method is being used
function isEnvValid = checkPythonEnv(pythonX)
fprintf('checking python environment ... \n\trunning python test script ... ');

% Extract Conda Installation Folder
[parentDir, folderName] = fileparts(pythonX);
while(~strcmp(folderName,'envs'))
    [parentDir, folderName] = fileparts(parentDir);
end
condaFolder = parentDir;

while (1)
    % locating '/test' directory
    relativeLocs = ["../test", "../../test"];
    testExist = false;
    for loc = relativeLocs
        dummy = what(loc);
        if (~isempty(dummy)) && ...
                (exist(fullfile(dummy.path,'pythonTest.py'),'file') == 2)
            testExist = true;
            break;
        end
    end

    if (~testExist)
        fprintf('\n<strong>Could not find test script</strong>.\n');
        fprintf('Simulation will continue but may run into problems later.\n');
        isEnvValid = true;
        break;
    end
    testDir = dummy.path;
    clear dummy;
    systemCallCMD  = sprintf('%s %s/pythonTest.py', pythonX, testDir);
    systemCallCMD = sprintf('%s/Scripts/activate dnn && %s', condaFolder, systemCallCMD);
    [status, ~] =  system( systemCallCMD, '-echo' );
    if (status ~= 0)
        fprintf('<strong>test failed</strong>.\n\t');
        %fprintf(result);
        fprintf('\tDo you wish to provide a path to python executable in another environment?\n\t');
        userInput = [];
        while (1)
            userInput = input('Enter y(Y) for Yes and n(N) for No: ','s');
            if ( strcmpi(userInput,'y') || strcmpi(userInput,'n') )
                break
            end
        end
        if ( strcmpi(userInput,'n') )
            isEnvValid = false;
            fprintf('\tterminating simulation ...\n');
            return;
        else
            fprintf('\t');
            pythonX = input ('Enter path to python executable: ','s');
            fprintf('\trunning python test script ... ');
        end
    else
        fprintf('<strong>test was successful.</strong>\n');
        isEnvValid = true;
        break;
    end
end
end