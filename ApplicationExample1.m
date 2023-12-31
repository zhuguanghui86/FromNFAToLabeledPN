% MATLAB codes for Application Example 1
% Note that we simply modify the NFA2PN function and the new function is NFA2PNApplicationExampleOne( ).
% Please see Line 50 for the implemetation of function NFA2PNApplicationExampleOne( ).

m = 9;
n = 6;

% Enon = empty set
Enon = {};
% Edet = {
%             {(M0,a,M1)},
%             {(M0,d,M2)},
%             {(M1,b,M3)},
%             {(M2,e,M4)},
%             {(M3,c,M0)},
%             {(M4,f,M0)}
% }
Edet = {
    struct('MFrom',{'M0'},'label',{'a'},'MTo',{'M1'}); 
    struct('MFrom',{'M0'},'label',{'d'},'MTo',{'M2'}); 
    struct('MFrom',{'M1'},'label',{'b'},'MTo',{'M3'}); 
    struct('MFrom',{'M2'},'label',{'e'},'MTo',{'M4'}); 
    struct('MFrom',{'M3'},'label',{'c'},'MTo',{'M0'}); 
    struct('MFrom',{'M4'},'label',{'f'},'MTo',{'M0'})   
};
% D={
%             (M0,b),(M0,c),(M0,e),(M0,f),
%             (M1,a),(M1,c),(M1,d),(M1,e),(M1,f)
%             (M2,a),(M2,b),(M2,c),(M2,d),(M2,f)
%             (M3,a),(M3,b),(M3,d),(M3,e),(M3,f)
%             (M4,a),(M4,b),(M4,c),(M4,d),(M4,e)
%             }
% 
D = struct('MFrom',{'M0','M0','M0','M0','M1','M1','M1','M1','M1','M2','M2','M2','M2','M2','M3','M3','M3','M3','M3','M4','M4','M4','M4','M4'},'label',{'b','c','e','f','a','c','d','e','f','a','b','c','d','f','a','b','d','e','f', 'a','b','c','d','e'});

flabel=containers.Map;
flabel('a') = {'t1'};
flabel('b') = {'t2'};
flabel('c') = {'t3'};
flabel('d') = {'t4'};
flabel('e') = {'t5'};
flabel('f') = {'t6'};

nodeNum = 5;

[M0, I, O] = NFA2PNApplicationExampleOne(m,n,Enon,Edet,D,flabel,nodeNum);



