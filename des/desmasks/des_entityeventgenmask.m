function varargout = des_entityeventgenmask(block, action, subaction)
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/19 07:23:19 $

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
    % Get the block position
    blockPosition =  get_param(gcb, 'position');
    
    % Create the idxParamName variables
    
     des_setfieldindexnumbers(block);
    % --- check if we are in a block update (and don't want to
    %     be called)  This reduces flicker in the mask and ports.
    b_ud = get_param(block,'userdata');
    if b_ud.in_blockupdate,
        return;
    end

    % --- call independent callback functions in block that have other
    %     callback function that depend on it.  These functions
    %     will call, in turn, the dependent callback functions.

    % Statistics (count)
    des_cbStats(block,'StatNumberDeparted','#d',subaction);
    des_cbStats(block,'StatNumberF1Calls','#f1',subaction);
    % update the function call port tag (just update to/from tag)
    des_enableport(block, subaction, 'out' , 'FC', 'f1', 'yes', ...
        'timingcontrol', 'FunctionCall');

    % Set the block position back to what it was     
    set_param(block, 'position', blockPosition);
% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbStatNumberDeparted',
    des_cbStats(block,'StatNumberDeparted','#d',subaction);    
case 'cbStatNumberF1Calls',
    des_cbStats(block,'StatNumberF1Calls','#f1',subaction);
  
%*********************************************************************
% Function Name:    'default'
% Description:      Set the block defaults (development use only)
% Inputs:           current block
% Return Values:    none
%*********************************************************************
case 'default',
    des_def_entityeventgenmask(block,mfilename);
    % Statistics (count)
    des_cbStats(block,'StatNumberDeparted','#d',subaction);
    des_cbStats(block,'StatNumberF1Calls','#f1',subaction);
% --- End of case 'default'
end; % End of switch(action)
return;

% --- end of des_entityeventgenmask.m