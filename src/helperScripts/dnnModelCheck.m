% Check that a corresponding DNN model exists
isValidDNNModel = true;
firstLoop = 1;
m1 = size( generatorMatrix(nr, n_paths ,Error_corr) ,1);
m2 = size( generatorMatrix(nt, n_paths ,Error_corr) ,1);
if ( strcmpi( decodingMethod, "dnn") )
    fprintf('locating DNN model ... ');
    % DNN models' filename
    dnnModelRX = sprintf('dnnModel_%dto%d_%dP.h5',m1,nr,n_paths);
    dnnModelRXPath = strcat(pwd,'/../','dnnModels/',dnnModelRX);
    
    dnnModelTX = sprintf('dnnModel_%dto%d_%dP.h5',m2,nt,n_paths);
    dnnModelTXPath = strcat(pwd,'/../','dnnModels/',dnnModelTX);
    
    sameModel = strcmp( dnnModelTX, dnnModelRX);
    if ( sameModel )
        dnnModelPath = dnnModelTXPath;
        while (1)
            if (exist( dnnModelPath, 'file') ~= 2)
                firstLoop = 0;
                [ ~ , dnnModelName, dnnModelExt] = fileparts( dnnModelPath );
                fprintf('\n\t<strong>Cannot find DNN model "%s%s".</strong> ', dnnModelName, dnnModelExt);
                userInput = [];
                fprintf('Do you wish to provide another model?\n');
                while(1)
                    userInput = input('    Enter y(Y) for Yes and n(N) for No: ','s');
                    if ( strcmpi(userInput,'y') || strcmpi(userInput,'n') )
                        break;
                    end
                end
                if ( strcmpi(userInput,'n') )
                    fprintf('\t<strong>terminating simulation ...</strong>\n');
                    isValidDNNModel = false;
                    return;
                else
                    dnnModel_user = input ('    Enter path to DNN model: ','s');
                    % copy user input file to standard location
                    if ( isfile(dnnModel_user) )
                        copyfile(dnnModel_user, dnnModelPath);
                    end
                end
            else
                if (firstLoop == 1)
                    fprintf('model successfuly located\n');
                else
                    fprintf('\t<strong>model successfuly located</strong>\n');
                end
                break;
            end
        end
    else
        while (1)
            if (exist( dnnModelTXPath, 'file') ~= 2)
                firstLoop = 0;
                [ ~ , dnnModelName, dnnModelExt] = fileparts( dnnModelTXPath );
                fprintf('\n\t<strong>Cannot find DNN model "%s%s".</strong> ', dnnModelName, dnnModelExt);
                userInput = [];
                fprintf('Do you wish to provide another model?\n');
                while(1)
                    userInput = input('    Enter y(Y) for Yes and n(N) for No: ','s');
                    if ( strcmpi(userInput,'y') || strcmpi(userInput,'n') )
                        break;
                    end
                end
                if ( strcmpi(userInput,'n') )
                    fprintf('\t<strong>terminating simulation ...</strong>\n');
                    isValidDNNModel = false;
                    return;
                else
                    dnnModelTX_user = input ('    Enter path to DNN model: ','s');
                    % copy user input file to standard location
                    if ( isfile(dnnModelTX_user) )
                        copyfile(dnnModelTX_user, dnnModelTXPath);
                    end
                end
            else
                if (firstLoop == 1)
                    fprintf(' TX model successfuly located\n');
                else
                    fprintf('\t<strong> TX model successfuly located</strong>\n');
                end
                break;
            end
        end
        while (1)
            if (exist( dnnModelRXPath, 'file') ~= 2)
                [ ~ , dnnModelName, dnnModelExt] = fileparts( dnnModelRXPath );
                fprintf('\n\t<strong>Cannot find DNN model "%s%s".</strong> ', dnnModelName, dnnModelExt);
                userInput = [];
                fprintf('Do you wish to provide another model?\n');
                while(1)
                    userInput = input('    Enter y(Y) for Yes and n(N) for No: ','s');
                    if ( strcmpi(userInput,'y') || strcmpi(userInput,'n') )
                        break
                    end
                end
                if ( strcmpi(userInput,'n') )
                    fprintf('\t<strong>terminating simulation ...</strong>\n');
                    isValidDNNModel = false;
                    return;
                else
                    dnnModelRX_user = input ('    Enter path to DNN model: ','s');
                    % copy user input file to standard location
                    if ( isfile(dnnModelRX_user) )
                        copyfile(dnnModelRX_user, dnnModelRXPath);
                    end
                end
            else
                if (firstLoop == 1)
                    fprintf('... RX model successfuly located\n');
                else
                    fprintf('\t<strong>RX model successfuly located</strong>\n');
                end
                break;
            end
        end
    end
end
clear firstLoop;