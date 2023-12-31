# FromNFAToLabeledPN
This is a repository for the paper "Identification of Labeled Petri Nets From Finite State Automata" (under review).

We here provide MATLAB codes for Example 6, the numerical example, application example 1, and appliaction example 2 of the paper.

There are five MATLAB files:
(1) NFA2PN.m     This is a matlab function that identify a Petri net according to the input arguments. It is a MATLAB implementation of the approach in this paper. 
(2) Example6.m   These are MATLAB codes used in Example 6, which calls the function 'NFA2PN.m'.
(3) NumericalExamInSection5.m   These are MATLAB codes used in the Numerical example (i.e., Section 5), which also calls the function 'NFA2PN.m'.
(4) ApplicationExample1.m     These are MATLAB codes used in Application Example 1.
(5) ApplicationExample2.m     These are MATLAB codes used in Application Example 2, which also calls the function 'NFA2PN.m'.


Note that to run this program, two additional software packages should be installed and configured in advance.
(1) Yalmip MATLAB toolbox: see https://yalmip.github.io/
(2) Gurobi solver (see https://www.gurobi.com/) and the correct setting of the Gurobi MATLAB interface
