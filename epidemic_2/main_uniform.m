%% Initialization 
% close all; clear all; clc;
RunTime = 300;
monte_rounds = 30;
dim = [30,30]; 
global I1a_Initial I2a_Initial N dt 
N = dim(1)*dim(2); 
I1a_Initial = 50; %I1_A_Initial 
I2a_Initial = 50; %I2_A_Initial 
dt = 0.05;

global alpha mu gamma lambda kappa
alpha = [0.02, 0.03]; % infect rate 
mu = [0.14, 0.14]; % sleep s 
gamma = [0.5, 0.47]; % rec rate 
lambda = [0.05, 0.32]; % sleep I1 
kappa = [0.04, 0.31]; % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]

r0=3;
Net1 = NetGen_GeoUniform(N,r0,dim,1);
NetUni = NetCmbn({Net1, Net1});
[R0_rnd,R1_rnd,R2_rnd] = calc_R0(NetUni, alpha, mu, gamma, lambda, kappa, N);

%% Monte Dima
x0_uni = Initial_Cond_Gen(N,'Population',[3,5],[I1a_Initial,I2a_Initial]);
Para = Para_active_sleep_SI1I2S(alpha, mu, gamma, lambda, kappa); 
M = Para{1}; 
StopCond={'RunTime', RunTime};

[t, uni_stch] = monte_new(monte_rounds,N,Para,NetUni,x0_uni,StopCond,I1a_Initial,I2a_Initial);
%
% fig = figure(1);
% plot(t, rnd_/N)
%% ODE Yrys
time_range = [0, RunTime]; 
tic
[t_values, uni_ode] = ode_yrys(NetUni, time_range);
toc

% fig = figure(2);
% plot(t_values,compartments/N);
% xlabel('time(t)');
% ylabel('density');
% % legend('i1_a','i2_a','s_a','i2_s','s_s','i1_s')  % Yrys
% legend('Sa','Ss','Ia 1','Is 1','Ia 2','Is 2') % Dima

%% Plot Error
fig = figure(3);

plot(t_values,(uni_ode-uni_stch)/N);
title('Error  abs')
xlabel('time(t)');
ylabel('density');
legend('Sa','Ss','Ia 1','Is 1','Ia 2','Is 2') % Dima

fig = figure(4);
plot(t_values,(uni_ode-uni_stch)./uni_ode);
title('Error  persentage')
xlabel('time(t)');
ylabel('density');
legend('Sa','Ss','Ia 1','Is 1','Ia 2','Is 2') % Dima

