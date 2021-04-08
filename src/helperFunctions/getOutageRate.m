function outage_rate = getOutageRate(Ha, Qa, SNR_dB)

    [U_Ha,S_Ha,V_Ha] = svd(Ha);
    [U_Qa,S_Qa,V_Qa] = svd(Qa);
    
    lambda_Ha = diag(S_Ha);
    lambda_Qa = diag(S_Qa);
    
    
    lambda_Ha = lambda_Ha(lambda_Ha > 1e-6).';
    lambda_Qa = lambda_Qa(lambda_Qa > 1e-6).';
    
    % SNR = P/N0;
    SNR_linear = 10^(SNR_dB/10);
    P  = SNR_linear;
    N0 = 1;
    
    Pn_Ha = N0./(lambda_Ha.^2);
    Pn_Qa = N0./(lambda_Qa.^2);
    
    P_wf_Ha = waterfill(P,Pn_Ha);
    P_wf_Qa = waterfill(P,Pn_Qa);
    
    C_Ha = log2(1+P_wf_Ha.*(lambda_Ha.^2)/N0);
    C_Qa = log2(1+P_wf_Qa.*(lambda_Qa.^2)/N0);
end