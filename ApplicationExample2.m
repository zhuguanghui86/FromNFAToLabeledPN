% MATLAB Code for Application Example 2
m = 4;
n = 6;

% Enon = empty set
Enon = {};
% Edet = {
%             {(M0,a,M0)},
%             {(M0,e,M1)}, where 'e' stands for the epsilon symbol
%             {(M1,a,M2)},
%             {(M2,b,M0)},
%             {(M2,e,M3)},
%             {(M3,b,M2)}
% }
Edet = {
    struct('MFrom',{'M0'},'label',{'a'},'MTo',{'M0'}); 
    struct('MFrom',{'M0'},'label',{'e'},'MTo',{'M1'}); 
    struct('MFrom',{'M1'},'label',{'a'},'MTo',{'M2'}); 
    struct('MFrom',{'M2'},'label',{'b'},'MTo',{'M0'}); 
    struct('MFrom',{'M2'},'label',{'e'},'MTo',{'M3'}); 
    struct('MFrom',{'M3'},'label',{'b'},'MTo',{'M2'})   
};
% D={(M0,b),(M1,b),(M1,e),(M2,a),(M3,a),(M3,e)}
% 
D = struct('MFrom',{'M0','M1','M1','M2','M3','M3'},'label',{'b','b','e','a','a','e'});

flabel=containers.Map;
flabel('a') = {'t5','t6'};
flabel('b') = {'t1','t4'};
flabel('e') = {'t2','t3'};

nodeNum = 4;

[M0, I, O] = NFA2PN(m,n,Enon,Edet,D,flabel,nodeNum);