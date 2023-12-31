% To call the function [M0, I, O] =NFA2PN(m,n,Enon,Edet,D,flabel,nodeNum)  
% in Example 6,
% we use the following arguments.

m = 3;
n = 4;

% Enon = {{(M0,a,M1),(M0,a,M2)}}
Enon = {
    struct('MFrom',{'M0','M0'},'label',{'a','a'},'MTo',{'M1','M2'})
 };
% Edet = {{(M1,b,M3)},{(M2,a,M4)},{(M3,b,M2)},{(M4,b,M0)}}
Edet = {
    struct('MFrom',{'M1'},'label',{'b'},'MTo',{'M2'}); 
    struct('MFrom',{'M2'},'label',{'a'},'MTo',{'M4'});
    struct('MFrom',{'M3'},'label',{'b'},'MTo',{'M2'});
    struct('MFrom',{'M4'},'label',{'b'},'MTo',{'M0'})
};
% D = {(M0,b),(M1,a),(M2,b),(M3,a),(M4,a)}
D = struct('MFrom',{'M0','M1','M2','M3','M4'},'label',{'b','a','b','a','a'});

flabel=containers.Map;
flabel('a') = {'t1','t2'};
flabel('b') = {'t3','t4'};

nodeNum = 5;

[M0, I, O] = NFA2PN(m,n,Enon,Edet,D,flabel,nodeNum);