function Net=NetGen_Geo_Read(N, r)

% Generates random geometric graph network
% Faryad Darabi Sahneh
% Kansas State University
% Last Modified: Sep 2013
% Copyright (c) 2013, Faryad Darabi Sahneh. All rights reserved. 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted
pos = csvread(sprintf('pos_%g.csv',r));
% adj_loaded = csvread(sprintf('adj_%g.csv',r));
x = pos(1,:);
y = pos(2,:);
r2=r^2;
nodes = [x; y]; % stores original coordinates

l=0;
for i=1:N
    for j=i+1:N
        d2=(x(i)-x(j))^2+(y(i)-y(j))^2;
        if d2<=r2
            l=l+1;
            L1(l)=i;
            L2(l)=j;
        end;
    end;
end;

[ NeighVec , I1 , I2 , d ] = NeighborhoodData ( N , L1 , L2 ); 
I1=I1'; 
I2=I2';
Neigh{1}=NeighVec;

adj=cell(1);
adj{1}=sparse(L1,L2,1,N,N); 
adj{1}=adj{1}+adj{1}'; 

Net={Neigh,I1,I2,d,adj,nodes};
% equalaa = all(adj{1} == adj_loaded);
% equalaa
end