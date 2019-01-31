function [timevec, compartments] = ode_yrys(Net, time_range, I1a_Initial, I2a_Initial, N)
% legend('i1_a','i2_a','s_a','i2_s','s_s','i1_s') 
global alpha mu gamma lambda kappa dt
dt = 0.05;
q = I1a_Initial;
b = I2a_Initial;
infected = randperm(N, I1a_Initial + I2a_Initial); % generate distinct random integers
i1a = zeros(N,1);
i1a(infected(1:I1a_Initial)) = 1;
i2a = zeros(N,1);
i2a(infected(I1a_Initial+1:end)) = 1;
sa = ones(N,1);
sa(infected) = 0;
initial_w = [i1a; i2a; sa; zeros(3*N,1)]; % initial conditions
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