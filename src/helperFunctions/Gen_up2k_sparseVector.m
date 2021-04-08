function Y = Gen_up2k_sparseVector(n,k)

cols = 0;
for i=0:k
    cols = cols + nchoosek(n,i);
end
Y = zeros(n,cols);

pointer = 0;
for i=0:k
    Y_temp = zeros(n,nchoosek(n,i));
    positions = nchoosek(1:n,i);
    for j = 1:nchoosek(n,i)
        Y_temp(positions(j,:),j) = 1;
    end
    Y(:,pointer+1:pointer+nchoosek(n,i)) = Y_temp;
    pointer = pointer + nchoosek(n,i);
end