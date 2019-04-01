function [lambda1,v1] = EIG2(adj)

% Finds the largest eigenvalue of a network layer
% Faryad Darabi Sahneh
% Kansas State University
% Last Modified: Sep 2013
% Copyright (c) 2013, Faryad Darabi Sahneh. All rights reserved. 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted

k=sum(adj,2); k=k/sum(k);

err=1; lambda1=0;
while err>1e-3
    k=adj*k;
    err=sum(k)-lambda1;
    lambda1=sum(k);
    k=k/lambda1;
end;

lambda1=full(lambda1);
v1=full(k);

end