% This function is for Application Example 1 only since we need to restrict
% the structure of a sub-net of the identified in this example.
function [M0, I, O] = NFA2PNApplicationExampleOne(m,n,Enon,Edet,D,flabel,nodeNum)
% m: number of places
% n: number of transitions
% Enon: the set of enabled triples that describe the nondeterministic cases
% Edet: the set of enabled triples that describe the deterministic cases.
% D: the set of disabled pairs
% flabel: the labeling function. 
% nodeNum: the number of nodes in the NFA.  Note that these nodes must be numbered to M0,M1,M2,...
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Note that to run this program, two additional software should be installed and configured in advance.
%     (1) Yalmip MATLAB toolbox: see https://yalmip.github.io/
%     (2) Gurobi solver (see https://www.gurobi.com/) and the correct setting of the Gurobi MATLAB interface
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



% ---- Constraint set (a) in Eq. (4)-------%
markings = {};
for i = 1:nodeNum
    markings{i} = intvar(m,1);
end
Ix = intvar(m,n,'full');
Ox = intvar(m,n,'full');
% --------------------end-------------------%

K = 1000;
Kv = ones(m,1)*1000;

tvectors = {};
for i = 1:n
    v = zeros(n,1);
    v(i) = 1;
    tvectors{i} = v;
end


M0x = markings{1};
F = [M0x >=0, Ix >=0, Ox >=0];

% ---- Constraint set (b) of Eq. (4)-------%
for i = 1:nodeNum-1
    for j = i+1:nodeNum
        binv1 = binvar(m,1);
        binv2 = binvar(m,1);
        F = [F, markings{i} - markings{j} - ones(m,1) + binv1*K >=0];
        F = [F, markings{i} - markings{j} + ones(m,1) - binv2*K <=0];
        F = [F, ones(1,m)*(binv1+binv2) == 2*m-1];
    end
end
% --------------------end-------------------%

% ---- Constraint set (c) of Eq. (4)-------%
EnonLen = length(Enon);
for i=1:EnonLen
       nonArr = Enon{i};
       h = length(nonArr);
       nonElem = nonArr(1);
       label = nonElem.label;
       tranArr = flabel(label);
       ne = length(tranArr);
       
       MFrom = nonElem.MFrom;
       MFromIndex = str2double(strrep(MFrom,'M',''))+1;
       MFromVar = markings{MFromIndex};
       
       bvecs={};
       for j = 1:h % Constraint set (c.1) 
           nonElem = nonArr(j);
           MTo = nonElem.MTo;
           MToIndex = str2double(strrep(MTo,'M',''))+1;
           MToVar = markings{MToIndex};
           
           bvec = binvar(ne,1);
           bvecs{j} = bvec;
           
           for k = 1:ne
                tran = tranArr{k};
                tnum = str2double(strrep(tran,'t',''));
                F = [F,MFromVar - Ix*tvectors{tnum} >= -bvec(k)*Kv];
                F = [F,MToVar - MFromVar - Ox*tvectors{tnum} + Ix*tvectors{tnum} <= bvec(k)*Kv];
                F = [F,MToVar - MFromVar - Ox*tvectors{tnum} + Ix*tvectors{tnum} >= -bvec(k)*Kv];
           end
            
            F = [F,sum(bvec) == ne-1];
       end
       
       bvecsSum = bvecs{1};
        for j = 2:h
            bvecsSum = bvecsSum + bvecs{j};
        end
        
        for k = 1:ne % Constraint set (c.2) 
            tran = tranArr{k};
            tnum = str2double(strrep(tran,'t',''));
            
            SBarVec = binvar(m,1);
            F = [F,-K*SBarVec + MFromVar - Ix*tvectors{tnum} <= -1];
            F = [F,sum(SBarVec) <= m + (h-bvecsSum(k))-1];
        end
end
% --------------------end-------------------%

% ---- Constraint set (d) of Eq. (4)-------%
EdetLen = length(Edet);
for i=1:EdetLen
    detArr = Edet{i};
    detElem = detArr(1);
    label = detElem.label;
    tranArr = flabel(label);
    ne = length(tranArr);

    MFrom = detElem.MFrom;
    MFromIndex = str2double(strrep(MFrom,'M',''))+1;
    MFromVar = markings{MFromIndex};
    MTo = detElem.MTo;
    MToIndex = str2double(strrep(MTo,'M',''))+1;
    MToVar = markings{MToIndex};
    
    bvec = binvar(ne,1);
    
    for k = 1:ne % Constraint set (d.1) 
        tran = tranArr{k};
        tnum = str2double(strrep(tran,'t',''));
        F = [F,MFromVar - Ix*tvectors{tnum} >= -bvec(k)*Kv];
        F = [F,MToVar - MFromVar - Ox*tvectors{tnum} + Ix*tvectors{tnum} <= bvec(k)*Kv];
        F = [F,MToVar - MFromVar - Ox*tvectors{tnum} + Ix*tvectors{tnum} >= -bvec(k)*Kv];
    end
    F = [F,sum(bvec) == ne-1];
    
    for k = 1:ne % Constraint set (d.2) 
        tran = tranArr{k};
        tnum = str2double(strrep(tran,'t',''));

        SBarVec = binvar(m,1);
        F = [F,-K*SBarVec + MFromVar - Ix*tvectors{tnum} <= -1];
        F = [F,sum(SBarVec) <= m - bvec(k)];
    end
end
% --------------------end-------------------%

% ---- Constraint set (e) of Eq. (4)-------%
DLen = length(D);
for i=1:DLen
    dElem = D(i);
    label = dElem.label;
    tranArr = flabel(label);
    ne = length(tranArr);

    MFrom = dElem.MFrom;
    MFromIndex = str2double(strrep(MFrom,'M',''))+1;
    MFromVar = markings{MFromIndex};
    
    for k = 1:ne
        SBar = binvar(m,1);
        tran = tranArr{k};
        tnum = str2double(strrep(tran,'t',''));
        F = [F,MFromVar - Ix*tvectors{tnum} <= K*SBar - 1];
        F = [F, sum(SBar) <= m-1];
    end
end
% --------------------end-------------------%

%========== To restrict a sub-net of the identified net to be exactly the the given S3PR.===============
I_Init = [
1,0,0,0,0,0;
0,1,0,0,0,0;
0,0,1,0,0,0;
0,0,0,1,0,0;
0,0,0,0,1,0;
0,0,0,0,0,1;
1,0,0,0,1,0;
0,1,0,1,0,0];
O_Init = [
0,0,1,0,0,0;
1,0,0,0,0,0;
0,1,0,0,0,0;
0,0,0,0,0,1;
0,0,0,1,0,0;
0,0,0,0,1,0;
0,1,0,0,0,1;
0,0,1,0,1,0
];
M0_Init = [1,0,0,1,0,0,1,1]';

F = [F, Ix(1:m-1,1:n) == I_Init];
%F = [F, Prex(m,1:n-1) == [1,0,0,1,0]];
F = [F, Ox(1:m-1,1:n) ==O_Init];
%F = [F, Postx(m,1:n-1) == [0,1,0,0,1]];
F = [F, M0x(1:m-1) ==M0_Init];




% The following constraints can be used to restrict the structure of the identified net
% Constraint 1: Each place has at least an outgoing arc, i.e., p->
%F = [F, Ix*ones(n,1) >= 1];
% Constraint 2: Each transition has at least an input arc, i.e., ->t
%F = [F, transpose(Ix)*ones(m,1) >= 1];
% Constraint 3: Each transition has at least an outgoing arc, i.e., t->
%F = [F, transpose(Postx)*ones(m,1) >= 1];

% An objective function that minimize the total weight of all arcs and the number of tokens in M0
objective = ones(1,m)*M0x+ones(1,m)*(Ix+Ox)*ones(n,1);

% We use Gurobi Solver
% Please see https://www.gurobi.com/
options = sdpsettings('solver','gurobi', 'verbose',1);
optimize(F, objective, options);
M0 = value(M0x);
I = value(Ix);
O = value(Ox);
end
