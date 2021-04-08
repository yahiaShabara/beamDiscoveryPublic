function Y = Gen_kSparseVector(n,k)

Y = zeros(n,nchoosek(n,k));

positions = nchoosek(1:n,k);
for j = 1:nchoosek(n,k)
    Y(positions(j,:),j) = 1;
end
end