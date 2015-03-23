function varargout = des_fcncallmask(block, action, subaction)
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2008/12/04 22:28:19 $

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
     MaskParamCheck = struct('Numeric', {idxPriorityFunctionCall, idxDelayFunctionCall}, ...
                             'isValid',  {'IsInt',       'IsReal'}, ...
                             'inRange',  {[1 Inf],        [0 Inf]});                
 
     % Pass the MaskParamCheck array of structures to the error checking
     % sub-function
     if(des_validateinputs(block, MaskParamCheck));
         % --- check if we are in a block update (and don't want to
         %     be called)  This reduces flicker in the mask and ports.
         b_ud = get_param(block,'userdata');
         if b_ud.in_blockupdate,
             return;
         end
        % --- relinking reinitialization
     end

    % --- call independent callback functions in block that have other
    %     callback function that depend on it.  These functions
    %     will call, in turn, the dependent callback functions.

    % Enable/Disable the enable port
    cbEnableEPort(block,subaction, 1);
    % Statistics (count)
    des_cbStats(block, 'StatNumberF1Calls','#f1',subaction);
    des_cbStats(block, 'StatNumberF2Calls','#f2',subaction);
    % update the function call port tag (just update to/from tag)
    des_enableport(block, subaction, 'out' , 'FC', 'f1', 'yes', ...
        'timingcontrol', 'FunctionCall');
    % Enable/Disable the second function call port
    cbEnableF2Port(block,subaction);
    % update based on function call options
    cbFcnCallUpon(block,subaction);
    % update based on SpecifyEventPriority options
    cbSpecifyEventPriority(block,subaction);
    cbFcnCallDelayFrom(block, subaction);
    % update based on if the block is used in a Discrete Event Subsystem
    % and how the block is used
    cbMaskBlockType(block, subaction);

    % Set the block position back to what it was     
    set_param(block, 'position', blockPosition);
% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbFcnCallUpon',
    cbFcnCallUpon(block,subaction);
case 'cbFcnCallDelayFrom',    
    cbFcnCallDelayFrom(block, subaction);        
case 'cbEnableE1Port',
    cbEnableEPort(block,subaction,1);
case 'cbEnableE2Port',
    cbEnableEPort(block,subaction,2);    
case 'cbEnableF2Port',
    cbEnableF2Port(block,subaction);
case 'cbStatNumberF1Calls',
    des_cbStats(block, 'StatNumberF1Calls','#f1',subaction);
case 'cbStatNumberF2Calls',
    des_cbStats(block, 'StatNumberF2Calls','#f2',subaction);
case 'cbSpecifyEventPriority',
    cbSpecifyEventPriority(block,subaction);
    
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
    des_def_fcncallmask(block,mfilename);
    % Enable/Disable the enable port
    cbEnableEPort(block,subaction, 1);
    % Statistics (count)
    des_cbStats(block, 'StatNumberF1Calls','#f1',subaction);
    des_cbStats(block, 'StatNumberF2Calls','#f2',subaction);
    % Enable/Disable the second function call port
    cbEnableF2Port(block,subaction);
    % update based on function call options
    cbFcnCallUpon(block,subaction);
    % update based on SpecifyEventPriority options
    cbSpecifyEventPriority(block,subaction);
    cbFcnCallDelayFrom(block, subaction);        
    % update based on if the block is used in a Discrete Event Subsystem
    % and how the block is used    
    cbMaskBlockType(block, subaction);    

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
    priority = Vals{idxPriorityFunctionCall};
       
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
        des_enableport(block, applyStatus, 'out' , 'FC', 'f2', 'yes', ...
            'timingcontrol', 'FunctionCall');
    case 'off',
        Vis{idxEnableE2Port} = 'off';
        En{idxStatNumberF2Calls} = 'off';
        des_enableport(block, applyStatus, 'out' , 'FC', 'f2', 'no');
        if(strcmp(applyStatus,'apply'))
            currStatVal = Vals{idxStatNumberF2Calls};
            currE2PortVal = Vals{idxEnableE2Port};
            if (~strcmp(currStatVal,'Off')) || (~strcmp(currE2PortVal,'off'))
                Vals{idxStatNumberF2Calls} = 'Off';
                Vals{idxEnableE2Port} = 'off';
                set_param(block, 'MaskValues', Vals);
            end
        end
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter',['Illegal value for Enabling the Enable port' ]);
    end
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables',En);
    cbEnableEPort(block,applyStatus, 2);
    des_cbStats(block, 'StatNumberF2Calls','#f2',applyStatus);
return;

