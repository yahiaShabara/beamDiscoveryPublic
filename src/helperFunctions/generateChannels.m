% <nr> and <nt> are the numbers of receive and transmit antennas,
% respectively.
%
% <n_paths> is the number of paths between the transmitter and receiver.
%
% <a_b> is of size (<n_paths> x <nRuns>) baseband path gains.
%
% <Delta_r> and <Delta_t> are the antenna separation distance at the RX and
% TX, respectively, normalized to the carrier wavelength.
%
% <Ur> and <Ut> are the discrete Fourier Transform matrices for the
% receiver and the transmitter sides respectively. They are mainly used to
% obtain the angular channels representation from the original channel
% matrix representation.
%
% <pathOnGrid> set to 1 to force the angular directions of the channel
% paths to fall on the "grid" created by the angular directions of the DFT
% matrices, which are used to obtain the angular channel Ha from the
% regular channel H
%--------------------------------------------------------------------------
function [AllH, AllHa] = generateChannels(nr, nt, n_paths, nRuns, a_b, ...
    Delta_r, Delta_t, Ur, Ut, Angles_rx, Angles_tx, pathOnGrid)

% This pre-allocates the AllH and AllHa matrices to enahnce performance.    
% AllH is a 3D matrix that contains all the <nRuns> generated channels. To
% access a specific channel, e.g. the 4th generated channel use
% (AllH(4,:,:)) along with squeeze to reduce the dimension of the output to
% just <nr> x <nt>
AllH  = zeros(nRuns,nr,nt);
AllHa = zeros(nRuns,nr,nt);


for runI = 1:nRuns
    
    %         phi_t_i = degtorad(Angles_tx( randsample(nt,n_paths) ));
    %         phi_r_i = degtorad(Angles_rx( randsample(nr,n_paths) ));
    
    
    if (pathOnGrid == 1)
        phi_t_i = deg2rad(Angles_tx( datasample((1:nt).', n_paths, 'Replace', false) ));
        phi_r_i = deg2rad(Angles_rx( datasample((1:nr).', n_paths, 'Replace', false) ));
    else
        phi_t_i = rand*pi;
        phi_r_i = rand*pi;
    end
    
    Omega_t = cos(phi_t_i);
    Omega_r = cos(phi_r_i);
    
    et = zeros(nt,n_paths);
    er = zeros(nr,n_paths);
    
    for i = 1:n_paths
        for k = 1:nt
            et(k,i) = (1/sqrt(nt)) * exp(-1j*2*pi*(k-1)*Delta_t*Omega_t(i));
        end
    end
    for i = 1:n_paths
        for k = 1:nr
            er(k,i) = (1/sqrt(nr)) * exp(-1j*2*pi*(k-1)*Delta_r*Omega_r(i));
        end
    end
    
    H = zeros(nr,nt);
    for path_i = 1:n_paths
        H = H + a_b(path_i,runI) * er(:,path_i) * et(:,path_i)' ;
    end
    
    AllH(runI,:,:)  = H;
    AllHa(runI,:,:) = Ur'*H*Ut;
end