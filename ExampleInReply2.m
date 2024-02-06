% MATLAB Code for the example in the response letter.
m = 3;
n = 3;

% Enon = empty set
Enon = {};
% Edet = {
%             {(M0,a,M1)},
%             {(M1,a,M2)}, 
%             {(M1,b,M5)}, 
%             {(M2,a,M3)},
%             {(M2,b,M6)},
%             {(M3,a,M4)},
%             {(M3,b,M8)},
%             {(M6,b,M7)}
% }
Edet = {
    struct('MFrom',{'M0'},'label',{'a'},'MTo',{'M1'}); 
    struct('MFrom',{'M1'},'label',{'a'},'MTo',{'M2'}); 
    struct('MFrom',{'M1'},'label',{'b'},'MTo',{'M5'}); 
    struct('MFrom',{'M2'},'label',{'a'},'MTo',{'M3'}); 
    struct('MFrom',{'M2'},'label',{'b'},'MTo',{'M6'}); 
    struct('MFrom',{'M3'},'label',{'a'},'MTo',{'M4'}); 
    struct('MFrom',{'M3'},'label',{'b'},'MTo',{'M8'}); 
    struct('MFrom',{'M6'},'label',{'b'},'MTo',{'M7'})
    
};
% D={(M0,b),(M4,a),(M4,b),(M5,a),(M5,b),(M6,a),(M7,a),(M7,b),(M8,a),(M8,b)}
% 
D = struct('MFrom',{'M0','M4','M4','M5','M5','M6','M7','M7','M8','M8'},'label',{'b','a','b','a','b','a','a','b','a','b'});

flabel=containers.Map;
flabel('a') = {'t1'};
flabel('b') = {'t2','t3'};

nodeNum = 9;

[M0, I, O] = NFA2PN(m,n,Enon,Edet,D,flabel,nodeNum);