function varargout = des_signaleventgenmask(block, action, subaction)
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/07 18:26:56 $

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

    % Statistics (count)
    des_cbStats(block, 'StatNumberF1Calls','#f1',subaction);
    % update the function call port tag (just update to/from tag)
    des_enableport(block, subaction, 'out' , 'FC', 'f1', 'yes', ...
        'timingcontrol', 'FunctionCall');
    % update based on function call options
    cbFcnCallUpon(block,subaction);
    % update based on SpecifyEventPriority options
    cbSpecifyEventPriority(block,subaction);

    % Set the block position back to what it was     
    set_param(block, 'position', blockPosition);
% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbFcnCallUpon',
    cbFcnCallUpon(block,subaction);
   
case 'cbStatNumberF1Calls',
    des_cbStats(block, 'StatNumberF1Calls','#f1',subaction);
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
    des_def_signaleventgenmask(block,mfilename);
    % Statistics (count)
    des_cbStats(block, 'StatNumberF1Calls','#f1',subaction);
    % update based on function call options
    cbFcnCallUpon(block,subaction);
    % update based on SpecifyEventPriority options
    cbSpecifyEventPriority(block,subaction);

% --- End of case 'default'
end; % End of switch(action)
return;

% ----------------
% --- Subfunctions
% ----------------

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
        [Vis{idxPriorityFunctionCall}]   = deal('on');
    case 'off',
        [Vis{idxPriorityFunctionCall}]   = deal('off');
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for SpecifyEventPriority option handling' ]);
    end

    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
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
        Prompts{idxSignalEdgeOption} = deal('Trigger type:');
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
        Prompts{idxSignalEdgeOption} = deal('Type of change in signal value:');        
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for GenerateFunctionCallUpon ' ]);
    end

    % No dependent callabacks -- just set the visibilities and leave
    set_param(block, 'MaskVisibilities', Vis, 'MaskPrompts',Prompts);
    cbSpecifyEventPriority(block, subaction);
return;
% --- end of des_getattributemask.m