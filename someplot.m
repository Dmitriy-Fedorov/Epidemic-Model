%% additional plots
figure(21)
subplot(3,1,1)
plot(t,Xuni(3,:),t,Xuni(5,:)); 
title('Uniform')
legend({'Ia 1';'Ia 2'})
ylim([0,1])
grid minor

subplot(3,1,2)
plot(t,Xuni(4,:),t,Xuni(6,:)); 
legend({'Is 1';'Is 2'})
ylim([0,1])
grid minor

subplot(3,1,3)
plot(t,Xuni(1,:),t,Xuni(2,:)); 
legend({'Sa';'Ss'})
ylim([0,1])
grid minor

figure(22)
subplot(3,1,1)
plot(t,Xrnd(3,:),t,Xrnd(5,:)); 
title('Random')
legend({'Ia 1';'Ia 2'})
ylim([0,1])
grid minor

subplot(3,1,2)
plot(t,Xrnd(4,:),t,Xrnd(6,:)); 
legend({'Is 1';'Is 2'})
ylim([0,1])
grid minor

subplot(3,1,3)
plot(t,Xrnd(1,:),t,Xrnd(2,:)); 
legend({'Sa';'Ss'})
ylim([0,1])
grid minor