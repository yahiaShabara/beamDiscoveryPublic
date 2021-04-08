% <nr> and <nt> are the numbers of antennas at the receiver, and
% trasmitter, respectively.
%
% <Delta_r> and <Delta_t> are the antenna separation distance at the RX and
% TX, respectively, normalized to the carrier wavelength.
%
% <Angles_rx> and <Angles_tx> are the sets of AoAs and AoDs.
%
% <G_RX> and <G_TX> are the generator matrices (of some corresponding
% linear source codes) to be used for encoding the channel at the RX and TX
% sides, respectively.
function [W, F] = combinersAndPrecoders(nr, nt, Delta_r, Delta_t, Angles_rx, Angles_tx, G_RX, G_TX)

% Possible Directions
beamTX = zeros(nt);
for m = 1:nt
    beamTX(:,m) = (1/sqrt(nt)) * exp(-1j*2*pi*(0:nt-1)*Delta_t*cosd(Angles_tx(m))).';
end

beamRX = zeros(nr);
for m = 1:nr
    beamRX(:,m) = (1/sqrt(nr)) * exp(-1j*2*pi*(0:nr-1)*Delta_r*cosd(Angles_rx(m))).';
end


% Matrix of Precoders (nt x m2)
F = zeros(nt,size(G_TX,1));
for m = 1 : size(G_TX,1)
    DirInd = find(G_TX(m,:)==1);
    F(:,m) = sum(beamTX(:,DirInd),2);
end

% Matrix of Combiners (nr x m1)
W = zeros(nr,size(G_RX,1));
for m = 1 : size(G_RX,1)
    DirInd = find(G_RX(m,:)==1);
    W(:,m) = sum(beamRX(:,DirInd),2);
end