%*********************************************************************
% Function Name:    cbSpecifyEventPriority
% Description:      Deal with scheduling options.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbSpecifyEventPriority(block, applyStatus)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);


    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    switch Vals{idxSpecifyEventPriority},
    case 'on',
        [Vis{[idxPriorityFunctionCall, idxFunctionCallDelayFrom]}]   = deal('on');
        [En{[idxPriorityFunctionCall, idxFunctionCallDelayFrom]}]   = deal('on');
    case 'off',
        [Vis{[idxPriorityFunctionCall idxFunctionCallDelayFrom]}]   = deal('off');
        [En{[idxPriorityFunctionCall idxFunctionCallDelayFrom]}]   = deal('off');        
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for SpecifyEventPriority option handling' ]);
    end
    
    % Don't enable the Delay widget if the call is coming from the Event
    % Generator.
    if( strcmp(get_param(block,'MaskType'), 'Signal-Based Function-Call Event Generator') )
        [Vis{[idxDelayFunctionCall]}]   = deal('off');        
    end
    
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
    cbFcnCallDelayFrom(block,applyStatus);
    return;




%*********************************************************************
% Function Name:    cbFcnCallUpon
% Description:      Update dialog from function call options.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbFcnCallUpon(block, subaction)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    Prompts = get_param(block, 'MaskPrompts');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    priority = Vals{idxPriorityFunctionCall};

    % --- Update the Mask Parameters if the above switch statement resulted
    %     in new values for the Visibility variables
    switch Vals{idxGenerateFunctionCallUpon},
    case 'Sample time hit from port ts',
    	[Vis{[idxSpecifyEventPriority ]}]   = deal('on');
    	[Vis{[idxSignalEdgeOption]}] = deal('off');
        des_enableport(block, subaction, 'in' , 'SL', 'tr', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'ts', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );
        des_enableport(block, subaction, 'in' , 'FC', 'fcn', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'vc', 'no');
    case 'Trigger from port tr',
    	[Vis{[idxSpecifyEventPriority idxSignalEdgeOption ]}]   = deal('on');
        des_enableport(block, subaction, 'in' , 'SL', 'tr', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );
        des_enableport(block, subaction, 'in' , 'FC', 'fcn', 'no'); 
        des_enableport(block, subaction, 'in' , 'SL', 'ts', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'vc', 'no');
        currPrompt = Prompts{idxSignalEdgeOption};
        if ~strcmp(currPrompt,'Trigger type:')
            Prompts{idxSignalEdgeOption} = deal('Trigger type:');
            set_param(block,'MaskPrompts',Prompts);
        end
    case 'Function call from port fcn',
    	[Vis{[idxSpecifyEventPriority]}]   = deal('on');
    	[Vis{[idxSignalEdgeOption]}] = deal('off');
        des_enableport(block, subaction, 'in' , 'SL', 'tr', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'ts', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'vc', 'no');        
        des_enableport(block, subaction, 'in' , 'FC', 'fcn', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );  
    case 'Change in signal from port vc',
       	[Vis{[idxSpecifyEventPriority idxSignalEdgeOption ]}]   = deal('on');
        des_enableport(block, subaction, 'in' , 'SL', 'vc', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );
        des_enableport(block, subaction, 'in' , 'FC', 'fcn', 'no'); 
        des_enableport(block, subaction, 'in' , 'SL', 'ts', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'tr', 'no');
        currPrompt = Prompts{idxSignalEdgeOption};
        if ~strcmp(currPrompt,'Type of change in signal value:')
            Prompts{idxSignalEdgeOption} = deal('Type of change in signal value:');
            set_param(block,'MaskPrompts',Prompts);
        end
    case 'Entity departure',
    	[Vis{[idxSpecifyEventPriority idxSignalEdgeOption idxPriorityFunctionCall idxDelayFunctionCall]}] = deal('off');
        des_enableport(block, subaction, 'in' , 'SE', 'IN', 'yes');
        des_enableport(block, subaction, 'out' , 'SE', 'OUT', 'yes');
        des_enableport(block, subaction, 'in' , 'SL', 'tr', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'ts', 'no');
        des_enableport(block, subaction, 'in' , 'FC', 'fcn', 'no'); 
        des_enableport(block, subaction, 'in' , 'SL', 'vc', 'no');        
        set_param(block, 'MaskVisibilities', Vis);
        return;
        
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter',['Illegal value for event generation type' ]);
    end

    % No dependent callabacks -- just set the visibilities and leave
    set_param(block, 'MaskVisibilities', Vis);
    cbSpecifyEventPriority(block, subaction);
