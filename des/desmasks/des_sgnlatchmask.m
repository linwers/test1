function varargout = des_sgnlatchmask(block, action, subaction)
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/11/13 04:16:11 $

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
	 
	% update set/reset port and under mask parameters
    % updation based on SpecifyEventPriority options are included
    cbWriteMemoryUpon(block,subaction);
    cbReadMemoryUpon(block,subaction);

	% Create validation cell array
    MaskParamCheck = struct('Numeric', {idxInitialMemoryValue, idxPriorityMemoryWrite, idxPriorityMemoryRead}, ...
                             'isValid',  {'IsReal',         'IsInt',           'IsInt'}, ...
                             'inRange',  {[-Inf Inf],       [1 Inf],           [1 Inf]});                
 
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
    
    % update statistics ports
    des_cbStats(block, 'ReportMemoryState','st',subaction);
    des_cbStats(block, 'ReportMemoryUponWrite','mem',subaction);
    des_cbStats(block, 'ReportMemoryUponRead','out',subaction);
    
    % Set the block position back to what it was     
    set_param(block, 'position', blockPosition);
% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbWriteMemoryUpon',
    cbWriteMemoryUpon(block,subaction);
case 'cbReadMemoryUpon',
    cbReadMemoryUpon(block,subaction);    
case 'cbReportMemoryState',
    des_cbStats(block, 'ReportMemoryState','st',subaction);
case 'cbReportMemoryUponWrite',
    des_cbStats(block, 'ReportMemoryUponWrite','mem',subaction);
case 'cbReportMemoryUponRead',
    des_cbStats(block, 'ReportMemoryUponRead','out',subaction);
case 'cbSpecifyWriteEventPriority',
    cbSpecifyWriteEventPriority(block,subaction);
case 'cbSpecifyReadEventPriority',
    cbSpecifyReadEventPriority(block,subaction);
    
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
    des_def_sgnlatchmask(block,mfilename);
    % Status of the Latch
    des_cbStats(block, 'ReportMemoryState','st',subaction);
    des_cbStats(block, 'ReportMemoryUponWrite','mem',subaction);
    des_cbStats(block, 'ReportMemoryUponRead','out',subaction);
    % update based on Write options
    cbWriteMemoryUpon(block,subaction);
    % update based on Read options
    cbReadMemoryUpon(block,subaction);    
    % update based on SpecifyWritePriority options
    cbSpecifyWriteEventPriority(block,subaction);
    % update based on SpecifyResetPriority options
    cbSpecifyReadEventPriority(block,subaction);
% --- End of case 'default'
end; % End of switch(action)
return;

% ----------------
% --- Subfunctions
% ----------------

%*********************************************************************
% Function Name:    cbSpecifyWritePriority
% Description:      Deal with scheduling options.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbSpecifyWriteEventPriority(block, applyStatus)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    switch Vals{idxSpecifyWriteEventPriority},
    case 'on',
        [Vis{[idxPriorityMemoryWrite]}]   = deal('on');
    case 'off',
        [Vis{[idxPriorityMemoryWrite]}]   = deal('off');
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for SpecifyEventPriority option handling' ]);
    end
    
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
return;

%*********************************************************************
% Function Name:    cbSpecifyResetPriority
% Description:      Deal with scheduling options.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbSpecifyReadEventPriority(block, applyStatus)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    if strcmp(Vals{idxReadMemoryUpon},'Write to memory event'),
        [Vis{[idxPriorityMemoryRead]}]   = deal('off');
    else
        switch Vals{idxSpecifyReadEventPriority},
        case 'on',
            [Vis{[idxPriorityMemoryRead]}]   = deal('on');
        case 'off',
            [Vis{[idxPriorityMemoryRead]}]   = deal('off');
        otherwise,
             des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for SpecifyEventPriority option handling ' SpecifyReadEventPriority]);
        end    
    end
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
return;

