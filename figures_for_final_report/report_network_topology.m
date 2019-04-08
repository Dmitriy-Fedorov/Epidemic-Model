clear; clc; close all;
setenv('MKL_DEBUG_CPU_TYPE', '4')
% Initial Setup
r0 = 1.5;
number_of_disconnected_nodes = 50;

dim = [30,30];
N = dim(1)*dim(2);

Net1 = NetGen_GeoUniform(N,r0,dim,1);
Net2 = NetGen_Geo(N,r0,dim);

fig1 = renderNetwork(Net1,21, sprintf('Uniform Grid, r=%d',r0));
fig2 = renderNetwork(Net2,22, sprintf('Geometric Random, r=%d',r0));

% saveas(fig1,sprintf('fig/r=%.1f_Uniform_Grid.png',r0))
% saveas(fig2,sprintf('fig/r=%.1f_Geometric_Random.png',r0))