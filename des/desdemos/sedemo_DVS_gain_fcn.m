function gain_out = sedemo_DVS_gain_fcn(gain_in)
% Helper function of sedemo_DVS_model

% Copyright 2006 The MathWorks, Inc.

% Average inter-arrival time
global int_arr;

% x2 -- range of feasible voltage
% y2 -- corresponding cost per job
global x2;
global y2;

gain_out=gain_in;

if(gain_in~=int_arr)
    % Gain changes, update theoratical values
    int_arr=gain_in;
    lower_bound=0.12;
    upper_bound=(max([(1-int_arr/3),0.55])*int_arr);
    delta=(upper_bound-lower_bound)/50;
    theta=lower_bound:delta:upper_bound;
    x2=sedemo_DVS_2v_fcn(theta);
    y2=sedemo_DVS_cost_fcn(1/int_arr,theta);
end
    