clear; clc; close all;
seed = 17;
rng(seed)

global RunTime dt
global alpha mu gamma lambda kappa N
% Initial Setup
r = 1.5;
monte_rounds = 20;
dim = [30,30];
N = dim(1)*dim(2);
RunTime = 300;
dt = 0.05;

Net1 = NetGen_GeoUniform(N,r,dim,1);
Net2 = NetGen_Geo_Read(N,r);
NetUni = NetCmbn({Net1, Net1});
NetRnd = NetCmbn({Net2, Net2});

init = 50;
I1_a_initial_uni=init;
I2_a_initial_uni=init;
I1_a_initial_rnd=init;
I2_a_initial_rnd=init;

% alpha = [0.35, 0.10];   % infect rate
% mu = [0.04, 0.04];     % sleep s
% gamma = [0.04, 0.03];  % rec rate
% lambda = [0.06, 0.07];  % sleep I1
% kappa = [0.05, 0.06];  % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]

alpha = [0.25, 0.35];   % infect rate
mu = [0.04, 0.04];     % sleep s
gamma = [0.04, 0.35];  % rec rate
lambda = [0.06, 0.07];  % sleep I1
kappa = [0.05, 0.06];  % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]

[R0_uni,R1_uni,R2_uni] = calc_R0(NetUni, alpha, mu, gamma, lambda, kappa, N);
[R0_rnd,R1_rnd,R2_rnd] = calc_R0(NetRnd, alpha, mu, gamma, lambda, kappa, N);
[R0_uni, R1_uni, R2_uni; R0_rnd ,R1_rnd, R2_rnd]

% renderNetwork(Net1,21, 'uniform')
% renderNetwork(Net2,22, 'random')
%
Para = Para_active_sleep_SI1I2S(alpha, mu, gamma, lambda, kappa); 
M = Para{1}; StopCond={'RunTime', RunTime};
x0_uni = Initial_Cond_Gen(N,'Population',[3,5],[I1_a_initial_uni,I2_a_initial_uni], seed, r);
x0_rnd = Initial_Cond_Gen(N,'Population',[3,5],[I1_a_initial_rnd,I2_a_initial_rnd], seed, r);
x0 = {x0_uni, x0_rnd};

paramet = {alpha, mu, gamma, lambda, kappa};
paramet_mat = cell2mat(paramet);

