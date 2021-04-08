% <AllH> is a 3D matrix that contains all generated channel matrices. It
% has dimesnions <nRuns>-by-<nr>-by-<nt> where <nr> and <nt> are the
% numbers of RX and TX antennas.
%--------------------------------------------------------------------------
% <m1> and <m2> are the numbers of measurements at the RX and TX,
% respecitvely, What this means is that <m1> is the total number of
% rx-combiners, and <m2> is the total number of tx-precoders.
%--------------------------------------------------------------------------
% W = [w_0, w_1, ... , w_{m1-1}] AND F = [f_0, f_1, ... , f_{m2-1}]
% are the matrices of rx-combiners and tx-precoders, respectively.
%--------------------------------------------------------------------------
% <add_noise> set this number to an integer number 1 to add channel noise
% to the obtained measurements.
%--------------------------------------------------------------------------
% <noisePower> is the power of the added noise signal (added to the
% measurements)
%--------------------------------------------------------------------------
% <perfect_ADC> set this number to an integer number 1 to simulate a
% perfect, infinite resoluion ADC. Otherwise, set it to the ineteger 0 to
% quantize the measurements.
%--------------------------------------------------------------------------
% <quantizeLevels> Number of ADC's quantization levels.
%--------------------------------------------------------------------------
% <quantizeStep> The step size of the used ADC. This value is adjusted such
% that the maximum expected signal power can be represented using by the
% highest quantization levels of the ADC. The values between 0 and max
% signal power are thus represented using a linear mapping between the 0th
% quantize level and the highest quantize level.
%--------------------------------------------------------------------------
function AllY = channelEncoder4Training(AllH, m1, m2, W, F, add_noise, ...
    noisePower, perfect_ADC, quantizeLevels, quantizeStep)

nRuns = size(AllH,1); % Total number of generated channels.
AllY = zeros(nRuns, m1, m2);
parfor runI = 1:nRuns
    H  = squeeze(AllH (runI,:,:));
    Y  = zeros(m1,m2);
    
    for jj = 1 : m2
        for i = 1 : m1
            Y(i,jj) = W(:,i)' * H * F(:,jj);
        end
    end
    if add_noise == 1
%         noise = sqrt(noisePower) * ...
%             (1/sqrt(2)) * ( randn(m1,m2) + 1j*randn(m1,m2) );
        noise = sqrt(noisePower) * randn(m1,m2);
        Y = Y + noise;
    end
    
    if perfect_ADC == 0
        Y = round(Y/quantizeStep)*quantizeStep;
        Y_real = real(Y);
        Y_imag = imag(Y);
        Y_real(Y_real < -1*((quantizeLevels-1)/2)*quantizeStep) = -1*((quantizeLevels-1)/2)*quantizeStep;
        Y_real(Y_real >    ((quantizeLevels-1)/2)*quantizeStep) =  1*((quantizeLevels-1)/2)*quantizeStep;
        Y_imag(Y_imag < -1*((quantizeLevels-1)/2)*quantizeStep) = -1*((quantizeLevels-1)/2)*quantizeStep;
        Y_imag(Y_imag >    ((quantizeLevels-1)/2)*quantizeStep) =  1*((quantizeLevels-1)/2)*quantizeStep;
        Y = Y_real + 1j * Y_imag;
    end
    AllY(runI,:,:) = Y;
end