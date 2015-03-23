function des_cbStats_obsoleted(block, paramName, portLabel, applyStatus,idxParam)
% des_cbStats - handle obsoleted statistics ports 
%
% Description:      The obsoleted statistics tab callbacks
%                   The function is intended to smooth backward
%                   incompability. It is intended for short term usage.
% Inputs:           block - current block, SubactionList
%                   paramName - name of the mask parameter from which the 
%                               desired statistics reporting state is gotten
%                   applyStatus - determines whether or not the status from
%                                 'paramName' is used to update the port's 
%                                 visibilitiy
%                   portLable - string that contain the port label. 
%                   idxParam -- the field index of the mask parameter
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
% $Revision: 1.1.6.3 $ $Date: 2009/11/13 04:16:03 $

if nargin < 5,
    str = sprintf(['Incorrect number of arguments passed to ' mfilename '.m !\n' ]);
    des_mask_error(block,'DES_MASK_Illegal_Param',str);
end

if ~is_simulink_handle(get_param(block,'handle')),
    str = sprintf(['Incorrect first argument passed to ' mfilename '.m !\n' ...
        '    The first argument must be the block handle and \n' ...
        '    The second argument must be the mask helper file name\n' ...
        '    The third argument (optional) can be the sub-action']);
    des_mask_error(block,'DES_MASK_Illegal_Param',str);
end

% Customize the warning message for mask parameter
warningID = 'ObsoletedMaskParameter';
switch paramName
    case {'StatPendingEntity'}  %pe port of queue blocks is obsoleted.
        warningMsg = ['''' block ''' no longer supports the pe signal output port. '...
            'The port will not output any value throughout the simulation.  '  ...
            'To check for entities in this block, use the #n signal output port instead.'];
end

% --- Field data
Vals = get_param(block, 'maskvalues');
Vis = get_param(block, 'maskvisibilities');
En = get_param(block,'MaskEnables');

% --- Set the field index numbers
des_setfieldindexnumbers(block);

% Determine whether the mask should be enabled or disabled. 
% NOTE: OLD and NEW values are legal (for a while)
switch get_param(block, paramName)
    case {'On'},
        des_warning(warningID, warningMsg);
        [Vis{[idxParam]}]   = deal('on'); 
        [En{[idxParam]}]   = deal('on');
        enablingAction = 'yes';
        
    case {'Before entity departure'},
        des_warning(warningID, warningMsg);
        enablingAction = 'yes';
        
    case {'After entity departure'},
        des_warning(warningID, warningMsg);
        enablingAction = 'yes';
        
    case {'Upon stop or pause'},
        des_warning(warningID, warningMsg);
        enablingAction = 'yes';
        
    case {'Off'},
       [Vis{[idxParam]}]   = deal('off'); 
       [En{[idxParam]}]   = deal('off');
       enablingAction = 'no';

    otherwise
        disp('Illegal value for an obsolete mask parameter');
        enablingAction = 'no';
end

des_enableport(block, applyStatus, 'out' , 'SL', portLabel, enablingAction);

% Realize mask visibility changes if any
set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);    

return;
