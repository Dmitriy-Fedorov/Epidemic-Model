function [ x0 ] = Initial_Cond_Gen ( N , method, J, funarg )

% Examples
% N=10; method='Population', J=[2,4]; NJ=[5,6];
% Initial_Cond_Gen ( N , method, J, NJ )
% N=10; method='Distribution', J=[2]; p=zeros(1,N); p([3,2,7])=1;
% Initial_Cond_Gen ( N , method, J, p )
% Faryad Darabi Sahneh
% Kansas State University
% Last Modified: Sep 2013
% Copyright (c) 2013, Faryad Darabi Sahneh. All rights reserved. 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted

x0=ones(1,N); % by defaul assignes all nodes to first compartment

if strcmp(method,'Population')

    NJ=funarg;
    
    % ensures that number of infected is less than total population
    if sum(NJ)>N
        disp('error')
        return;
    end;
    nj=randperm(N); % randomly arranges N numbers
    nj=nj(1:sum(NJ)); % takes first sum(NJ) nodes %Ex: NJ = [10,1,5]
    index=[0,cumsum(NJ)]; %Ex: index=[0,10,11,16]

    for k=1:length(J)
        x0(nj(index(k)+1:index(k+1)))=J(k); % sets compartment layer for each node
    end;
    
elseif strcmp(method,'Distribution')
    
    p=funarg;
    if sum(sum(p,1)>1)~=0
        disp('error');
        return;
    end;
    
    J=[J,1];
    
    for n=1:N
        index=rnd_draw([p(n);1-sum(p(:,n))]);
        x0(n)=J(index);
    end;
    
else
    disp('error');
    return;
    
end;

end
