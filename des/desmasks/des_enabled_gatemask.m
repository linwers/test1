function varargout = des_enabled_gatemask(block, action, subaction)
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2008/12/04 22:28:18 $

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

    % Create the idxParamName variable
    Vals = get_param(block, 'maskvalues');
    
    des_setfieldindexnumbers(block);
    priority = Vals{idxPriorityGateEnableOpenClose};
      
    % Pass the MaskParamCheck array of structures to the error checking
    % sub-function
    MaskParamCheck = struct('Numeric', {idxPriorityGateEnableOpenClose}, ...
                             'isValid',  {'IsInt'}, ...
                             'inRange',  {[1 Inf]});  
    if(~des_validateinputs(block, MaskParamCheck))
        
        return;
    else
        % --- check if we are in a block update (and don't want to
        %     be called)  This reduces flicker in the mask and ports.
        b_ud = get_param(block,'userdata');
        if b_ud.in_blockupdate,
            return;
        end

        % --- Set Field index numbers and mask variable data
        [child childName] = des_getchildblockname(block);

        % --- call independent callback functions in block that have other
        %     callback function that depend on it.  These functions
        %     will call, in turn, the dependent callback functions.
        
        cbSpecifyEventPriority(block,subaction);
        des_cbStats(block, 'StatNumberDeparted','#d',subaction);
              
        des_enableport(block, subaction, 'in' , 'SL', 'en', 'yes', ...
          'timingcontrol', 'Simulink', 'execIndex', priority ); 
    
    end

    % Set the block position back to what it was
    set_param(block, 'position', blockPosition);

% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfacesd
%----------------------------------------------------------------------
case 'cbSpecifyEventPriority',
    cbSpecifyEventPriority(block, subaction);
case 'cbStatNumberDeparted',
    des_cbStats(block, 'StatNumberDeparted','#d',subaction);
%----------------------------------------------------------------------
%   Setup/Utility functions
%----------------------------------------------------------------------

%*********************************************************************
% Function Name:    'default'
% Description:      Set the block defaults (development use only)
% Inputs:           current block
% Return Values:    none
%*********************************************************************
case 'default',
    des_def_enabled_gatemask(block,mfilename);
    cbSpecifyEventPriority(block, subaction);
    des_cbStats(block, 'StatNumberDeparted','#d',subaction);
% --- End of case 'default'
end; % End of switch(action)
return;
% ----------------
% --- Subfunctions
% ----------------

%*********************************************************************
% Function Name:    cbSpecifyEventPriority
% Description:      Deal with the different signal level crossing handlers.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************

function cbSpecifyEventPriority(block, subaction)
 % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    
    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    updateOpt = Vals{idxSpecifyEventPriority};
  
    switch updateOpt,
        case 'on',
            [Vis{[idxPriorityGateEnableOpenClose]}]   = deal('on');
            [En{[idxPriorityGateEnableOpenClose]}]   = deal('on');
            set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
        case 'off',
            [Vis{[idxPriorityGateEnableOpenClose]}]   = deal('off');
            [En{[idxPriorityGateEnableOpenClose]}]   = deal('off');
            set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
        otherwise,
            des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for gate control signal update.' ]);
        end
    return;

% --- end of des_gatemask.m
