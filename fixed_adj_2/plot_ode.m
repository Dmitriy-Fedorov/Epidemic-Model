function plot_ode(paramet,Xuni,Xrnd_,N,t,NetUni,NetRnd,save_)
lambdaUni = EIG1(NetUni,1);
lambdaRnd = EIG1(NetRnd,1);
global RunTime
alpha = paramet{1};
mu = paramet{2};
gamma = paramet{3};
lambda = paramet{4};
kappa = paramet{5};

[R0_uni,R1_uni,R2_uni] = calc_R0(NetUni, alpha, mu, gamma, lambda, kappa, N);
[R0_rnd,R1_rnd,R2_rnd] = calc_R0(NetRnd, alpha, mu, gamma, lambda, kappa, N);
paramet = cell2mat(paramet);
beta1 = paramet(1)/paramet(5);
beta2 = paramet(2)/paramet(6);

fig21 = figure(21);
subplot(3,1,1)
plot(t,Xuni(3,:)./N,t,Xuni(5,:)./N); 
title(sprintf('Uniform R1: %.02f, R2: %.02f, EIG: %.02f',R1_uni,R2_uni,lambdaUni))
legend({'Ia 1';'Ia 2'})
% ylim([0,1])
grid minor

subplot(3,1,2)
plot(t,Xuni(4,:)./N,t,Xuni(6,:)./N); 
legend({'Is 1';'Is 2'})
% ylim([0,1])
grid minor

% subplot(3,1,3)
% plot(t,uni_(1,:)./N,t,uni_(2,:)./N); 
% legend({'Sa';'Ss'})
% xlabel(num2str(paramet))
% ylim([0,1])
% grid minor

subplot(3,1,3)
plot(t,(Xuni(3,:)+Xuni(4,:))./N,t, (Xuni(5,:)+Xuni(6,:))./N); 
legend({'I1';'I2'})
% ylim([0,1])
xlabel(num2str(paramet))
grid minor

fig22 = figure(22);
subplot(3,1,1)
plot(t,Xrnd_(3,:)./N,t,Xrnd_(5,:)./N); 
title(sprintf('Random R1: %.02f, R2: %.02f, EIG: %.02f',R1_rnd,R2_rnd,lambdaRnd))
legend({'Ia 1';'Ia 2'})
% ylim([0,1])
grid minor

subplot(3,1,2)
plot(t,Xrnd_(4,:)./N,t,Xrnd_(6,:)./N); 
legend({'Is 1';'Is 2'})
% ylim([0,1])
grid minor

% subplot(3,1,3)
% plot(t,rnd_(1,:)./N,t,rnd_(2,:)./N); 
% legend({'Sa';'Ss'})
% ylim([0,1])
% xlabel(num2str(paramet))
% grid minor

subplot(3,1,3)
plot(t,(Xrnd_(3,:)+Xrnd_(4,:))./N,t, (Xrnd_(5,:)+Xrnd_(6,:))./N); 
legend({'I1';'I2'})
% ylim([0,1])
xlabel(num2str(paramet))
grid minor

ss = sprintf('%g %g %g %g %g %g %g %g %g %g %d', paramet, RunTime);
sub = sprintf('ODE %g %g %g %g', paramet(1),paramet(2),paramet(5),paramet(6));
if save_ == 1
    mkdir(sprintf('fig/%s',sub))
    saveas(fig21,sprintf('fig/S_%s_uni.png',ss))
    saveas(fig21,sprintf('fig/%s/S_%s_uni.png',sub, ss))
    saveas(fig22,sprintf('fig/S_%s_rnd.png',ss))
    saveas(fig22,sprintf('fig/%s/S_%s_rnd.png',sub, ss))
end
end