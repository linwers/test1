function varargout = des_entityfcncallmask(block, action, subaction)
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/07 18:26:19 $

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

    % Enable/Disable the enable port
    cbEnableEPort(block,subaction, 1);
    % Statistics (count)
    des_cbStats(block,'StatNumberDeparted','#d',subaction);
    des_cbStats(block, 'StatNumberF1Calls','#f1',subaction);
    des_cbStats(block, 'StatNumberF2Calls','#f2',subaction);
    % update the function call port tag (just update to/from tag)
    des_enableport(block, subaction, 'out' , 'FC', 'f1', 'yes', ...
        'timingcontrol', 'FunctionCall');
    % Enable/Disable the second function call port
    cbEnableF2Port(block,subaction);
    % update based on function call options
    cbFcnCallUpon(block,subaction);

    % Set the block position back to what it was     
    set_param(block, 'position', blockPosition);
% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbFcnCallUpon',
    cbFcnCallUpon(block,subaction);    
case 'cbEnableE1Port',
    cbEnableEPort(block,subaction,1);
case 'cbEnableE2Port',
    cbEnableEPort(block,subaction,2);    
case 'cbEnableF2Port',
    cbEnableF2Port(block,subaction);
case 'cbStatNumberDeparted',
    des_cbStats(block,'StatNumberDeparted','#d',subaction);    
case 'cbStatNumberF1Calls',
    des_cbStats(block, 'StatNumberF1Calls','#f1',subaction);
case 'cbStatNumberF2Calls',
    des_cbStats(block, 'StatNumberF2Calls','#f2',subaction);
    
    
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
    des_def_entityfcncallmask(block,mfilename);
    % Enable/Disable the enable port
    cbEnableEPort(block,subaction, 1);
    % Statistics (count)
    des_cbStats(block,'StatNumberDeparted','#d',subaction);
    des_cbStats(block, 'StatNumberF1Calls','#f1',subaction);
    des_cbStats(block, 'StatNumberF2Calls','#f2',subaction);
    % Enable/Disable the second function call port
    cbEnableF2Port(block,subaction);
    % update based on function call options
    cbFcnCallUpon(block,subaction);
% --- End of case 'default'
end; % End of switch(action)
return;

% ----------------
% --- Subfunctions
% ----------------

%*********************************************************************
% Function Name:    cbEnableEPort
% Description:      enables the enable port.
% Inputs:           current block, applyStatus
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbEnableEPort(block, applyStatus, enablePortNumber)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    EnablePortIdx = [idxEnableE1Port idxEnableE2Port];
    EnableEPort = Vals{EnablePortIdx(enablePortNumber)};
      
       
    switch EnableEPort,
    case 'on',
        des_enableport(block, applyStatus, 'in' , 'SL', ['e' num2str(enablePortNumber)], 'yes');
    case 'off',
        des_enableport(block, applyStatus, 'in' , 'SL', ['e' num2str(enablePortNumber)], 'no');
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Enabling the Enable port' ]);
    end
return;

%*********************************************************************
% Function Name:    cbEnableF2Port
% Description:      enables the second function call port.
% Inputs:           current block, applyStatus
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbEnableF2Port(block, applyStatus)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En =  get_param(block, 'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    switch Vals{idxEnableF2Port},
        case 'on',
            Vis{idxEnableE2Port} = 'on';
            En{idxStatNumberF2Calls} = 'on';
            if(strcmp(Vals{idxTimingFunctionCallF1},'Before entity departure'))
               Vis{idxTimingFunctionCallF2} = 'on';
               En{idxTimingFunctionCallF2} = 'on';               
            else
               Vis{idxTimingFunctionCallF2} = 'off';
               En{idxTimingFunctionCallF2} = 'off';               
               if strcmp(applyStatus,'apply');
                   Vals{idxTimingFunctionCallF2} = 'After entity departure';
                   set_param(block, 'MaskValues', Vals);
               end
            end
            des_enableport(block, applyStatus, 'out' , 'FC', 'f2', 'yes', ...
                'timingcontrol', 'FunctionCall');
        case 'off',
            Vis{idxEnableE2Port} = 'off';
            En{idxStatNumberF2Calls} = 'off';
            des_enableport(block, applyStatus, 'out' , 'FC', 'f2', 'no');
            Vis{idxTimingFunctionCallF2} = 'off';
            En{idxTimingFunctionCallF2} = 'off';               
            if(strcmp(applyStatus,'apply'))
                Vals{idxStatNumberF2Calls} = 'Off';
                Vals{idxEnableE2Port} = 'off';
                set_param(block, 'MaskValues', Vals);
            end
        otherwise,
    		des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Enabling the Enable port' ]);
    end
        set_param(block, 'MaskVisibilities', Vis, 'MaskEnables',En);
        cbEnableEPort(block,applyStatus, 2);
        des_cbStats(block, 'StatNumberF2Calls','#f2',applyStatus);        
return;

%*********************************************************************
% Function Name:    cbFcnCallUpon
% Description:      Update dialog from function call options.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbFcnCallUpon(block, subaction)
    % Call dependent callabacks 
    cbEnableF2Port(block, subaction);
return;
% --- end of des_entityfcncallmask.m