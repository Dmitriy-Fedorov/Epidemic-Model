function plot_stch(paramet,uni_,rnd_,N,t,NetUni,NetRnd, save_)
global RunTime
lambdaUni = EIG1(NetUni,1);
lambdaRnd = EIG1(NetRnd,1);
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


fig23 = figure(23);
subplot(3,1,1)
plot(t,uni_(3,:)./N,t,uni_(5,:)./N); 
title(sprintf('Uniform R1: %.02f, R2: %.02f, EIG: %.02f',R1_uni,R2_uni,lambdaUni))
legend({'Ia 1';'Ia 2'})
% ylim([0,1])
grid minor

subplot(3,1,2)
plot(t,uni_(4,:)./N,t,uni_(6,:)./N); 
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
plot(t,(uni_(3,:)+uni_(4,:))./N,t, (uni_(5,:)+uni_(6,:))./N); 
legend({'I1';'I2'})
% ylim([0,1])
xlabel(num2str(paramet))
grid minor

fig24 = figure(24);
subplot(3,1,1)
plot(t,rnd_(3,:)./N,t,rnd_(5,:)./N); 
title(sprintf('Random R1: %.02f, R2: %.02f, EIG: %.02f',R1_rnd,R2_rnd,lambdaRnd))
legend({'Ia 1';'Ia 2'})
% ylim([0,1])
grid minor

subplot(3,1,2)
plot(t,rnd_(4,:)./N,t,rnd_(6,:)./N); 
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
plot(t,(rnd_(3,:)+rnd_(4,:))./N,t, (rnd_(5,:)+rnd_(6,:))./N); 
legend({'I1';'I2'})
% ylim([0,1])
xlabel(num2str(paramet))
grid minor

ss = sprintf('%g %g %g %g %g %g %g %g %g %g %d', paramet, RunTime);
sub = sprintf('%g %g %g %g', paramet(1),paramet(2),paramet(5),paramet(6));

if save_ == 1
    mkdir(sprintf('fig/%s',sub))
    saveas(fig23,sprintf('fig/S_%s_uni.png',ss))
    saveas(fig23,sprintf('fig/%s/S_%s_uni.png',sub, ss))
    saveas(fig24,sprintf('fig/S_%s_rnd.png',ss))
    saveas(fig24,sprintf('fig/%s/S_%s_rnd.png',sub, ss))
end
end