%*********************************************************************
% Function Name:    cbWriteMemoryUpon
% Description:      Update dialog from function call options.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbWriteMemoryUpon(block, subaction)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    Prompts = get_param(block, 'MaskPrompts');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    priority = Vals{idxPriorityMemoryWrite};

    % --- Update the Mask Parameters if the above switch statement resulted
    %     in new values for the Visibility variables
    switch Vals{idxWriteMemoryUpon},
    case 'Sample time hit from port wts',
    	[Vis{[idxMemoryWriteEdgeOption]}] = deal('off');
        des_enableport(block, subaction, 'in' , 'SL', 'wtr', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'wts', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );
        des_enableport(block, subaction, 'in' , 'FC', 'wfcn', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'wvc', 'no');
    case 'Trigger from port wtr',
    	[Vis{[idxMemoryWriteEdgeOption ]}]   = deal('on');
        des_enableport(block, subaction, 'in' , 'SL', 'wtr', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );
        des_enableport(block, subaction, 'in' , 'FC', 'wfcn', 'no'); 
        des_enableport(block, subaction, 'in' , 'SL', 'wts', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'wvc', 'no');
        Prompts{idxMemoryWriteEdgeOption} = deal('Trigger type:');
    case 'Function call from port wfcn',
    	[Vis{[idxMemoryWriteEdgeOption]}] = deal('off');
        des_enableport(block, subaction, 'in' , 'SL', 'wtr', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'wts', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'wvc', 'no');        
        des_enableport(block, subaction, 'in' , 'FC', 'wfcn', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );  
    case 'Change in signal from port wvc',
       	[Vis{[idxMemoryWriteEdgeOption ]}]   = deal('on');
        des_enableport(block, subaction, 'in' , 'SL', 'wvc', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );
        des_enableport(block, subaction, 'in' , 'FC', 'wfcn', 'no'); 
        des_enableport(block, subaction, 'in' , 'SL', 'wts', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'wtr', 'no');
        Prompts{idxMemoryWriteEdgeOption} = deal('Type of change in signal value:');
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter',  ['Illegal value for WriteMemoryUpon ' WriteMemoryUpon ]);
    end

    % No dependent callabacks -- just set the visibilities and leave
    set_param(block, 'MaskVisibilities', Vis, 'MaskPrompts',Prompts);
    cbSpecifyWriteEventPriority(block, subaction);
return;

%*********************************************************************
% Function Name:    cbReadMemoryUpon
% Description:      Update dialog from function call options.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbReadMemoryUpon(block, subaction)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    Prompts = get_param(block, 'MaskPrompts');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    priority = Vals{idxPriorityMemoryRead};

    % --- Update the Mask Parameters if the above switch statement resulted
    %     in new values for the Visibility variables
    switch Vals{idxReadMemoryUpon},
    case 'Sample time hit from port rts',
    	[Vis{[idxSpecifyReadEventPriority]}]   = deal('on');
    	[Vis{[idxMemoryReadEdgeOption]}] = deal('off');
        des_enableport(block, subaction, 'in' , 'SL', 'rtr', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'rts', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );
        des_enableport(block, subaction, 'in' , 'FC', 'rfcn', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'rvc', 'no');
    case 'Trigger from port rtr',
    	[Vis{[idxSpecifyReadEventPriority idxMemoryReadEdgeOption]}]   = deal('on');
        des_enableport(block, subaction, 'in' , 'SL', 'rtr', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );
        des_enableport(block, subaction, 'in' , 'FC', 'rfcn', 'no'); 
        des_enableport(block, subaction, 'in' , 'SL', 'rts', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'rvc', 'no');
        Prompts{idxMemoryReadEdgeOption} = deal('Trigger type:');
    case 'Function call from port rfcn',
    	[Vis{[idxSpecifyReadEventPriority]}]   = deal('on');
    	[Vis{[idxMemoryReadEdgeOption]}] = deal('off');
        des_enableport(block, subaction, 'in' , 'SL', 'rtr', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'rts', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'rvc', 'no');        
        des_enableport(block, subaction, 'in' , 'FC', 'rfcn', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );  
    case 'Change in signal from port rvc',
       	[Vis{[idxSpecifyReadEventPriority idxMemoryReadEdgeOption]}]   = deal('on');
        des_enableport(block, subaction, 'in' , 'SL', 'rvc', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );
        des_enableport(block, subaction, 'in' , 'FC', 'rfcn', 'no'); 
        des_enableport(block, subaction, 'in' , 'SL', 'rts', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'rtr', 'no');
        Prompts{idxMemoryReadEdgeOption} = deal('Type of change in signal value:');
    case 'Write to memory event',
        [Vis{[idxSpecifyReadEventPriority idxMemoryReadEdgeOption]}]   = deal('off');
        des_enableport(block, subaction, 'in' , 'SL', 'rtr', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'rts', 'no');
        des_enableport(block, subaction, 'in' , 'SL', 'rvc', 'no');        
        des_enableport(block, subaction, 'in' , 'FC', 'rfcn', 'no');        
    otherwise,
		des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for event generation type ' ReadMemoryUpon ]);
    end

    % No dependent callabacks -- just set the visibilities and leave
    set_param(block, 'MaskVisibilities', Vis, 'MaskPrompts',Prompts);
    cbSpecifyReadEventPriority(block, subaction);        
return;

%*********************************************************************
% Function Name:    cbSgnlatchStatus
% Description:      Update output ports from latch status options.
% Inputs:           current block, Value, port label and apply options
% Modified Values:  Output ports enable / disable status
%********************************************************************
function des_cbStats(block, paramName, portLabel, applyStatus);

% Determine whether the mask should be enabled or disabled. 
switch get_param(block, paramName)
    case {'on'},
        enablingAction = 'yes';
        
    case {'off'},
        enablingAction = 'no';
        
    otherwise
        disp('Illegal latch status options');
        enablingAction = 'no';
end

des_enableport(block, applyStatus, 'out' , 'SL', portLabel, enablingAction);

return;

% --- end of des_sgnlatchmask.m
