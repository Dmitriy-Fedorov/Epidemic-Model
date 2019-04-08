function [t, X1, X2] = ode(N,Para,NetUni,NetRnd,x0,StopCond,number_of_disconnected_nodes)
RunTime = StopCond{2};
M = Para{1};
x0_uni = x0{1};
x0_rnd = x0{2};

X0_uni = zeros(M,N);
for i=1:N
    X0_uni(x0_uni(i),i) = 1;
end;
X0_rnd = zeros(M,N-number_of_disconnected_nodes);
for i=1:N-number_of_disconnected_nodes
    X0_rnd(x0_rnd(i),i) = 1;
end;

tic;
[t1,X1] = GEMF_ODE(Para,NetUni,X0_uni,RunTime);
toc;
tic;
[t2,X2] = GEMF_ODE(Para,NetRnd,X0_rnd,RunTime);
toc;

X1_ = zeros(6,length(t1));
X2_ = zeros(6,length(t2));
for ab = 1:M
     X1_(ab,:) = sum(X1(:,ab:M:end),2);
     X2_(ab,:) = sum(X2(:,ab:M:end),2);
end

ts1 = timeseries(X1_,t1);
ts2 = timeseries(X2_,t2);
dt = 0.05;
% makes vectors of the same length
[X11,X22] = synchronize(ts1,ts2,'Uniform','Interval', dt);
X1 = X11.data;
X2 = X22.data;
X1 = reshape(X1,6,StopCond{2}/dt+1);
X2 = reshape(X2,6,StopCond{2}/dt+1);
t = X22.time;

