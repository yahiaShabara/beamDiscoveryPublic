function [q , ys] = genTrainingData_v1(n, n_paths, maxGain, rep, ...
    SNR_dB, quantizationBits, Error_corr, mode)

rng('shuffle') % seed the random number generator based on the current time

if SNR_dB == Inf, add_noise = 0; else, add_noise = 1; end
if quantizationBits == Inf, perfect_ADC = 1; else, perfect_ADC = 0; end

if (strcmpi(mode, "train"))
    sparseVectors = Gen_up2k_sparseVector(n,n_paths);
elseif (strcmpi(mode, "test"))
    sparseVectors = Gen_k_sparseVector(n,n_paths);
else
    fprintf('<strong>Error! unrecognized data generation mode</strong>\n');
    fprintf('\tSet <mode> to either "train" or "test"\n');
    return;
end
q = zeros(n,size(sparseVectors,2) * rep);
count = 0;
for i = 1:size(sparseVectors,2)
    v = sparseVectors(:,i);
    numOnes = sum(v);
    y = v;
    for j = 1:rep
        count = count + 1;
        y(v==1) = rand(numOnes,1)*2*maxGain - maxGain ;
        q(:,count) = y;
        y = v;
    end
end

G  = generatorMatrix(n, n_paths, Error_corr);
ys = G*q;

if add_noise == 1
    noisePower = 10^(-SNR_dB/10);
%     noise = sqrt(noisePower) * ...
%         (1/sqrt(2)) * ( randn(size(ys)) + 1j*randn(size(ys)) );
    noise = sqrt(noisePower) * randn(size(ys));

    ys = ys + noise;
end

if perfect_ADC == 0
    quantizeLevels = 2^quantizationBits+1;
    quantizeStep = 2*maxGain*n_paths / quantizeLevels;
    ys = round(ys/quantizeStep)*quantizeStep;
    ys_real = real(ys);
    ys_imag = imag(ys);
    ys_real(ys_real < -1*((quantizeLevels-1)/2)*quantizeStep) = -1*((quantizeLevels-1)/2)*quantizeStep;
    ys_real(ys_real >    ((quantizeLevels-1)/2)*quantizeStep) =  1*((quantizeLevels-1)/2)*quantizeStep;
    ys_imag(ys_imag < -1*((quantizeLevels-1)/2)*quantizeStep) = -1*((quantizeLevels-1)/2)*quantizeStep;
    ys_imag(ys_imag >    ((quantizeLevels-1)/2)*quantizeStep) =  1*((quantizeLevels-1)/2)*quantizeStep;
    ys = ys_real + 1j * ys_imag;
end
end