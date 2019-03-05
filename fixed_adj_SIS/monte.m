function [t, StateCount1, StateCount2, ci1, ci2] = monte(n,N,Para,NetUni,NetRnd,x0,StopCond)
global dt RunTime
M = Para{1};
x0_uni = x0{1};
x0_rnd = x0{2};

tic;
[ts1,n_index1,i_index1,j_index1] = GEMF_SIM(Para,NetUni,x0_uni,StopCond);
[ts2,n_index2,i_index2,j_index2] = GEMF_SIM(Para,NetRnd,x0_rnd,StopCond);
toc;
[T1, StateCount1]=Post_Population(x0_uni,M,N,ts1,i_index1,j_index1);
[T2, StateCount2]=Post_Population(x0_rnd,M,N,ts2,i_index2,j_index2);

[t, StateCount11] = standartize(StateCount1, T1, dt, RunTime);
[t, StateCount22] = standartize(StateCount2, T2, dt, RunTime);
StateCount111(:,:,1) = squeeze(StateCount11);
StateCount222(:,:,1) = squeeze(StateCount22);
for zz = 1:(n-1)
    tic;
    [ts1,n_index1,i_index1,j_index1] = GEMF_SIM(Para,NetUni,x0_uni,StopCond);
    [ts2,n_index2,i_index2,j_index2] = GEMF_SIM(Para,NetRnd,x0_rnd,StopCond);
    toc;
    %%%%%%%%%%%%%%%%%%%%% Post Processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [T1, StateCount1]=Post_Population(x0_uni,M,N,ts1,i_index1,j_index1);
    [T2, StateCount2]=Post_Population(x0_rnd,M,N,ts2,i_index2,j_index2);
    [t, StateCount11] = standartize(StateCount1, T1, dt, RunTime);
    [t, StateCount22] = standartize(StateCount2, T2, dt, RunTime);
    StateCount111(:,:,zz+1) = squeeze(StateCount11);
    StateCount222(:,:,zz+1) = squeeze(StateCount22);
end

StateCount1 = mean(StateCount111, 3);
StateCount2 = mean(StateCount222, 3);


low1 = zeros(size(StateCount1));
high1 = zeros(size(StateCount1));
low2 = zeros(size(StateCount2));
high2 = zeros(size(StateCount2));

for zz = 1:size(StateCount111,1)
    exp1 = squeeze(StateCount111(zz,:,:));
    exp2 = squeeze(StateCount222(zz,:,:));
    [low11,high11] = CI_df(exp1');
    [low22,high22] = CI_df(exp2');
    low1(zz,:) = low11;
    high1(zz,:) = high11;
    low2(zz,:) = low22;
    high2(zz,:) = high22;
end

ci1 = {low1, high1};
ci2 = {low2, high2};