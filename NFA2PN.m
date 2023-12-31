function [M0, I, O] = NFA2PN(m,n,Enon,Edet,D,flabel,nodeNum)
% m: number of places
% n: number of transitions
% Enon: the set of enabled triples that describe the nondeterministic cases
% Edet: the set of enabled triples that describe the deterministic cases.
% D: the set of disabled pairs
% flabel: the labeling function. 
% nodeNum: the number of nodes in the NFA.  Note that these nodes must be numbered to M0,M1,M2,...
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Note that to run this program, two additional software packages should be installed and configured in advance.
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
