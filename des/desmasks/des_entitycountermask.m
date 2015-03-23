function varargout = des_entitycountermask(block, action, subaction)
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/11/13 04:16:04 $

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
    blockPosition =  get_param(block, 'position');
  
    % Create the idxParamName variables
    des_setfieldindexnumbers(block);
    MaskParamCheck{1} = struct('CharString', {idxNumberDepartedAttributeName});
    MaskParamCheck{2} = struct('Numeric',{idxPriorityEntityCounterReset}, ...
                             'isValid'  ,{'IsInt'    }, ...
                             'inRange'  ,{[1 Inf]    });
    % Pass the MaskParamCheck array of structures to the error checking
    % sub-function
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
        cbNumberDepartedToSignal(block, subaction);
        cbNumberDepartedToAttribute(block);
        cbCounterResetTypeOption(block, subaction);
        cbSpecifyEventPriority(block, subaction);
    end
    
    % Set the block position back to what it was     
    set_param(block, 'position', blockPosition);
    
% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------

case 'cbNumberDepartedToSignal',
    cbNumberDepartedToSignal(block, subaction);
case 'cbNumberDepartedToAttribute',
    cbNumberDepartedToAttribute(block);
case 'cbCounterResetTypeOption',
    cbCounterResetTypeOption(block, subaction)
case 'cbSpecifyEventPriority'
    cbSpecifyEventPriority(block, subaction);
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
    des_def_entitycountermask(block,mfilename);
    cbNumberDepartedToSignal(block, subaction);
    cbNumberDepartedToAttribute(block);
    cbCounterResetTypeOption(block, subaction);
    cbSpecifyEventPriority(block, subaction);

% --- End of case 'default'
end; % End of switch(action)
return;
% ----------------
% --- Subfunctions
% ----------------

%*********************************************************************
% Function Name:    cbNumberDepartedToSignal
% Description:      Deal with the different Attribute Source modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbNumberDepartedToSignal(block, applyStatus)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    NumberDepartedToSignal = Vals{idxNumberDepartedToSignal};
    PortLabel = '#d';

    switch NumberDepartedToSignal,

    case 'Off',
        des_enableport(block, applyStatus, 'out' , 'SL', PortLabel, 'no');

    case 'On',
        des_enableport(block, applyStatus, 'out' , 'SL', PortLabel, 'yes');

    case 'Upon stop or pause',
    	des_enableport(block, applyStatus, 'out' , 'SL', PortLabel, 'yes');

    otherwise,
	 des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for a statistic' ]);
    end
return;

