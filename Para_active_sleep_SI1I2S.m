function Para=Para_active_sleep_SI1I2S(alpha, mu, gamma, lambda, kappa)
% imput params are in this form: 
% [1 or active, 2 or sleep]
%%%% Compartments %%%%
% 1-S_a
% 2-S_s
% 3-I1_a
% 4-I1_s
% 5-I2_a
% 6-I2_s
%%%%%%%%%
% alpha - infect rate
% mu - sleep S
% gamma - recovery rate
% lambda - sleep I1
% kappa - sleep I2

M=6; q=[3,5]; L=length(q);

A_d=zeros(M); 
A_d(2,1) = mu(1);       % S_s  -> S_a
A_d(1,2) = mu(2);       % S_a  -> S_s
A_d(3,1) = gamma(1);    % I1_a -> S_a
A_d(5,1) = gamma(2);    % I2_a -> S_a
A_d(4,3) = lambda(1);   % I1_s -> I1_a
A_d(3,4) = lambda(2);   % I1_a -> I1_s
A_d(6,5) = kappa(1);        % I2_s -> I2_a
A_d(5,6) = kappa(2);        % I2_a -> I2_s

A_b=zeros(M,M,L); 
A_b(1,3,1)=alpha(1); 
A_b(1,5,2)=alpha(2); 


Para={M,q,L,A_d,A_b};