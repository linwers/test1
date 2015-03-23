function sedemo_DVS_plot_fcn(theta)

% Copyright 2005-2006 The MathWorks, Inc.

% Average inter-arrival time
global int_arr;

% History data
global x1;
global y1;
global x2;
global y2;

% Handler for plot window
global FigureHdl;

% Convert to arrival rate
lambda=1/int_arr;

% Append sample path
new_x=sedemo_DVS_2v_fcn(theta);
new_y=sedemo_DVS_cost_fcn(lambda,theta);
x1=[x1,new_x];
y1=[y1,new_y];

% Update plot every 200 samples
% (adjust this num will affect the speed
%  of simulation)
cur_size=size(x1);
if(mod(cur_size(2),200)==0)  
    figure(FigureHdl);
    plot(x2,y2,'r-.',x1,y1,'b-',new_x,new_y,'b^');
    hold off;
    xlabel('Input Voltage (volt)');
    ylabel('Cost per Job');
    title('Input Voltage under DVS Control');
    grid on;
end
