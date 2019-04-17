function Net=NetLoad_Geo(filename,N,r)

A = csvread(filename,0,0);
length(A) == N
x = A(:,1)';
y = A(:,2)';
r2=r^2;
nodes = [x; y] % stores original coordinates
% [x, y]
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

end