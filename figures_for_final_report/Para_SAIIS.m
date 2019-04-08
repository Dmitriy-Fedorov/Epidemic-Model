function Para=Para_SAIIS(delta,delta_a,delta_s,delta_i,beta,beta_a,kappa,mu)


M=4; q=[2,2]; L=length(q);

A_d=zeros(M); A_d(2,1)=delta; A_d(4,3)=delta_a; A_d(3,1) = delta_s; A_d(2,4) = delta_i;
A_b=zeros(M,M,L); A_b(1,2,1)=beta; A_b(1,3,1)=kappa; A_b(3,4,1)=beta_a; A_b(1,3,2)=mu;


Para={M,q,L,A_d,A_b};

