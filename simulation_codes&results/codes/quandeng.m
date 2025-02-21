clc;clear;
FoM1 = zeros(50,1);X1=zeros(50,1);X2=X1;X3=X1;X4=X1;X5=X1;X6=X1;
for j = 1:50
X1(j,1)=j;
end
for i=1:1
    FoM1(i,1) = CA2(X1(i,1), X2(i,1), X3(i,1) ,X4(i,1), X5(i,1), X6(i,1));
end