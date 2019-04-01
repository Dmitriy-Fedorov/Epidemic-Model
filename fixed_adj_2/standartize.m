function [timevec, vec] = standartize(vec, t_values, dt, RunTime)
timevec = 0:dt:RunTime;
ts = timeseries(vec,t_values);
vec = resample(ts, timevec);
vec = vec.data;
vec = reshape(vec,6, RunTime/dt+1);