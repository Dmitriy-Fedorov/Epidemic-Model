function [ts,n_index,i_index,j_index]=GEMF_SIM(Para,Net,x0,StopCond)

% Numerical stochastic simulation of GEMF
% Faryad Darabi Sahneh
% Kansas State University
% Last Modified: Sep 2013
% Copyright (c) 2013, Faryad Darabi Sahneh. All rights reserved. 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted

M=Para{1}; q=Para{2}; L=Para{3}; A_d=Para{4}; A_b=Para{5};

Neigh=Net{1}; I1=Net{2}; I2=Net{3}; N=length(I1);

bil=zeros(M,L);
for l=1:L
    bil(:,l)=sum(A_b(:,:,l),2);
end;

bi=cell(1,M);
for i=1:M
    temp=[];
    for l=1:L
        temp=[temp,squeeze(A_b(i,:,l))'];
    end;
    bi{i}=temp;
end;

di=sum(A_d,2);

X0=zeros(M,N);
for i=1:N
    X0(x0(i),i)=1;
end;
X=X0;

% Finding Nq (L by N) matrix
Nq=zeros(L,N);
for n=1:N
    for l=1:L
        Nln=Neigh{l}(I1(l,n):I2(l,n));
        Nq(l,n)=sum(X(q(l),Nln));
    end;
end;

% Rates
Rin=di*ones(1,N).*X+bil*Nq.*X;
Ri=sum(Rin,2);
R=sum(Ri);

EventNum=StopCond{2};
RunTime=StopCond{2};

s=0; Tf=0;

while Tf<RunTime %number of events

    s=s+1;
    % Event Occurance
    ts(s)=-log(rand)/R;
    is=rnd_draw(Ri);
    ns=rnd_draw(Rin(is,:).*X(is,:)); % only those which are is
    % A_d(is,:)
    % Nq(:,ns)'
    % squeeze(A_b(is,:,:))
    js=rnd_draw(A_d(is,:)'+bi{is}*Nq(:,ns));

    n_index(s)=ns;
    j_index(s)=js;
    i_index(s)=is;

    % Updateing
    % Update State
    X(is,ns)=0; X(js,ns)=1;
    % Updating neighbors state counters and Rates
    Ri=Ri-Rin(:,ns);
    Rin(:,ns)=di.*X(:,ns)+bil*Nq(:,ns).*X(:,ns);
    Ri=Ri+Rin(:,ns);
    for l=find(q==js)
        Nln=Neigh{l}(I1(l,ns):I2(l,ns));
        for n=Nln
            Nq(l,n)=Nq(l,n)+1;
            Rin(:,n)=Rin(:,n)+bil(:,l).*X(:,n);
        end;
        Ri=Ri+bil(:,l).*sum(X(:,Nln),2);
    end;
    for l=find(q==is)
        Nln=Neigh{l}(I1(l,ns):I2(l,ns));
        for n=Nln
            Nq(l,n)=Nq(l,n)-1;
            Rin(:,n)=Rin(:,n)-bil(:,l).*X(:,n);
        end;
        Ri=Ri-bil(:,l).*sum(X(:,Nln),2);
    end;
    R=sum(Ri);

    if R<1e-6
        break;
    end;

    Tf=Tf+ts(s);

end