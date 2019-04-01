% just list of parameters to remember

%Parameters and initial conditions
alpha = [0.4, 0.25];   % infect rate
mu = [0.04, 0.04];     % sleep s
gamma = [0.1, 0.025];  % rec rate
lambda = [0.02, 0.09];  % sleep I1
kappa = [0.03, 0.07];  % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]

%%  
% Initial Setup
r0 = 3;
number_of_disconnected_nodes = 50;
n_disconnected_I1 = 5; % floor(rand(1)*5);
n_disconnected_I2 = 2; % floor(rand(1)*5);
n_disconnected_S = number_of_disconnected_nodes - n_disconnected_I1 - n_disconnected_I2;

dim = [30,30];
N = dim(1)*dim(2);
RunTime = 50;

Net1 = NetGen_GeoUniform(N,r0,dim,1);
Net2 = NetGen_Geo(N-number_of_disconnected_nodes,r0,dim);
NetUni = NetCmbn({Net1, Net1});
NetRnd = NetCmbn({Net2, Net2});

%Parameters and initial conditions
alpha = [0.2, 0.15];   % infect rate
mu = [0.04, 0.04];     % sleep s
gamma = [0.08, 0.05];  % rec rate
lambda = [0.1, 0.12];  % sleep I1
kappa = [0.09, 0.11];  % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]
I1_a_initial_uni=10;
I2_a_initial_uni=10; 
I1_a_initial_rnd=10 - n_disconnected_I1;
I2_a_initial_rnd=10 - n_disconnected_I2; 
%% Overtaking example
% Initial Setup
r0 = 3;
number_of_disconnected_nodes = 0;
n_disconnected_I1 = 0;%floor(rand(1)*5);
n_disconnected_I2 = 0;%floor(rand(1)*5);
n_disconnected_S = number_of_disconnected_nodes - n_disconnected_I1 - n_disconnected_I2;

dim = [20,20];
N = dim(1)*dim(2);
RunTime = 1000;

Net1 = NetGen_GeoUniform(N,r0,dim,1);
Net2 = NetGen_Geo(N-number_of_disconnected_nodes,r0,dim);
NetUni = NetCmbn({Net1, Net1});
NetRnd = NetCmbn({Net2, Net2});

%Parameters and initial conditions
alpha = [0.4, 0.2];   % infect rate
mu = [0.04, 0.04];     % sleep s
gamma = [0.1, 0.05];  % rec rate
lambda = [0.03, 0.2];  % sleep I1
kappa = [0.12, 0.06];  % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]
I1_a_initial_uni=10;
I2_a_initial_uni=10; 
I1_a_initial_rnd=10 - n_disconnected_I1;
I2_a_initial_rnd=10 - n_disconnected_I2; 
%%

ss = 'asd2';
saveas(figure(1),sprintf('fig/1%s.png',ss))
saveas(figure(2),sprintf('fig/2%s.png',ss))
saveas(figure(3),sprintf('fig/3%s.png',ss))
saveas(figure(4),sprintf('fig/4%s.png',ss))