function sedemo_DVS_init_fcn

% Copyright 2005-2006 The MathWorks, Inc.

% Weight parameter for energy
% e.g. 100 indicates that we treat
% 100ms processing delay and 1mJ Energy
% usage as a same amount of cost
global w;

% Physical parameters of micro-processor
% c1, c2, Vt are hardware related constant
global c1;
global c2;
global Vt;

% Average inter-arrival time
% it shall have been initialized in 
% the init callback of Constant
global int_arr;  

% Simulation results
% x1 -- current voltage
% y1 -- current cost per job
global x1;
global y1;

% x2 -- range of feasible voltage
% y2 -- corresponding cost per job
global x2;
global y2;

% Device related constants
w=100;
c1=0.0833;
c2=0.4167e-3;
Vt=2;

% Clear x1 and y1
x1=[];
y1=[];

% range of feasible average service time
% (per Million operation)
lower_bound=0.12;
upper_bound=(max([(1-int_arr/3),0.55])*int_arr);
delta=(upper_bound-lower_bound)/50;
theta=lower_bound:delta:upper_bound;
x2=sedemo_DVS_2v_fcn(theta);
y2=sedemo_DVS_cost_fcn(1/int_arr,theta);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
