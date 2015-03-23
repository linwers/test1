function varargout = des_releasegatemask(block, action, subaction)
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/08/29 08:22:52 $

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
    
    % Pass the MaskParamCheck array of structures to the error checking
    % sub-function
    MaskParamCheck = struct('Numeric', {idxPriorityGateRelease}, ...
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
         
        cbOpenGateUpon(block, subaction);
        cbSignalEdgeOption(block,subaction);
        cbSpecifyEventPriority(block,subaction);
        des_cbStats(block, 'StatNumberDeparted','#d',subaction);       
    end

    % Set the block position back to what it was
    set_param(block, 'position', blockPosition);

% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------

case 'cbOpenGateUpon',
    cbOpenGateUpon(block, subaction);
case 'cbSignalEdgeOption',
    cbSignalEdgeOption(block, subaction);
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
    des_def_releasegatemask(block,mfilename);
    cbOpenGateUpon(block, subaction);
    cbSignalEdgeOption(block, subaction);
    cbSpecifyEventPriority(block, subaction);
    des_cbStats(block, 'StatNumberDeparted','#d',subaction);

% --- End of case 'default'
end; % End of switch(action)
return;

function cbSignalEdgeOption(block, applyStatus)
% do nothing.
return;

% ----------------
% --- Subfunctions
% ----------------
%*********************************************************************
% Function Name:    cbOpenGateUpon
% Description:      Deal with the different Gate control modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbOpenGateUpon(block, subaction)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    En = get_param(block,'MaskEnables');
    Vis = get_param(block, 'maskvisibilities');
    Prompt = get_param(block, 'maskprompts');
    
    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    OpenGateUponOpt = Vals{idxOpenGateUpon};
     
%     Prompt{idxSpecifyEventPriority} = 'Process zero crossing:';

    switch OpenGateUponOpt,
    case 'Sample time hit from port ts'
        priority = Vals{idxPriorityGateRelease};
        [Vis{[idxSpecifyEventPriority]}]   = deal('on');
        [Vis{[idxSignalEdgeOption, idxPriorityGateRelease]}] = deal('off');

        Prompt{idxSignalEdgeOption} = 'Trigger type:';
        des_enableport(block, subaction, 'in' , 'SL', 'ts', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );
        
        des_enableport(block, subaction, 'in' , 'SL', 'tr', 'no');
        des_enableport(block, subaction, 'in' , 'FC', 'fcn', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'vc', 'no');
        
        set_param(block, 'MaskVisibilities', Vis);
        %set_param(block, 'maskprompts', Prompt);
        cbSpecifyEventPriority(block, subaction);        
            
    case 'Trigger from port tr',
        priority = Vals{idxPriorityGateRelease};
        [Vis{[idxSignalEdgeOption, idxSpecifyEventPriority]}]   = deal('on');
        [Vis{[idxPriorityGateRelease]}] = deal('off');

        Prompt{idxSignalEdgeOption} = 'Trigger type:';
        des_enableport(block, subaction, 'in' , 'SL', 'tr', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );
        
        des_enableport(block, subaction, 'in' , 'SL', 'ts', 'no');
        des_enableport(block, subaction, 'in' , 'FC', 'fcn', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'vc', 'no');
        
        set_param(block, 'MaskVisibilities', Vis);
        set_param(block, 'maskprompts', Prompt);
        cbSpecifyEventPriority(block, subaction);
        
    case 'Change in signal from port vc',
        priority = Vals{idxPriorityGateRelease};
        [Vis{[idxSignalEdgeOption, idxSpecifyEventPriority]}]   = deal('on');
        [Vis{[idxPriorityGateRelease]}] = deal('off');
        Prompt{idxSignalEdgeOption} = 'Trigger type:';
        
        des_enableport(block, subaction, 'in', 'SL', 'vc', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority);
        
        Prompt{idxSignalEdgeOption} = 'Type of change in signal value:';
        
        des_enableport(block, subaction, 'in' , 'SL', 'ts', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'tr', 'no');
        des_enableport(block, subaction, 'in' , 'FC', 'fcn', 'no');
        
        set_param(block, 'MaskVisibilities', Vis);
        % Change prompt
%         Prompt{idxSpecifyEventPriority} = 'Process signal value changes:';
        set_param(block, 'maskprompts', Prompt);
        
        cbSpecifyEventPriority(block, subaction);

    case 'Function call from port fcn',
        priority = Vals{idxPriorityGateRelease};
        [Vis{[idxSpecifyEventPriority]}]   = deal('on');
        [Vis{[idxSignalEdgeOption, idxPriorityGateRelease]}] = deal('off');
              
        des_enableport(block, subaction, 'in' , 'FC', 'fcn', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );  
        
        des_enableport(block, subaction, 'in' , 'SL', 'ts', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'tr', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'vc', 'no');
        
        set_param(block, 'MaskVisibilities', Vis);
%         set_param(block, 'maskprompts', Prompt);
        cbSpecifyEventPriority(block, subaction);        
        
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Gate firing option' ]);
    end
   
return;
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
               
    updateOpt = Vals{idxSpecifyEventPriority};
    switch updateOpt,
        case 'on',
            [Vis{[idxPriorityGateRelease]}]   = deal('on');
            [En{[idxPriorityGateRelease]}]   = deal('on');
            set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
        case 'off',
            [Vis{[idxPriorityGateRelease]}]   = deal('off');
            [En{[idxPriorityGateRelease]}]   = deal('off');
            set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
        otherwise,
            des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for gate control signal update.' ]);
        end
    return;
%     OpenGateUponOpt = Vals{idxOpenGateUpon};
    

    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables

% --- end of des_gatemask.m
