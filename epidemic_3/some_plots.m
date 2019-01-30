%% Plot
global alpha mu gamma lambda kappa
paramet = {alpha, mu, gamma, lambda, kappa};
paramet = cell2mat(paramet);
[R0_rnd,R1_rnd,R2_rnd] = calc_R0(NetRnd, alpha, mu, gamma, lambda, kappa, N);
lambdaRnd = EIG1(NetRnd,1);

% legend('Sa','Ss','Ia 1','Is 1','Ia 2','Is 2') % Dima
% Random I1 vs I2 sublot
fig23 = figure(23);
subplot(3,1,1)
hold on
plot(t,rnd_stch(3,:)./N, '-r',t,rnd_stch(5,:)./N, '-b'); 
plot(t,rnd_ode(3,:)./N,'--r',t,rnd_ode(5,:)./N, '--b'); 
plot(M(:,1), M(:,4)/N,'-.k', M(:,1), M(:,6)/N,'-.k')
hold off
title(sprintf('Random R1: %.02f, R2: %.02f, EIG: %.02f', R1_rnd, R2_rnd, lambdaRnd))
legend({'Ia 1';'Ia 2'})
% ylim([0,1])
grid minor

subplot(3,1,2)
hold on
plot(t,rnd_stch(4,:)./N, '-r',t,rnd_stch(6,:)./N, '-b'); 
plot(t,rnd_ode(4,:)./N,'--r',t,rnd_ode(6,:)./N, '--b'); 
plot(M(:,1), M(:,5)/N,'-.k', M(:,1), M(:,7)/N,'-.k')
hold off
legend({'Is 1';'Is 2'})
% ylim([0,1])
grid minor


subplot(3,1,3)
% plot(t,(rnd_stch(3,:)+rnd_stch(4,:))./N,t, (rnd_stch(5,:)+rnd_stch(6,:))./N); 
hold on
plot(t,(rnd_stch(3,:)+rnd_stch(4,:))./N, '-r',t,(rnd_stch(5,:)+rnd_stch(6,:))./N, '-b'); 
plot(t,(rnd_ode(3,:)+rnd_ode(4,:))./N, '--r',t,(rnd_ode(5,:)+rnd_ode(6,:))./N, '--b');  
plot(M(:,1), (M(:,4)+M(:,5))/N,'-.k', M(:,1), (M(:,6)+M(:,7))/N,'-.k');
hold off
legend({'I1';'I2'})
% ylim([0,1])
xlabel(num2str(paramet))
grid minor
