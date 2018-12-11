function dX=GEMF_ODE_SOLVER(t,X)

% Solves GEMF ODE
% Faryad Darabi Sahneh
% Kansas State University
% Last Modified: Sep 2013
% Copyright (c) 2013, Faryad Darabi Sahneh. All rights reserved. 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted

global Q_d Q_b Neigh I1 I2 q M L N

x=reshape(X,M,N);


for i=1:N
    xi=x(:,i);
    dxi=-Q_d'*xi;
    for l=1:L
        Nei=Neigh{l}(I1(l,i):I2(l,i));
        yil=sum(x(q(l),Nei));
        dxi=dxi-yil*Q_b{l}'*xi;
    end;
    dx(:,i)=dxi;
end;

dX=reshape(dx,M*N,1);

end
    