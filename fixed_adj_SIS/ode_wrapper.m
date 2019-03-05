function [t, sol_values] = ode_wrapper(alpha, mu, gamma, lambda, kappa,...
    RunTime,N,I1_a_initial_uni,I2_a_initial_uni,r0)

lambda_a = lambda(1);
lambda_s = lambda(2);
kappa_a = kappa(1);
kappa_s = kappa(2);
alpha1 = alpha(1);
alpha2 = alpha(2);
mu_a = mu(1);
mu_s = mu(2);
gamma1 = gamma(1);
gamma2 = gamma(2);
sigma = 1;

time_range = [0, RunTime]; 

S_a_initial=N-I1_a_initial_uni-I2_a_initial_uni;
I2_s_initial=0;
S_s_initial=0; 
I1_s_initial=0; 
initial_w=[I1_a_initial_uni;I1_a_initial_uni;S_a_initial;I2_s_initial;S_s_initial;I1_s_initial]; 

tic;
[t_values, sol_values] = ode45(@(t,w) ...
    diff_eq(t,w,sigma, r0, N, lambda_a, lambda_s,...
    kappa_a, kappa_s, alpha1, alpha2,mu_a, mu_s, gamma1, gamma2),...
    time_range, initial_w); 
toc;

% legend('I1_a','I2_a','S_a', 'I2_s', 'S_s', 'I1_s') 
sol_values = sol_values(:,[3,5,1,6,2,4])';
ts = timeseries(sol_values, t_values');
dt = 0.05;
tsout = resample(ts,0:dt:RunTime);
t = tsout.time;
sol_values = tsout.data;
sol_values = reshape(sol_values,6,RunTime/dt+1);
end