function Net=NetGen_GeoUniform(N,r,dim,dx)

% sigma is number of nodes per unit area
% sigma = 1/dx^2

% Generates uniform geometric graph network
% Dmitriy Fedorov
% Nazarbayev University
% Last Modified: Oct 2018
% Copyright (c) 2013, Faryad Darabi Sahneh. All rights reserved. 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted
width = dim(1);
height = dim(2);
XX=0:dx:(width-1)*dx;
YY=0:dx:(height-1)*dx;

[x,y] = meshgrid(XX,YY);
x = x(1:N);
y = y(1:N);
r2=r^2;
nodes = [x; y]; % stores original coordinates

l=0;
for i=1:N
    for j=i+1:N
        d2=(x(i)-x(j))^2+(y(i)-y(j))^2; % distance squared between two node
        if d2<=r2  % if in transmission radius
            l=l+1;
            L1(l)=i; % index for first node position
            L2(l)=j; % index for second node position
        end;
    end;
end;

[ NeighVec , I1 , I2 , d ] = NeighborhoodData ( N , L1 , L2 ); 
% d -> how many connections does given node have
I1=I1'; I2=I2'; % dont know
Neigh{1}=NeighVec;

adj=cell(1);
adj{1}=sparse(L1,L2,1,N,N); % NxN adjacency matrix
adj{1}=adj{1}+adj{1}'; 

Net={Neigh,I1,I2,d,adj,nodes};

end