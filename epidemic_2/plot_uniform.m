%% Plot
global alpha mu gamma lambda kappa
paramet = {alpha, mu, gamma, lambda, kappa};
paramet = cell2mat(paramet);
[R0_rnd,R1_rnd,R2_rnd] = calc_R0(NetUni, alpha, mu, gamma, lambda, kappa, N);
lambdaUno = EIG1(NetUni,1);

% Random I1 vs I2 sublot
fig23 = figure(23);
subplot(3,1,1)
hold on
plot(t,uni_stch(3,:)./N, '-r',t,uni_stch(5,:)./N, '-b'); 
plot(t,uni_ode(3,:)./N,'--r',t,uni_ode(5,:)./N, '--b'); 
hold off
title(sprintf('Uniform R1: %.02f, R2: %.02f, EIG: %.02f', R1_rnd, R2_rnd, lambdaUno))
legend({'Ia 1';'Ia 2'})
% ylim([0,1])
grid minor

subplot(3,1,2)
hold on
plot(t,uni_stch(4,:)./N, '-r',t,uni_stch(6,:)./N, '-b'); 
plot(t,uni_ode(4,:)./N,'--r',t,uni_ode(6,:)./N, '--b'); 
hold off
legend({'Is 1';'Is 2'})
% ylim([0,1])
grid minor


subplot(3,1,3)
hold on
plot(t,(uni_stch(3,:)+uni_stch(4,:))./N, '-r',t,(uni_stch(5,:)+uni_stch(6,:))./N, '-b'); 
plot(t,(uni_ode(3,:)+uni_ode(4,:))./N, '--r',t,(uni_ode(5,:)+uni_ode(6,:))./N, '--b');  
hold off
legend({'I1';'I2'})
% ylim([0,1])
xlabel(num2str(paramet))
grid minor