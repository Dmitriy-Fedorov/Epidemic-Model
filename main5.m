% clear; clc; close all;
setenv('MKL_DEBUG_CPU_TYPE', '4')
global RunTime
% Initial Setup
r0 = 3;
monte_rounds = 5;
number_of_disconnected_nodes = 0;
n_disconnected_I1 = 0; % floor(rand(1)*5);
n_disconnected_I2 = 0; % floor(rand(1)*5);
n_disconnected_S = number_of_disconnected_nodes - n_disconnected_I1 - n_disconnected_I2;

dim = [30,30];
N = dim(1)*dim(2);
RunTime = 100;

Net1 = NetGen_GeoUniform(N,r0,dim,1);
Net2 = NetGen_Geo(N-number_of_disconnected_nodes,r0,dim);
NetUni = NetCmbn({Net1, Net1});
NetRnd = NetCmbn({Net2, Net2});

%Parameters and initial conditions
alpha = [0.02, 0.03];   % infect rate
mu = [0.04, 0.04];     % sleep s
gamma = [0.35, 0.40];  % rec rate
lambda = [0.05, 0.06];  % sleep I1
kappa = [0.04, 0.21];  % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]
I1_a_initial_uni=10;
I2_a_initial_uni=10; 
I1_a_initial_rnd=10 - n_disconnected_I1;
I2_a_initial_rnd=10 - n_disconnected_I2; 

Para = Para_active_sleep_SI1I2S(alpha, mu, gamma, lambda, kappa); 
M = Para{1}; StopCond={'RunTime', RunTime};
x0_uni = Initial_Cond_Gen(N,'Population',[3,5],[I1_a_initial_uni,I2_a_initial_uni]);
x0_rnd = Initial_Cond_Gen(N,'Population',[3,5],[I1_a_initial_rnd,I2_a_initial_rnd]);
x0 = {x0_uni, x0_rnd};

init_infection_uni = [I1_a_initial_uni, I2_a_initial_uni];
init_infection_rnd = [I1_a_initial_rnd, I2_a_initial_rnd];
init_infection = {init_infection_uni, init_infection_rnd};
paramet = {alpha, mu, gamma, lambda, kappa};
[R0_uni,R1_uni,R2_uni] = calc_R0(NetUni, alpha, mu, gamma, lambda, kappa, N);
[R0_rnd,R1_rnd,R2_rnd] = calc_R0(NetRnd, alpha, mu, gamma, lambda, kappa, N);

[R0_uni, R1_uni, R2_uni; R0_rnd ,R1_rnd, R2_rnd]

[t, uni_, rnd_] = monte(monte_rounds,N,Para,NetUni,NetRnd,x0,StopCond,init_infection);
%%
plot_stch(paramet,uni_,rnd_,N,t,NetUni,NetRnd, true)

% renderNetwork(Net1,21)
% renderNetwork(Net2,22)
%%
[t, Xuni, Xrnd] = ode(N,Para,NetUni,NetRnd,x0,StopCond,number_of_disconnected_nodes);
plot_ode(paramet,Xuni,Xrnd,N,t,NetUni,NetRnd,true)
%% Homogen

[tt, sol_values] = ode_wrapper(alpha, mu, gamma, lambda, kappa,...
    RunTime,N,I1_a_initial_uni,I2_a_initial_uni,r0);
%%
% plot(t,Xuni)
tit = {'Sa','Ss','Infected_a 1 vs Time','Infected_s 1 vs Time',...
    'Infected_a 2 vs Time','Infected_s 2 vs Time'};
i = 1;
variable1 = RunTime/.05+1;
shape = [4,6,variable1];
export = zeros(shape);
for z=[3,5,4,6]  % [3,5,4,6,1,2]
    export(i,1,:) = t;
    export(i,2,:) = uni_(z,:)./N;
    export(i,3,:) = rnd_(z,:)./N;
    export(i,4,:) = Xuni(z,:)./N;
    export(i,5,:) = Xrnd(z,:)./N;
    export(i,6,:) = sol_values(z,:)./N;
    
    figure(i)
    plot(t,uni_(z,:)./N, t,rnd_(z,:)./N); 
    hold on
    plot(t,Xuni(z,:)./N,'-.b','linewidth',1);
    plot(t,Xrnd(z,:)./N,'--r','linewidth',1);
    plot(t,sol_values(z,:)./N,'--k','linewidth',1)
    title(tit{z})
    legend('I1_a uni','I1_a rnd','ODE uni','ODE rnd','homogen','Location','northwest');
    xlim([0, RunTime])
    ylim([0,1])
    grid on
    hold off
    i = i + 1;
end;
% %%
% export_i1a=reshape(export(1,:,:),6,variable1)';
% export_i2a=reshape(export(2,:,:),6,variable1)';
% export_i1s=reshape(export(3,:,:),6,variable1)';
% export_i2s=reshape(export(4,:,:),6,variable1)';
% 
% % plot(t,export_i1a)
% dlmwrite('export_i1a.txt',export_i1a(1:15:end,:),'delimiter','\t')
% dlmwrite('export_i2a.txt',export_i2a(1:15:end,:),'delimiter','\t')
% dlmwrite('export_i1s.txt',export_i1s(1:15:end,:),'delimiter','\t')
% dlmwrite('export_i2s.txt',export_i2s(1:15:end,:),'delimiter','\t')
%% How big is difference plot
% n_disconnected_I1 = floor(rand(1)*5);
% n_disconnected_I2 = floor(rand(1)*5);
% n_disconnected_S = number_of_disconnected_nodes - n_disconnected_I1 - n_disconnected_I2;
% nsa = number_of_disconnected_nodes/2;
% nss = number_of_disconnected_nodes/2;
% 
% Xrnd_temp = Xrnd;
% Xrnd_temp(1,:) = Xrnd_temp(1,:) + nsa;
% Xrnd_temp(2,:) = Xrnd_temp(2,:) + nss;
% rnd_temp = rnd_;
% rnd_temp(1,:) = rnd_temp(1,:) + nsa;
% rnd_temp(2,:) = rnd_temp(2,:) + nss;

figure(9)
error_rnd = (Xrnd - rnd_);
plot(t,error_rnd(1:end,:)./N)
title('rnd error')
ylim([-0.1,0.1])
grid minor; grid on
lege = {'Sa';'Ss';'Ia 1';'Is 1';'Ia 2';'Is 2'};
legend(lege{3:end})

figure(10)
error_uni = (Xuni-uni_);
plot(t,error_uni(3:end,:)./N)
ylim([-0.1,0.1])
title('uni error')
grid minor; grid on
legend(lege{3:end})

%% additional plots
plot_ode(paramet,Xuni,Xrnd,N,t,NetUni,NetRnd,true)
plot_stch(paramet,uni_,rnd_,N,t,NetUni,NetRnd,true)
% save('Xuni')