function [Ut, Ur] = DFT_matrices(nr, nt, Delta_r, Delta_t, Lr, Lt)

Ut = zeros(nt,nt);
Ur = zeros(nr,nr);

if mod(nt,2)==0
    c = 0;
    for k = [(-nt/2+1:-1) 0:nt/2]
        c = c + 1;
        Ut(:,c) = e_gen(k,nt,Lt,Delta_t);
    end
elseif mod(nt,2)==1
    c = 0;
    for k = [(-(nt-1)/2:-1) 0:(nt-1)/2]
        c = c + 1;
        Ut(:,c) = e_gen(k,nt,Lt,Delta_t);
    end
end

if mod(nr,2)==0
    c = 0;
    for k = [(-nr/2+1:-1) 0:nr/2]
        c = c + 1;
        Ur(:,c) = e_gen(k,nr,Lr,Delta_r);
    end
elseif mod(nr,2)==1
    c = 0;
    for k = [(-(nr-1)/2:-1) 0:(nr-1)/2]
        c = c + 1;
        Ur(:,c) = e_gen(k,nr,Lr,Delta_r);
    end
end