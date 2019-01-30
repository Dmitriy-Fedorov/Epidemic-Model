% R1<1; R2<1
alpha = [0.02, 0.03]; % infect rate 
mu = [0.14, 0.14]; % sleep s 
gamma = [0.5, 0.47]; % rec rate 
lambda = [0.05, 0.32]; % sleep I1 
kappa = [0.04, 0.31]; % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]

% R1>1; R2<1
alpha = [0.05, 0.03]; % infect rate 
mu = [0.14, 0.14]; % sleep s 
gamma = [0.35, 0.47]; % rec rate 
lambda = [0.05, 0.32]; % sleep I1 
kappa = [0.04, 0.31]; % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]

% R1<1; R2>1
alpha = [0.03, 0.06]; % infect rate 
mu = [0.14, 0.14]; % sleep s 
gamma = [0.35, 0.47]; % rec rate 
lambda = [0.05, 0.32]; % sleep I1 
kappa = [0.04, 0.31]; % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]

% R1>1; R2>1
alpha = [0.03, 0.06]; % infect rate 
mu = [0.14, 0.14]; % sleep s 
gamma = [0.35, 0.47]; % rec rate 
lambda = [0.05, 0.32]; % sleep I1 
kappa = [0.04, 0.31]; % sleep I2    % [I2_s -> I2_a, I2_a -> I2_s]


M = csvread('monte_random_15.csv',1,0);

plot(M(:,1), M(:,2:5)/900)