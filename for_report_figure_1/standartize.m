function [timevec, vec] = standartize(vec, t_values, dt)
timevec = 0:dt:t_values(end);
ts = timeseries(vec,t_values);
vec = resample(ts, timevec);
vec = vec.data;
vec = reshape(vec,6, t_values(end)/dt+1);