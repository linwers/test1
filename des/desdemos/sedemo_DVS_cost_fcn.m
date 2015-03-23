function J=sedemo_DVS_cost_fcn(lambda,theta)

% Copyright 2005 The MathWorks, Inc.

global w;
global c1;
global c2;
global Vt;

J=w.*c2.*(Vt./(1-c1./theta)).^2+theta./(1-lambda.*theta);