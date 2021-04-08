function C =  channel_capacity(H, SNR_dB)

    lambda = svd(H);
    lambda = lambda(lambda > 1e-6).';
    
    % SNR = P/N0;
    SNR_linear = 10^(SNR_dB/10);
    P  = SNR_linear;
    N0 = 1;
    Pn = N0./(lambda.^2);
    
    P_wf = waterfill(P,Pn);
    
    C = sum(log2(1+P_wf.*(lambda.^2)/N0));
end