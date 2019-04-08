function Para=Para_SI1SI2S(delta_1,delta_2,beta_1,beta_2)
M=3; q=[2,3]; L=length(q);
A_d=zeros(M); A_d(2,1)=delta_1; A_d(3,1)=delta_2;
A_b=zeros(M,M,L); 
A_b(1,2,1)=beta_1; 
A_b(1,3,2)=beta_2;
Para={M,q,L,A_d,A_b};
end