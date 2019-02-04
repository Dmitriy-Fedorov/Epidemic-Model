function [t, StateCount1, StateCount2] = monte(n,N,Para,NetUni,NetRnd,x0,StopCond)
global dt
M = Para{1};
x0_uni = x0{1};
x0_rnd = x0{2};

tic;
[ts1,n_index1,i_index1,j_index1] = GEMF_SIM(Para,NetUni,x0_uni,StopCond);
[ts2,n_index2,i_index2,j_index2] = GEMF_SIM(Para,NetRnd,x0_rnd,StopCond);
toc;
[T1, StateCount1]=Post_Population(x0_uni,M,N,ts1,i_index1,j_index1);
[T2, StateCount2]=Post_Population(x0_rnd,M,N,ts2,i_index2,j_index2);

% Stocastic simulation produces not timeseries of different length
% therefore:
ts1 = timeseries(StateCount1,T1);
ts2 = timeseries(StateCount2,T2);

[StateCount11,StateCount22] = synchronize(ts1,ts2,'Uniform','Interval', dt);
StateCount111 = StateCount11.data;
StateCount222 = StateCount22.data;
t = StateCount22.time;
%
for zz = 1:(n-1)
    tic;
    [ts1,n_index1,i_index1,j_index1] = GEMF_SIM(Para,NetUni,x0_uni,StopCond);
    [ts2,n_index2,i_index2,j_index2] = GEMF_SIM(Para,NetRnd,x0_rnd,StopCond);
    toc;
    %%%%%%%%%%%%%%%%%%%%% Post Processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [T1, StateCount1]=Post_Population(x0_uni,M,N,ts1,i_index1,j_index1);
    [T2, StateCount2]=Post_Population(x0_rnd,M,N,ts2,i_index2,j_index2);
    ts1 = timeseries(StateCount1,T1);
    ts2 = timeseries(StateCount2,T2);
    [StateCount11,StateCount22] = synchronize(ts1,ts2,'Uniform','Interval', dt);
    StateCount111 = StateCount111 + StateCount11.data;
    StateCount222 = StateCount222 + StateCount22.data;
end

StateCount1 = StateCount111./n; % number of loops + initial one
StateCount2 = StateCount222./n;
StateCount1 = reshape(StateCount1,6,StopCond{2}/dt+1);
StateCount2 = reshape(StateCount2,6,StopCond{2}/dt+1);