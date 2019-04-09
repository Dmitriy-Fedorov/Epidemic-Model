close all;clear all; clc;
time_range = [0, 500]; 
dim = [10,10]; 
N = dim(1)*dim(2); 
q=10; %I1_A_Initial 
b=10; %I2_A_Initial 
initial_w= zeros(6*N,1); 
i1a = [ones(q,1); zeros(N-q,1)];
i2a = [zeros(q,1); ones(b,1); zeros(N-q-b,1)];
sa = [zeros(q+b,1); ones(N-q-b,1)];
initial_w=[i1a; i2a; sa; zeros(3*N,1)]; 
clear i1a i2a sa
r0=3; 
alpha = [0.02, 0.03]; % infect rate 
mu = [0.14, 0.14]; % sleep s 
gamma = [0.5, 0.47]; % rec rate 
l = [0.05, 0.32]; % sleep I1 
k = [0.04, 0.31]; 
Net=NetGen_Geo(N,r0,dim);
adj=Net{5}{1}; 
[t_values, sol_values] = ode45(@(t,w) diff_eq(t,w,mu,l,alpha,gamma,k, adj, N), time_range, initial_w); 
% plot(t_values,sol_values); 
% xlabel('time(t)'); 
% ylabel('density'); 
%legend('S(t)','I(t)','R(t)') 

compartments = zeros(length(t_values), 6);
for i=1:6
    start = (i-1)*100 + 1;
    compartments(:,i) = sum(sol_values(:,start:100*i),2);
end

% i1a = sum(sol_values(:,1:100),2);
fig = figure(2);
plot(t_values,compartments); 
xlabel('time(t)'); 
ylabel('density'); 
legend('i1_a','i2_a','s_a','i2_s','s_s','i1_s') 

