function perfEval = performanceEval(AllHa, AllQa, n_paths, minGain, SNR_dB)

nRuns = size(AllHa,1); % Number of generated channels

MSE_loss                = zeros(nRuns,1); % Placeholder for MSE values
NormalizedMSE     = zeros(nRuns,1); % Placeholder for Normalized MSE values
trueDiscoveredBeams_num = zeros(nRuns,1); % Placeholder for number of true discovered beams
numOfPathsThatCount     = zeros(nRuns,1); % Placeholder for number of channel paths with a
                                          % path gain value greater than equal to 'minGain'

channelCapacity = zeros(nRuns,1);

for runI = 1:nRuns
    Ha = squeeze(AllHa(runI,:,:));
    Qa = squeeze(AllQa(runI,:,:));
    
    % Perfect the sparsity of the channel by only keeping the strongest
    % <n_paths> channel paths
% % %     [~, Qa_ind] = maxk(abs(Qa(:)),n_paths);
% % %     QaTemp = zeros(size(Qa(:)));
% % %     QaTemp(Qa_ind) = Qa(Qa_ind);
% % %     Qa = reshape(QaTemp, size(Qa));
    
    
    try
        C_Ha = channel_capacity(Ha, SNR_dB);
        channelCapacity(runI) = C_Ha;
    catch
        warning("An Error In Channel Capacity Calculation Occured")
        fprintf("wait here ...\n")
        pause;
    end

%     error = Ha - Qa;
%     squaredAbsError = abs(error).^2;
%     MSE_loss(runI) = mean(squaredAbsError(:));
    MSE_loss(runI) = norm(Ha-Qa,'fro')^2;
    NormalizedMSE(runI) = (norm(Ha-Qa,'fro')/norm(Ha,'fro'))^2;

%     [rQ , cQ] = find(abs(real(Qa)) >=quantizeStep/2 | abs(imag(Qa)) >=quantizeStep/2);
%     [rH , cH] = find(abs(real(Ha)) >=quantizeStep/2 | abs(imag(Ha)) >=quantizeStep/2);
%     dimH = [rH cH];
%     dimQ = [rQ cQ];
%     if (size(dimH,1) == size(dimQ,1) ) && (sum(ismember(dimQ,dimH,'rows')) == size(dimH,1) )
%         perfectDirRecov(runI) = 1;
%     else
%         partialDirRecov(runI) = sum(ismember(dimQ,dimH,'rows'));
%         NfalseDirRecov(runI)   = size(dimQ,1) - partialDirRecov(runI);
%     end
%     FroNorm(runI) = norm(Ha-Qa,'fro')/norm(Ha,'fro');
%     realL(runI)   = size(dimH,1);

    %**********************************************************************
    % Find beam indices of the strongest <n_paths> in Ha
    [Ha_maxk, Bi]     = maxk(Ha(:),n_paths, 'ComparisonMethod','abs');
    % Remove paths' indices if their gain is less than <minGain>
    Bi(abs(Ha_maxk) < minGain) = [];
    % maxk only returns the k largest components in the given vector.
    % However, we are intesrested in finding all the channel paths whose
    % gain magnitudes are identical to that of the weakest paths returned
    % by maxk. This is done by the following line of code.
    paths_minReturnedGain = find( Ha(:) == min(abs(Ha_maxk)) );
    paths_minReturnedGain = setdiff(paths_minReturnedGain, Bi);
    Bi = [Bi; paths_minReturnedGain];
    %**********************************************************************
    % Find beam indices of the strongest <n_paths> in Qa
    [Qa_maxk, Bi_hat] = maxk(Qa(:),n_paths, 'ComparisonMethod','abs');
    % Remove paths' indices if their gain is less than <minGain>
    Bi_hat(abs(Qa_maxk) < minGain) = [];
    % Append path indices whose gain magnitudes are identical to the
    % weakest path returned by maxk.
    paths_minReturnedGain = find( Qa(:) == min(abs(Qa_maxk)) );
    paths_minReturnedGain = setdiff(paths_minReturnedGain, Bi_hat);
    Bi_hat = [Bi_hat; paths_minReturnedGain];
    %**********************************************************************
    
    % Find indices of the correctly discovered channel paths
    trueDiscoveredBeams = intersect(Bi, Bi_hat); % The correctly discovered beams
    trueDiscoveredBeams_num(runI) = length(trueDiscoveredBeams); % Number of correctly discovered beams
    numOfPathsThatCount(runI) = length(Bi);
    clear Bi Bi_hat;
end


% outage_flag = channelCapacity < achievableRate;
misdetection_flag = 1 - (trueDiscoveredBeams_num == numOfPathsThatCount);
outage_rate = sum((1-misdetection_flag).*channelCapacity)/nRuns;
perfectCSIRate = sum(channelCapacity)/nRuns;


beamD_gek = zeros(n_paths,1);
for k = 1:n_paths
%     beamD_gek(k) = sum(trueDiscoveredBeams_num >= k) / nRuns;
    beamD_gek(k) = sum(trueDiscoveredBeams_num >= k) / sum(numOfPathsThatCount >= k);
end

% Fill in the performance evaluation structure 'perfEval'
perfEval.MSE_loss  = mean(MSE_loss);
perfEval.NormalizedMSE  = mean(NormalizedMSE);
perfEval.beamD_gek = beamD_gek;
perfEval.outage_rate = outage_rate;
perfEval.perfectCSIRate = perfectCSIRate;