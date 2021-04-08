% This function generates angles of departure (AoD) and angles of arrival
% (AoA) directions at the TX and RX sides, respectively. These are the
% angles defined in the DFT matrices Ut and Ur.
% <nr> and <nt> are the numbers of receive and transmit antennas,
% respectively.
%
% <Lr> and <Lt> are the lengths of the receive and transmit antennas
% normalized to the carrier wavelength.
function [Angles_tx, Angles_rx] = generateAngles(nr, nt, Lr, Lt)

% Set of discrete TX angles
if mod(nt,2) == 0
    Angles_tx = [radtodeg(acos((-nt/2+1:-1)./Lt)) radtodeg(acos((0:nt/2)./Lt))];
elseif mod(nt,2) == 1
    Angles_tx = [radtodeg(acos((-(nt-1)/2:-1)./Lt)) radtodeg(acos((0:(nt-1)/2)./Lt))];
end

% Set of discrete RX angles
if mod(nr,2) == 0
    Angles_rx = [radtodeg(acos((-nr/2+1:-1)./Lr)) radtodeg(acos((0:nr/2)./Lr))];
elseif mod(nr,2) == 1
    Angles_rx = [radtodeg(acos((-(nr-1)/2:-1)./Lr)) radtodeg(acos((0:(nr-1)/2)./Lr))];
end