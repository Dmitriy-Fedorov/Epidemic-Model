function [ NeighVec , I1 , I2 , d ] = NeighborhoodData ( N , L1 , L2 )
% N scalar, L1 & L2 are lists

% Find Neighborhood represention of graph from adjacency list
% Faryad Darabi Sahneh
% Kansas State University
% Last Modified: Sep 2013
% Copyright (c) 2013, Faryad Darabi Sahneh. All rights reserved. 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted

I1 = [] ;
I2 = [] ;
dummy1 = [ L1 , L2 ] ;
dummy2 = [ L2 , L1 ] ;
[ junk , index ] = sort ( dummy1 ) ;
NeighVec = dummy2 ( index ) ;
l = length ( junk ) ;
d = zeros ( N , 1 ) ;
I1 = zeros ( N , 1 ) ;
i = 1 ;
while i < l
    node = junk ( i ) ;
    I1 ( node ) = i ;
    while junk ( i + 1 ) == junk ( i )
        d ( node ) = d ( node ) + 1 ;
        i = i + 1 ;
        if i == l ;
            break ;
        end
    end
    i = i + 1 ;
end
if i == l
    node = junk ( i ) ;
    I1 ( node ) = i ;
    d ( node ) = 0 ;
end
I2 = I1 + d ;
d = I2 - I1 + ( I1 ~= 0 ) ;
    
    
    