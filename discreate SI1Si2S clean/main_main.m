%% Initialization 
close all; clear all; clc;
RunTime = 1000;
monte_rounds = 15;
dim = [10,10]; 
global I1a_Initial I2a_Initial N dt 
N = dim(1)*dim(2);
I1a_Initial = 10; %I1_A_Initial 
I2a_Initial = 10; %I2_A_Initial 
dt = 0.05;
filename = '100 nodes_position.csv';

global alpha mu gamma lambda kappa
% R00
% alpha = [0.05, 0.06]; % infect rate 
% mu = [0.02, 0.02]; % sleep s 
% gamma = [0.2, 0.3]; % rec rate 
% lambda = [0.02, 0.08]; % sleep I1 
% kappa = [0.04, 0.09]; % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]
% R10
alpha = [0.35, 0.05]; % infect rate 
mu = [0.02, 0.02]; % sleep s 
gamma = [0.02, 0.2]; % rec rate 
lambda = [0.04, 0.05]; % sleep I1 
kappa = [0.02, 0.1]; % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]

r0=1.5;
Net2 = NetLoad_Geo(filename, N, r0);
NetRnd = NetCmbn({Net2, Net2});
[R0_rnd,R1_rnd,R2_rnd] = calc_R0(NetRnd, alpha, mu, gamma, lambda, kappa, N);
[R1_rnd;R2_rnd]

% renderNetwork(Net2, 1, '')
%% Monte Dima
x0_rnd = Initial_Cond_Gen(N,'Population',[3,5],[I1a_Initial,I2a_Initial]);
Para = Para_active_sleep_SI1I2S(alpha, mu, gamma, lambda, kappa); 
M = Para{1}; 
StopCond={'RunTime', RunTime};

[t, rnd_stch] = monte_new(monte_rounds,N,Para,NetRnd,x0_rnd,StopCond,I1a_Initial,I2a_Initial);

fig = figure(1);
plot(t, rnd_stch(3:end,:)/N)
title('100 nodes RGG')
legend('Ia 1','Is 1','Ia 2','Is 2') % Dima 'Sa','Ss',
grid minor
csvwrite('rnd_stch.csv', rnd_stch')
%% ODE Yrys
time_range = [0, RunTime]; 
tic
[t_values, rnd_ode] = ode_yrys(NetRnd, time_range);
toc

fig = figure(2);
plot(t_values,rnd_ode(3:end,:)/N);
xlabel('time(t)');
ylabel('density');
% % legend('i1_a','i2_a','s_a','i2_s','s_s','i1_s')  % Yrys
legend('Ia 1','Is 1','Ia 2','Is 2') % Dima 'Sa','Ss',
grid minor
csvwrite('rnd_ode.csv', rnd_ode')
%% Plot Error
% fig = figure(3);
% 
% plot(t_values,(rnd_ode-rnd_stch)/N);
% title('Error  abs')
% xlabel('time(t)');
% ylabel('density');
% legend('Sa','Ss','Ia 1','Is 1','Ia 2','Is 2') % Dima
% 
% fig = figure(4);
% plot(t_values,(rnd_ode-rnd_stch)./rnd_ode);
% title('Error  persentage')
% xlabel('time(t)');
% ylabel('density');
% legend('Sa','Ss','Ia 1','Is 1','Ia 2','Is 2') % Dima
%%
% s1 = sprintf('R1_%g R2_%g ODE.xlsx', R1_rnd, R2_rnd); 
% s2 = sprintf('R1_%g R2_%g STCH.xlsx', R1_rnd, R2_rnd); 
% xlswrite(s1,rnd_ode)
% xlswrite(s2,rnd_stch)
