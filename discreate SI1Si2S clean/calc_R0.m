function [R0,R1,R2] = calc_R0(Net, alpha, mu, gamma, lambda, kappa, N)
adj = Net{1,5}{1,1};
I = eye(N);
muuuu = mu(1)/(mu(1) + mu(2));
R1 = (alpha(1)*adj*muuuu + lambda(1)*I)/(gamma(1)+lambda(2));
R2 = (alpha(2)*adj*muuuu + kappa(1)*I)/(gamma(2)+kappa(2));

R11 = EIG2(R1)
R21 = EIG2(R2)
[V1,D1] = eig(R1);
[V2,D2] = eig(R2);
R1 = max(D1(:));
R2 = max(D2(:));

R0 = max(R1, R2);


