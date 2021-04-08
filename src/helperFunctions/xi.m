function [qa] = xi(y_s,PC,n,k,PINV)

nCr = nchoosek(1:n,k);
qa_candidate = zeros(k,size(nCr,1));
qa = zeros(n,size(y_s,2));
y_s_test = zeros(size(y_s,1),size(nCr,1));

for j = 1 : size(y_s,2)
    y_s_j = y_s(:,j);
    for i = 1 : size(nCr,1)
        qa_candidate(:,i) = PINV(:,:,i) * y_s_j;
        y_s_test(:,i) = PC(:,nCr(i,:)) * qa_candidate(:,i);
    end
    y_s_diff = sqrt(sum(abs(y_s_test - y_s_j).^2));
    [~ , d_min_index] = min(y_s_diff);
    qa(nCr(d_min_index,:),j) = qa_candidate(:,d_min_index);
end