return;
%*********************************************************************
% Function Name:    cbFcnCallDelayFrom
% Description:      Deal with the different Service Time modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbFcnCallDelayFrom(block, applyStatus)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block, 'MaskEnables');
   
    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    % Proceed with the callback only when the pop-up is enabled
    if(strcmp(En{idxFunctionCallDelayFrom},'off'))
        des_enableport(block, applyStatus, 'in' , 'SL', 't', 'no');
        [Vis{[idxDelayFunctionCall]}]   = deal('off');
    	[En{[idxDelayFunctionCall]}]   = deal('off'); 
        set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
        return;
    end    
    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    FunctionCallDelayFrom = Vals{idxFunctionCallDelayFrom};
    switch FunctionCallDelayFrom,

    case 'Dialog',
    	[Vis{idxDelayFunctionCall}]   = deal('on');
    	[En{idxDelayFunctionCall}]   = deal('on');        
        des_enableport(block, applyStatus, 'in' , 'SL', 't', 'no');
    case 'Signal port t',
        Vis{idxDelayFunctionCall} = deal('off');
        En{idxDelayFunctionCall} = deal('off');        
        des_enableport(block, applyStatus, 'in' , 'SL', 't', 'yes');
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', 'Illegal value for Function-call Delay Time Source' );
    end

    % No dependent callabacks -- just set the visibilities and leave
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
return;

%*********************************************************************
% Function Name:    cbMaskBlockType
% Description:      MaskBlockType is a user-invisible mask parameter that
%                   is designed for internal use only. SimEvents depends on
%                   this parameter to mark if the fcn-call block is used
%                   inside other SimEvents masked blocks (like Discrete
%                   Event Subsystem block), and how the block is used. By
%                   R2008a, MaskBlockType can take one of the following 3
%                   values:
%                   none -- this block is not used any SimEvents library
%                           block
%                   DESS_EVENT_PORT -- this block is used in Discrete Event
%                           Subsystem block for event triggering
%                   DESS_DATA_PORT -- this block is used in Discrete Event
%                           Subsystem block for data input
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbMaskBlockType(block, applyStatus)

switch applyStatus

case 'noapply'
    return;
case 'apply'
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    
    fcnCallUponOpt = {'Change in signal from port vc', ...
        'Trigger from port tr','Sample time hit from port ts'};
    fcnCallUponPort = {'vc','tr','ts'};
    index = strmatch(Vals{idxGenerateFunctionCallUpon},fcnCallUponOpt,'exact');
    if isempty(index)
        return;
    end
    fcnCallUponBlock = [block '/' fcnCallUponPort{index}];
    fcnCallGateBlock = [block '/SL2DES_' fcnCallUponPort{index}];
    curPortDimensions = get_param(fcnCallUponBlock,'PortDimensions');
    curSignalType = get_param(fcnCallUponBlock,'SignalType');
    curMonitorState = get_param(fcnCallGateBlock,'IsMonitorOnly');
    
    % Change PortDimensions and SignalType only when necessary
    switch Vals{idxMaskBlockType}
    case 'none'
        if ~strcmp(curPortDimensions,'1')
            set_param(fcnCallUponBlock,'PortDimensions','1');
        end
        if ~strcmp(curSignalType,'real')
            set_param(fcnCallUponBlock,'SignalType','real');
        end
        if ~strcmp(curMonitorState,'off')
            set_param(fcnCallGateBlock,'IsMonitorOnly','off');
        end        
    case 'DESS_EVENT_PORT'
        if ~strcmp(curPortDimensions,'-1')
            set_param(fcnCallUponBlock,'PortDimensions','-1');
        end
        if index == 3 % ts port
            if ~strcmp(curSignalType,'auto')
                set_param(fcnCallUponBlock,'SignalType','auto');
            end
        else % tr or vc port
            if ~strcmp(curSignalType,'real')
                set_param(fcnCallUponBlock,'SignalType','real');
            end
        end    
        if ~strcmp(curMonitorState,'off')
            set_param(fcnCallGateBlock,'IsMonitorOnly','off');
        end                
    case 'DESS_DATA_PORT'
        if ~strcmp(curPortDimensions,'-1')
            set_param(fcnCallUponBlock,'PortDimensions','-1');
        end
        if ~strcmp(curSignalType,'auto')
            set_param(fcnCallUponBlock,'SignalType','auto');
        end
        if ~strcmp(curMonitorState,'off')
            set_param(fcnCallGateBlock,'IsMonitorOnly','off');
        end                        
    case {'TOWKSPC_HAS_IC','TOWKSPC_NO_IC'}
        if ~strcmp(curPortDimensions,'-1')
            set_param(fcnCallUponBlock,'PortDimensions','-1');
        end
        if ~strcmp(curSignalType,'auto')
            set_param(fcnCallUponBlock,'SignalType','auto');
        end
        if ~strcmp(curMonitorState,'on')
            set_param(fcnCallGateBlock,'IsMonitorOnly','on');
        end                        
    end               
end

return;

% --- end of des_fcncallmask.m
