function varargout = des_toworkspacemask(block, action)
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/23 20:28:42 $

%*********************************************************************
% --- Action switch -- Determines which of the callback functions is called
%*********************************************************************

switch(action)
%*********************************************************************
% Function Name:     init
% Description:       Main initialization code
% Inputs:            current block and any parameters from the mask
%                    required for parameter calculation.
% Return Values:     params - Parameter structure
%********************************************************************
case 'init',
     % Create the idxParamName variables
    des_setallfieldvalues(block);
    MaskParamCheck{1} = struct('Numeric', {idxMaxDataPoints, idxDecimation}, ...
                             'isValid',  {'IsInt',        'IsInt'    }, ...
                             'inRange',  {[1 Inf],        [1 Inf]    });
    MaskParamCheck{2} = struct('CharString', {idxVariableName});
    
    % Pass the MaskParamCheck array of structures to the error checking
    % sub-function
    if(~des_validateinputs(block, MaskParamCheck))
        return;
    else
        set_toworkspace_params(block);
    end
% --- End of case 'init'
%----------------------------------------------------------------------
%   Setup/Utility functions
%----------------------------------------------------------------------
%*********************************************************************
% Case:             'default'
% Description:      Set the block defaults (development use only)
% Inputs:           current block
% Return Values:    none
%*********************************************************************
case 'default',
    des_def_toworkspacemask(block,mfilename);
    set_toworkspace_params(block);
% --- End of case 'default'
end; % End of switch(action)

% --- end of des_basicqueuemask.m

% Helper functions
function set_toworkspace_params(block)
% This function sets the parameters for the underlying SL To Workspace
% block.
set_param([block,'/To Workspace'], 'VariableName', get_param(block, 'VariableName'));
set_param([block,'/To Workspace'], 'MaxDataPoints', get_param(block, 'MaxDataPoints'));
set_param([block,'/To Workspace'], 'Decimation', get_param(block, 'Decimation'));
set_param([block, '/To Workspace'], 'SaveFormat', get_param(block, 'SaveFormat'));