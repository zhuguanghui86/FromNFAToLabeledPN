%To call the function [M0, I, O] =NFA2PN(m,n,Enon,Edet,D,flabel,nodeNum)  
% in the numerical example in Section 5,
% we use the following arguments.

m = 2;
n = 3;

% Enon = {{(M1,a,M0),(M1,a,M2)}}
Enon = {
    struct('MFrom',{'M1','M1'},'label',{'a','a'},'MTo',{'M0','M2'})
 };
% Edet = {{(M0,a,M1)},{(M2,b,M1)}}
Edet = {
    struct('MFrom',{'M0'},'label',{'a'},'MTo',{'M1'});
    struct('MFrom',{'M2'},'label',{'b'},'MTo',{'M1'})
};
% D = {(M0,b),(M1,b),(M2,a)}
D = struct('MFrom',{'M0','M1','M2'},'label',{'b','b','a'});

flabel=containers.Map;
flabel('a') = {'t1','t2'};
flabel('b') = {'t3'};

nodeNum = 3;

[M0, I, O] = NFA2PN(m,n,Enon,Edet,D,flabel,nodeNum);