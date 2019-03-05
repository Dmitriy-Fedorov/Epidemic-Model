n = 5;
global dt
clear StateCount111 StateCount222
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
StateCount111(:,:,1) = squeeze(StateCount11.data);
StateCount222(:,:,1) = squeeze(StateCount22.data);
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
    StateCount111(:,:,zz+1) = squeeze(StateCount11.data);
    StateCount222(:,:,zz+1) = squeeze(StateCount22.data);
end



StateCount1 = mean(StateCount111, 3);
StateCount2 = mean(StateCount222, 3);
% plot(StateCount1')

%%
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
%%
% plot(t, low1,'b')
% hold on
% plot(t, high1,'k')

fill_ci(t',low1,high1,'y')
hold on
fill_ci(t',low2,high2,'g')

%%
slice = {ci_rnd{1}(1,:), ci_rnd{2}(1,:)};
fill_ci(t', {ci_rnd{1}(1,:), ci_rnd{2}(1,:)},'g');
%%
adj = Net2{1,5}{1};

dlmwrite('adj_2.csv',full(adj),'delimiter',',')
%%
exp1 = squeeze(StateCount111(1,:,:));
[low1,high1] = CI_df(exp1');
figure(3)
plot(t,StateCount1(1,:))
hold on
% plot(low1,'--k')
% plot(high1,'--k')
t2 = [t', fliplr(t')];
inBetween = [high1, fliplr(low1)];
h = fill(t2, inBetween, 'g', 'LineStyle','none');
set(h,'facealpha',.5)