%*********************************************************************
% Function Name:    cbNumberDepartedToAttribute
% Description:      Deal with the different Attribute Source modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbNumberDepartedToAttribute(block)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    NumberDepartedToAttribute = Vals{idxNumberDepartedToAttribute};

    switch NumberDepartedToAttribute,

    case 'On',
        [Vis{[idxNumberDepartedAttributeName, idxCreateAttribute]}]   = deal('on');
        [En{[idxNumberDepartedAttributeName, idxCreateAttribute]}]   = deal('on');
    case 'Off',
        [Vis{[idxNumberDepartedAttributeName, idxCreateAttribute]}]   = deal('off');
        [En{[idxNumberDepartedAttributeName, idxCreateAttribute]}]   = deal('off');
    otherwise,
	 des_mask_error(block, 'DES_InvalidParameter',['Illegal value for Action on missing attribute' ]);
    end

    % No dependent callabacks -- just set the visibilities and leave
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
return;
%*********************************************************************
% Function Name:    cbCounterResetTypeOption
% Description:      Deal with the different trigger types (SL or DES).
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbCounterResetTypeOption(block, applyStatus)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');
    Prompts = get_param(block, 'MaskPrompts');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    PriorityEntityCounterReset = Vals{idxPriorityEntityCounterReset};

    CounterResetTypeOption = Vals{idxCounterResetTypeOption};
    PortLabel1 = 'ts';
    PortLabel2 = 'tr';
    PortLabel3 = 'vc';
    PortLabel4 = 'fcn';
    switch CounterResetTypeOption,
    case 'Sample time hit from port ts',
        [Vis{[idxSpecifyEventPriority idxCounterResetEdgeOption]}] = deal('on', 'off');
        [En{[idxSpecifyEventPriority idxCounterResetEdgeOption]}] = deal('on','off');
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel1, 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel2, 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel3, 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        des_enableport(block, applyStatus, 'in' , 'FC', PortLabel4, 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En, 'MaskPrompts', Prompts);
        cbSpecifyEventPriority(block, applyStatus);
        return;
    case 'Trigger from port tr',
        [Vis{[idxSpecifyEventPriority idxCounterResetEdgeOption]}] = deal('on');
        [En{[idxSpecifyEventPriority idxCounterResetEdgeOption]}] = deal('on');
        Prompts{idxCounterResetEdgeOption} = deal('Trigger type:');
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel1, 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel2, 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel3, 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        des_enableport(block, applyStatus, 'in' , 'FC', PortLabel4, 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En, 'MaskPrompts', Prompts);
        cbSpecifyEventPriority(block, applyStatus);
        return;
   case 'Change in signal from port vc',
        [Vis{[idxSpecifyEventPriority idxCounterResetEdgeOption]}] = deal('on');
        [En{[idxSpecifyEventPriority idxCounterResetEdgeOption]}] = deal('on');
        Prompts{idxCounterResetEdgeOption} = deal('Type of change in signal value:');
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel2, 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel1, 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel3, 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        des_enableport(block, applyStatus, 'in' , 'FC', PortLabel4, 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En, 'MaskPrompts', Prompts);
        cbSpecifyEventPriority(block, applyStatus);
        return;
    case 'Function call from port fcn',
        [Vis{[idxSpecifyEventPriority idxCounterResetEdgeOption]}] = deal('on','off');
        [En{[idxSpecifyEventPriority idxCounterResetEdgeOption]}] = deal('on','off');
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel1, 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel2, 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel3, 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        des_enableport(block, applyStatus, 'in' , 'FC', PortLabel4, 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En, 'MaskPrompts', Prompts);
        cbSpecifyEventPriority(block, applyStatus);
        return;
    case 'Off',
        [Vis{[idxSpecifyEventPriority idxPriorityEntityCounterReset idxCounterResetEdgeOption]}]   = deal('off');
        [En{[idxSpecifyEventPriority idxPriorityEntityCounterReset idxCounterResetEdgeOption]}]   = deal('off');
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel1, 'no');
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel2, 'no');
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel3, 'no');
        des_enableport(block, applyStatus, 'in' , 'FC', PortLabel4, 'no');
        set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
        return;
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Reset Trigger' CounterResetTypeOption ]);
    end

    % No dependent callabacks --
return;
%*********************************************************************
% Function Name:    cbCounterResetEdgeOption
% Description:      Deal with the different Attribute Source modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbCounterResetEdgeOption(block, applyStatus)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    PriorityEntityCounterReset = Vals{idxPriorityEntityCounterReset};

    CounterResetEdgeOption = Vals{idxCounterResetEdgeOption};
    PortLabel = 'rst';

    switch CounterResetEdgeOption,

    case {'Rising', 'Falling', 'Either'},
        [Vis{[idxSpecifyEventPriority idxCounterResetEdgeOption]}] = deal('on');
        [En{[idxSpecifyEventPriority idxCounterResetEdgeOption]}] = deal('on');
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel, 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', PriorityEntityCounterReset );
        set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
        cbSpecifyEventPriority(block, applyStatus);
        return;
    case 'Off',
        [Vis{[idxSpecifyEventPriority idxPriorityEntityCounterReset]}]   = deal('off');
        [En{[idxSpecifyEventPriority idxPriorityEntityCounterReset]}]   = deal('off');
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel, 'no');
        set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
        return;
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Reset Trigger ' CounterResetEdgeOption]);
    end

    % No dependent callabacks --
return;

%*********************************************************************
% Function Name:    cbSpecifyEventPriority
% Description:      Deal with the different kinds of Input ports.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbSpecifyEventPriority(block, applyStatus)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');
    Prompts = get_param(block, 'maskprompts');
    ResetSignalType = get_param(block, 'CounterResetTypeOption');
      
    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    % Execute this callback only if the selection criterion is 'From
    % Simulink'
    Reset = Vals{idxCounterResetTypeOption};

    if(strcmp(Reset,'Off'))
        return;
    end


    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    updateOpt = Vals{idxSpecifyEventPriority};

    switch updateOpt,
    case 'on',
        [Vis{[idxPriorityEntityCounterReset]}]   = deal('on');
        [En{[idxPriorityEntityCounterReset]}]   = deal('on');
    case 'off',
        [Vis{[idxPriorityEntityCounterReset ]}]   = deal('off');
        [En{[idxPriorityEntityCounterReset ]}]   = deal('off');
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for reset signal handling ' updateOpt ]);
    end

    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
    return;

% --- end of des_entitycountermask.m
