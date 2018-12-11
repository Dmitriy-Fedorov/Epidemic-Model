function Net=NetCmbn(NetSet)

% Combines simple graphs into a multilayer graph
% Faryad Darabi Sahneh
% Kansas State University
% Last Modified: Sep 2013
% Copyright (c) 2013, Faryad Darabi Sahneh. All rights reserved. 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted

L=length(NetSet);

for i=1:L
    Neigh{i}=NetSet{i}{1}{1};
    I1(i,:)=NetSet{i}{2};
    I2(i,:)=NetSet{i}{3};
    d(:,i)=NetSet{i}{4};
    adj{i}=NetSet{i}{5}{1};
end;

Net={Neigh,I1,I2,d,adj};

end
    
