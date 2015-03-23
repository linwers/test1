function V=sedemo_DVS_2v_fcn(theta)

% Copyright 2005 The MathWorks, Inc.

global c1;
global Vt;

V = Vt./(1-c1./theta);

