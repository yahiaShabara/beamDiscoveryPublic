function e = e_gen(k,n,L,Delta)
e = zeros(n,1);
for i = 1:n
    e(i) = (1/sqrt(n)) * exp(-1j*2*pi*(i-1)*Delta*k/L);
end
end