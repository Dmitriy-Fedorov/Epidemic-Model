function hb = diff_eq(t, w, mu,l,alpha,gamma,k, adj, N) 
x=zeros(N,1);  % i1_a
y=zeros(N,1);  % i2_a
z=zeros(N,1);  % s_a
v=zeros(N,1);  % i2_s
ww=zeros(N,1); % s_s
u=zeros(N,1);  % i1_s
for m=1:N 
    x(m)=w(m); 
end 
for m=N+1:2*N
    y(m-N)=w(m);
end 
for m=2*N+1:3*N 
    z(m-2*N)=w(m); 
end 
for m=3*N+1:4*N 
    v(m-3*N)=w(m); 
end 
for m=4*N+1:5*N 
    ww(m-4*N)=w(m); 
end 
for m=5*N+1:6*N 
    u(m-5*N)=w(m); 
end
% length(x)
% length(y)
% length(z)
% length(v)
% length(ww)
% length(u)
% length(w)

dxdt=zeros(N,1); 
dydt=zeros(N,1); 
dzdt=zeros(N,1); 
dvdt=zeros(N,1); 
dwdt=zeros(N,1); 
dudt=zeros(N,1);

for i=1:N 
    dxdt(i)=alpha(1)*z(i)*adj(i,:)*x-gamma(1)*x(i)-l(2)*x(i)+l(1)*u(i); 
    dydt(i)=alpha(2)*z(i)*adj(i,:)*y-gamma(2)*y(i)+v(i)*k(1)-y(i)*k(2); 
    dzdt(i)=gamma(2)*y(i)-alpha(2)*z(i)*adj(i,:)*y-z(i)*mu(2)+ ...
        ww(i)*mu(1)-alpha(1)*z(i)*adj(i,:)*x+gamma(1)*x(i);
    dvdt(i)=k(2)*y(i)-k(1)*v(i); 
    dudt(i)=l(2)*x(i)-l(1)*u(i); 
    dwdt(i)=mu(2)*z(i)-mu(1)*ww(i); 
end 

hb=[dxdt; dydt; dzdt; dvdt; dwdt; dudt]; 
end