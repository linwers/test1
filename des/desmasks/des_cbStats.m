function des_cbStats(block, paramName, portLabel, applyStatus);
% des_cbStats - sets/resets statistics based ports
%
% Description:      The statistics tab callbacks
% Inputs:           block - current block, SubactionList
%                   paramName - name of the mask parameter from which the 
%                               desired statistics reporting state is gotten
%                   applyStatus - determines whether or not the status from
%                                 'paramName' is used to update the port's 
%                                 visibilitiy
%                   portLable - string that contain the port label. 
%
%    Mapping of mask parameter values to port enabling
%    paramName               enabling action
%    ========================================
%    On                      yes
%    Before entity departure yes
%    After entity departure  yes
%    Upon stop or pause      yes
%    Off                     no
%    To Attribute            no
%    <Unrecognized>          no (and warning)
    
% Return Values:    none
% Modified Values:  Modified Value, Visibility and Enable cell arrays

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/01/20 15:30:26 $

if nargin < 2,
    str = sprintf(['Incorrect number of arguments passed to ' mfilename '.m !\n' ...
        '    The first argument must be the block handle and \n' ...
        '    The second argument must bea list of the subactions\n']);
    des_mask_error(block,'DES_MASK_Illegal_Param',str);
end

if ~is_simulink_handle(get_param(block,'handle')),
    str = sprintf(['Incorrect first argument passed to ' mfilename '.m !\n' ...
        '    The first argument must be the block handle and \n' ...
        '    The second argument must be the mask helper file name\n' ...
        '    The third argument (optional) can be the sub-action']);
    des_mask_error(block,'DES_MASK_Illegal_Param',str);
end

% Determine whether the mask should be enabled or disabled. 
% NOTE: OLD and NEW values are legal (for a while)
switch get_param(block, paramName)
    case {'On'},
        enablingAction = 'yes';
        
    case {'Before entity departure'},
        enablingAction = 'yes';
        
    case {'After entity departure'},
        enablingAction = 'yes';
        
    case {'Upon stop or pause'},
        enablingAction = 'yes';
        
    case {'Off'},
        enablingAction = 'no';
        
    case 'To attribute'
        enablingAction = 'no';
        
    otherwise
        disp('Illegal value for Number of Entities Served');
        enablingAction = 'no';
end

des_enableport(block, applyStatus, 'out' , 'SL', portLabel, enablingAction);

return;
