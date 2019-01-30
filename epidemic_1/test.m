% Initial Setup
global RunTime
r0 = 3;
monte_rounds = 5;
number_of_disconnected_nodes = 0;
n_disconnected_I1 = 0; % floor(rand(1)*5);
n_disconnected_I2 = 0; % floor(rand(1)*5);
n_disconnected_S = number_of_disconnected_nodes - n_disconnected_I1 - n_disconnected_I2;

dim = [30,30];
N = dim(1)*dim(2);
RunTime = 150;

Net1 = NetGen_GeoUniform(N,r0,dim,1);
Net2 = NetGen_Geo(N-number_of_disconnected_nodes,r0,dim);
NetUni = NetCmbn({Net1, Net1});
NetRnd = NetCmbn({Net2, Net2});

%Parameters and initial conditions
alpha = [0.03, 0.03];   % infect rate
mu = [0.14, 0.14];     % sleep s
gamma = [0.5, 0.5];  % rec rate
lambda = [0.05, 0.32];  % sleep I1
kappa = [0.05, 0.32];  % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]
I1_a_initial_uni=10;
I2_a_initial_uni=10;
I1_a_initial_rnd=10 - n_disconnected_I1;
I2_a_initial_rnd=10 - n_disconnected_I2; 

paramet = {alpha, mu, gamma, lambda, kappa};

[R0_uni,R1_uni,R2_uni] = calc_R0(NetUni, alpha, mu, gamma, lambda, kappa, N);
[R0_rnd,R1_rnd,R2_rnd] = calc_R0(NetRnd, alpha, mu, gamma, lambda, kappa, N);

[R0_uni, R1_uni, R2_uni; R0_rnd ,R1_rnd, R2_rnd]

%%
Para = Para_active_sleep_SI1I2S(alpha, mu, gamma, lambda, kappa); 
M = Para{1}; StopCond={'RunTime', RunTime};
x0_uni = Initial_Cond_Gen(N,'Population',[3,5],[I1_a_initial_uni,I2_a_initial_uni]);
x0_rnd = Initial_Cond_Gen(N,'Population',[3,5],[I1_a_initial_rnd,I2_a_initial_rnd]);
x0 = {x0_uni, x0_rnd};

init_infection_uni = [I1_a_initial_uni, I2_a_initial_uni];
init_infection_rnd = [I1_a_initial_rnd, I2_a_initial_rnd];
init_infection = {init_infection_uni, init_infection_rnd};
%%
[t, uni_, rnd_] = monte(monte_rounds,N,Para,NetUni,NetRnd,x0,StopCond,init_infection);
%
plot_stch(paramet,uni_*N,rnd_*N,N,t,NetUni,NetRnd, true)
%%
[t, Xuni, Xrnd] = ode(N,Para,NetUni,NetRnd,x0,StopCond,number_of_disconnected_nodes);
%
plot_ode(paramet,Xuni*N,Xrnd*N,N,t,NetUni,NetRnd, true)