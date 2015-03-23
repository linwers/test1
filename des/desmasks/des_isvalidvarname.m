function [valid msg] = des_isvalidvarname(param)

% Copyright 2005 The MathWorks, Inc.

% Create the default message:
msg1 = 'must be a valid variable name.';
msg2 = 'Please type the following at the MATLAB command prompt';
msg3 = 'for more information:';
msg4 = 'help isvarname';
msg = [msg1 char(10) char(10) msg2 char(10) msg3 char(10) char(10) msg4];
% Return the result of isvarname
%param = deblank(param);
if(isvarname(param) && (~strcmpi(param, 'NaN')) && (~strcmpi(param,'Inf')))
    valid = 1;
else
    valid = 0;
    return;
end