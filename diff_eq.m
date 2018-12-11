function hb = diff_eq(t, w, sigma, r0, N, lambda_a, lambda_s, k_a, k_s, alpha1, alpha2,mu_a, mu_s, gamma1, gamma2 ) 
x=w(1); 
y=w(2); 
z=w(3); 
a=w(4); 
b=w(5); 
c=w(6); 
dxdt = c*lambda_a-x*lambda_s+x*alpha1*sigma*pi*r0*z/N-x*gamma1; 
dydt = a*k_a-y*k_s+y*alpha2*sigma*pi*r0*z/N-y*gamma2; 
dzdt = b*mu_a-z*mu_s+gamma2*y+x*gamma1-y*alpha2*sigma*pi*r0*z/N-x*alpha1*sigma*pi*r0*z/N;
dadt = y*k_s-a*k_a; 
dbdt = mu_s*z-mu_a*b; 
dcdt = x*lambda_s-c*lambda_a; 
% legend('I1_a','I2_a','S_a', 'I2_s', 'S_s', 'I1_s') 
hb = [dxdt; dydt; dzdt; dadt; dbdt; dcdt]; 

%hb = [dzdt; dbdt; dxdt; dcdt; dydt; dadt]; 
end