%% Stochastic
% monte_rounds = 20;
[t, uni_, rnd_, ci_uni, ci_rnd] = monte(monte_rounds,N,Para,NetUni,NetRnd,x0,StopCond);
%% Discreate stochastic
% rnd_d = csvread(sprintf('monte_random_r=%g_5.csv',r),1);
% [t, rnd_d] = standartize(rnd_d(1:RunTime+1,:)', 0:RunTime, dt, RunTime);
% 
% uni_d = csvread(sprintf('monte_uniform_r=%g_5.csv',r),1);
% [t, uni_d] = standartize(uni_d(1:RunTime+1,:)', 0:RunTime, dt, RunTime);


%% ODE GEMF
[t, Xuni, Xrnd] = ode(N,Para,NetUni,NetRnd,x0,StopCond);
%% ODE yrys

% tic
% [t, Xuni_y] = ode_yrys_2(NetUni, [0, RunTime], x0_uni, N);
% toc
% tic
% [t, Xrnd_y] = ode_yrys_2(NetRnd, [0, RunTime], x0_rnd, N);
% toc
%% Homogen

% alpha = [0.25, 0.35];   % infect rate
% mu = [0.04, 0.04];     % sleep s
% gamma = [0.04, 0.35];  % rec rate
% lambda = [0.06, 0.07];  % sleep I1
% kappa = [0.05, 0.06];  % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]

% [R0_uni,R1_uni,R2_uni] = calc_R0(NetUni, alpha, mu, gamma, lambda, kappa, N);
% [R0_rnd,R1_rnd,R2_rnd] = calc_R0(NetRnd, alpha, mu, gamma, lambda, kappa, N);
% [R0_uni, R1_uni, R2_uni; R0_rnd ,R1_rnd, R2_rnd]

[tt, hmg_sol] = ode_wrapper(alpha, mu, gamma, lambda, kappa,...
    RunTime,N,I1_a_initial_uni,I2_a_initial_uni,r);

% figure(5)
% plot(t, hmg_sol(3:4,:)','-k')
% hold on 
% plot(t, hmg_sol(5:6,:)','-b')
% legend('I1_a','I1_s','I2_a','I2_s','Location','northwest');
% xlim([0,100])
% hold off
%%

tit = {'Sa','Ss','Infected_a 1 vs Time','Infected_s 1 vs Time',...
    'Infected_a 2 vs Time','Infected_s 2 vs Time'};
i = 1;
run_id = 1;
ss = sprintf('%g %g %g %g %g %g %g %g %g %g %d_%d_%d', paramet_mat, RunTime, init, monte_rounds);
sub = sprintf('%d) R1r_%g-R2r_%g R1u_%g-R2u_%g',run_id, R1_rnd, R2_rnd, R1_uni, R2_uni);
mkdir(sprintf('fig/%s',sub))

for z=[3,5,4,6]  % [3,5,4,6,1,2]    
    fig = figure(i);
    plot(t,uni_(z,:)./N,'-b', 'DisplayName','Stch uni')
    hold on
    plot(t,rnd_(z,:)./N,'-r', 'DisplayName','Stch rnd')
    plot(t,Xuni(z,:)./N,'--b','linewidth',1, 'DisplayName','ODE uni')
    plot(t,Xrnd(z,:)./N,'--r','linewidth',1, 'DisplayName','ODE rnd')
    plot(t,hmg_sol(z,:)./N,'.k','linewidth',1, 'DisplayName','homogen') 
    fill_ci(t', {ci_rnd{1}(z,:)/N, ci_rnd{2}(z,:)/N},'r', '95CI rnd')
    fill_ci(t', {ci_uni{1}(z,:)/N, ci_uni{2}(z,:)/N},'b', '95CI uni')
%     plot(t,uni_d(z,:)./N,'.b', 'DisplayName','I1_a uni python')
%     plot(t,rnd_d(z,:)./N,'.r', 'DisplayName','I1_a rnd python ')
%     plot(t,Xuni_y(z,:)./N,'-.g','linewidth',1);
%     plot(t,Xrnd_y(z,:)./N,'--g','linewidth',1);
    xlim([0, RunTime])
%     ylim([0,1])
    grid on
    hold off
    legend('Location','best')
    title(tit{z})
    saveas(fig, sprintf('fig/%s/%s %d.png',sub, ss, i))
    i = i + 1;
end;

%% Export

dlmwrite(sprintf('data/%d) Stch_uni_%d_%d.txt',run_id, RunTime, monte_rounds),uni_','delimiter','\t')
dlmwrite(sprintf('data/%d) Stch_rnd_%d_%d.txt',run_id, RunTime, monte_rounds),rnd_','delimiter','\t')
dlmwrite(sprintf('data/%d) Ode_uni_%d_%d.txt',run_id, RunTime, monte_rounds),Xuni','delimiter','\t')
dlmwrite(sprintf('data/%d) Ode_rnd_%d_%d.txt',run_id, RunTime, monte_rounds),Xrnd','delimiter','\t')
dlmwrite(sprintf('data/%d) Homogen_%d_%d.txt',run_id, RunTime, monte_rounds),hmg_sol','delimiter','\t')

dlmwrite(sprintf('data/%d) Stch_rnd_cil_%d_%d.txt',run_id, RunTime, monte_rounds), ci_rnd{1}','delimiter','\t')
dlmwrite(sprintf('data/%d) Stch_rnd_cih_%d_%d.txt',run_id, RunTime, monte_rounds), ci_rnd{2}','delimiter','\t')

dlmwrite(sprintf('data/%d) Stch_uni_cil_%d_%d.txt',run_id, RunTime, monte_rounds), ci_uni{1}','delimiter','\t')
dlmwrite(sprintf('data/%d) Stch_uni_cih_%d_%d.txt',run_id, RunTime, monte_rounds), ci_uni{2}','delimiter','\t')
