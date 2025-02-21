function [distance,m]=index(x)
t=-((log(0.001)*x));
matri = zeros((2*ceil(t))+1,(2*ceil(t))+1);
[m,n] = size(matri);
for i = 1:m
    for j = 1:n
matri(i,j) = sqrt((i-(m+1)/2)^2+(j-(n+1)/2)^2);
    end
end
distance = exp(-matri./x);
distance((m+1)/2,(m+1)/2) = 0;
end

