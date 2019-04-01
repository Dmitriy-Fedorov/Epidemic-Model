function [timevec, compartments] = ode_yrys_2(Net, time_range, x0, N)
% modification that uses GEMF_sim initial parameters
% legend('i1_a','i2_a','s_a','i2_s','s_s','i1_s') 
global alpha mu gamma lambda kappa dt
dt = 0.05;
i1a = x0 == 3;
i2a = x0 == 5;
sa = x0 == 1;
% disp(sum([i1a, i2a, sa]))

initial_w = [i1a'; i2a'; sa'; zeros(3*N,1)]; % initial conditions
clear i1a i2a sa
adj = Net{5}{1};

[t_values, sol_values] = ode45(@(t,w) diff_eq_heterogen(t,w,mu,lambda,alpha,gamma,kappa, adj, N), time_range, initial_w);

compartments = zeros(length(t_values), 6);
for i=1:6
    start = (i-1)*N + 1;
    compartments(:,i) = sum(sol_values(:,start:N*i),2);
end

% standartise length
timevec = 0:dt:time_range(2);
ts = timeseries(compartments,t_values);
compartments = resample(ts, timevec);
compartments = compartments.data;
% legend('i1_a','i2_a','s_a','i2_s','s_s','i1_s')  Yrys
% legend('Sa';'Ss';'Ia 1';'Is 1';'Ia 2';'Is 2') Dima
compartments = compartments(:,[3,5,1,6,2,4])';

end