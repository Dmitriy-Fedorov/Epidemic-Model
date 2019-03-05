function fill_ci(t, confidence_interval, color, DisplayName)
low = confidence_interval{1};
high = confidence_interval{2};
t2 = [t, fliplr(t)];
inBetween = [high, fliplr(low)];
h = fill(t2, inBetween, color, 'LineStyle','none','DisplayName',DisplayName);
set(h,'facealpha',.2)