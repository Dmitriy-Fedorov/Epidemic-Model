function fig = renderNetwork(Net, fig, tit)

nodes = Net(6);
nodes = nodes{1};
U = triu(Net{5}{1});
[ii,jj] = find(U);
xx = nodes(1,:);
yy = nodes(2,:);
fig = figure(fig);

for k=1:length(ii)
    xxx = [xx(ii(k)),xx(jj(k))];
    yyy = [yy(ii(k)),yy(jj(k))];
    hold on
    p1 = plot(xxx,yyy,'-k');
    p1.Color(4) = 0.5;
end
scatter(xx,yy,40,'ok','filled',...
    'MarkerEdgeColor',[0 0 0],...  %[0 0 0] [1 1 1]
    'MarkerFaceColor',[1 1 1])
title(tit)
hold off