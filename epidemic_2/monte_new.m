function [t, StateCount] = monte_new(n,N,Para,Net,x0,StopCond, I1a_Initial, I2a_Initial)
M = Para{1};
global dt 
dt = 0.05;
timevec = 0:dt:StopCond{2};
tic;
[ts,n_index,i_index,j_index] = GEMF_SIM(Para,Net,x0,StopCond);
toc;
[T, StateCount_current] = Post_Population(x0,M,N,ts,i_index,j_index);

% Stocastic simulation produces not timeseries of different length
% therefore:
ts = timeseries(StateCount_current,T);
StateCount_current = resample(ts, timevec);
StateCount_total = StateCount_current.data;
t = StateCount_current.time;
%
for zz = 1:(n-1)
    x0 = Initial_Cond_Gen(N,'Population',[3,5],[I1a_Initial, I2a_Initial]);
    tic;
    [ts,n_index,i_index,j_index] = GEMF_SIM(Para,Net,x0,StopCond);
    toc;
    %%%%%%%%%%%%%%%%%%%%% Post Processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [T, StateCount_current]=Post_Population(x0,M,N,ts,i_index,j_index);
    ts = timeseries(StateCount_current,T);
    StateCount_current = resample(ts, timevec);
    StateCount_total = StateCount_total + StateCount_current.data;
end

StateCount = StateCount_total./n; % number of loops + initial one
StateCount = reshape(StateCount,6,StopCond{2}/dt+1);