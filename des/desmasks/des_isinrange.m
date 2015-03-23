function [inrange msg] = des_isinrange(param, paramName, limits, varargin)
% DES_ISINRANGE Checks if the input parameter falls in the range specified
% by the user. By default, the range is inclusive on both sides that is,
% the input parameter should satisfy the following condition: 
% Lower limit <= Input parameter <= Upper limit
% The user can specify the open-ness of the range by adding the string
% corresponding to one of the options 'closeboth', 'openlower', 'openupper'
% and 'openboth'
% This file helps the error checking routine des_validateinputs to check if
% the parameter value input from the mask dialog falls in the right range.
% This function is expected to be used along with the des_isvalidnumber
% function and hence the error checking for data types is not part of this
% function. 
% 
% Input Arguments: 
% param          - Parameter value
% paramName      - The name of the parameter as it appears on the mask
%                  dialog. In other words this is the prompt string
%                  corresponding to the parameter in the dialog. This
%                  string is used to create a usefule error message.
% limits         - A two element vector whose elements indicate the lower
%                  limit and upper limit of the range in that order. 
%                  e.g. [1 4] is a valid value for limits but [4 1] is not.
% varagin        - A character string indicating the range option to be
%                  used. The character string should be one of the
%                  following options:
%                  1.'closeboth': for a range closed on both ends
%                  2.'openlower': for a range open at lower limit
%                  3.'openupper': for a range open at upper limit
%                  4.'openboth' : for a range open at both ends
%                  e.g. 'openlower' will verify that the following
%                  condition holds true:
%                  Lower limit < Input parameter <= Upper limit
%                  As oppposed to 'closeboth' which checks the following
%                  Lower limit <= Input parameter <= Upper limit
% Return Values: 
% valid          - boolean indicating the success(1) or failure(0)
% msg            - a string describing the conditions on the range
%
% Example 1:
% [valid msg] = des_isinrange(0, 'Priority', [1, Inf]) returns
% valid = 0
% msg = in the range 1 <= Priority <= Inf
% 
% Example 2:
% [valid msg] = des_isinrange(Inf, 'Priority', [1, Inf], 'openupper')
% returns:
% valid = 0
% msg = in the range 1 <= Priority < Inf

% Copyright 2004-2005 The MathWorks, Inc.

LowerLimit = limits(1);
UpperLimit = limits(2);
if(LowerLimit>UpperLimit)
    msg = ['The lower limit ' num2str(LowerLimit) ' of the range ' 'should be less than or equal to the upper limit ' num2str(UpperLimit) '.'];
    des_error('DES_InvalidParam',msg);
end

% Create a default action:
if(isempty(varargin))
    action = 'closeboth';
else
    action = varargin{1};
end

switch action
    case 'closeboth'
        inrange = all(all(all([param>=LowerLimit param<=UpperLimit])));
        msg = ['in the range ' num2str(LowerLimit) ' <= ' paramName ' <= ' num2str(UpperLimit)];
    case 'openlower'
        inrange = all(all(all([param>LowerLimit param<=UpperLimit])));
        msg = ['in the range ' num2str(LowerLimit) ' < ' paramName ' <= ' num2str(UpperLimit)];
    case 'openupper'
        inrange = all(all(all([param>=LowerLimit param<UpperLimit])));
        msg = ['in the range ' num2str(LowerLimit) ' <= ' paramName ' < ' num2str(UpperLimit)];
    case 'openboth'
        inrange = all(all(all([param>LowerLimit param<UpperLimit])));
        msg = ['in the range ' num2str(LowerLimit) ' < ' paramName ' < ' num2str(UpperLimit)];
    otherwise
        des_error('DES_InvalidParam','Invalid option for des_isinrange');
end

return;