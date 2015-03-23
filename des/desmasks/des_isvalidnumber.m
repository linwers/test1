function [valid msg] = des_isvalidnumber(param, check)
% DES_ISVALIDNUMBER Validates the input parameter against the criteria
% specified by the user. This file helps the error checking routine
% des_validateinputs to check the data type of the parameter input from the
% the mask dialog. The following checks are always performed:
% 1. Is numeric
% 2. Is scalar
% 3. Is NOT NaN
% 4. Is NOT empty 
% 
% Input Arguments: 
% param          - parameter value
% check          - The criterion to be checked. Currently there are
%                  following two options:
%                  1. 'IsInt': Check if the input parameter is integer
%                  valued
%                  2. 'IsReal': Check if the input parameter is real valued
% 
% Return Values: 
% valid          - boolean indicating the success(1) or failure(0)
% msg            - a string describing the conditions on the data type
%                  e.g. 'must be a scalar integer' or 
%                  'must be a real scalar' etc.
%
% Example:
% [valid msg] = des_isvalidnumber(1.5, 'IsInt')

% Copyright 2004-2005 The MathWorks, Inc.



switch(check)
%*********************************************************************
% Function Name:     IsInt
% Description:       Check if integer valued
% Inputs:            parameter
% Return Values:     validity and error message
%********************************************************************
case 'IsInt',
    % Create the default message:
    msg = 'must be a scalar number';
    % Check the default conditions to be satisfied. Return if one or more fail
    % Assign appropriate value to the return value: valid 
    if(isnumeric(param)&&isscalar(param)&&(~isnan(param))&&(~isempty(param)))
        valid = 1;
    else
        valid = 0;
        return;
    end
    % --- Check if the number is an integer:
    if(des_isvalinteger(param))
        valid = 1;
    else
        valid = 0;
    end
    msg = 'must be a scalar integer'; ;
%*********************************************************************
% Function Name:     IsReal
% Description:       Check if real valued scalar
% Inputs:            parameter
% Return Values:     validity and error message
%********************************************************************
case 'IsReal'
    % Create the default message:
    msg = 'must be a scalar number';
    % Assign appropriate value to the return value: valid 
    if(isnumeric(param)&&isscalar(param)&&(~isnan(param))&&(~isempty(param)))
        valid = 1;
    else
        valid = 0;
        return;
    end
    % --- Check if the number is an integer:
    if(isreal(param))
        valid = 1;
    else
        valid = 0;
    end
    msg = 'must be a real scalar'; 
%*********************************************************************
% Function Name:     IsReal
% Description:       Check if real valued - don't check for scalar
% Inputs:            parameter
% Return Values:     validity and error message
%********************************************************************
case 'IsRealNonScalar'
    % Create the default message:
    msg = 'must contain real valued elements';
    % Assign appropriate value to the return value: valid 
    if(isnumeric(param)&&(isempty(find(isnan(param))))&&(~isempty(param)))
        valid = 1;
    else
        valid = 0;
        return;
    end
    % --- Check if the number is real:
    if(isreal(param))
        valid = 1;
    else
        valid = 0;
    end
case 'IsNonScalar'
    % Create the default message:
    msg = 'must contain numeric elements';
    % Assign appropriate value to the return value: valid 
    if(isnumeric(param)&&(isempty(find(isnan(param))))&&(~isempty(param)))
        valid = 1;
    else
        valid = 0;
        return;
    end
end
    