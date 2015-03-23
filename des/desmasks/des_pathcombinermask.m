function varargout = des_pathcombinermask(block, action, subaction)
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2007/11/07 18:26:36 $

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
    MaskParamCheck = struct('Numeric', {idxNumberInputPorts, idxInitialSeed}, ...
                            'isValid',  {'IsInt',        'IsInt'}, ...
                            'inRange',  {[1 Inf],          [0 Inf]}, ...
                            'rangeOpt', {'openupper',    'openupper'}, ...
                            'checkTiming', {'DlgApply','CompileTime'});                            
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
        cbNumberInputPorts(block,subaction);
        cbPortPrecedence(block, subaction);
        cbInitialSeed(block, subaction);
        cbSpecifyEventPriority(block, subaction);
        des_cbStats(block,'StatNumberDeparted','#d',subaction);
        des_cbStats(block, 'StatLastArrivalPort', 'last', subaction);
    end
 set_param(block, 'EvaluatedNumPorts',get_param(block,'NumberInputPorts'));
 
 % Set the block position back to what it was     
 set_param(block, 'position', blockPosition);
% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------

case 'cbNumberInputPorts',
    cbNumberInputPorts(block,subaction);
case 'cbPortPrecedence',
    cbPortPrecedence(block, subaction);
case 'cbInitialSeed',
    cbInitialSeed(block,subaction);
case 'cbSpecifyEventPriority',
    cbSpecifyEventPriority(block,subaction);
case 'cbStatNumberDeparted',
    des_cbStats(block,'StatNumberDeparted','#d',subaction);
case 'cbStatLastArrivalPort',
    des_cbStats(block, 'StatLastArrivalPort', 'last', subaction);
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
    des_def_pathcombinermask(block,mfilename);
    cbNumberInputPorts(block,subaction);
    cbPortPrecedence(block, subaction);
    cbInitialSeed(block, subaction);
    cbSpecifyEventPriority(block,subaction);
    des_cbStats(block,'StatNumberDeparted','#d',subaction);
    des_cbStats(block, 'StatLastArrivalPort', 'last', subaction);

% --- End of case 'default'
end; % End of switch(action)
return;

% ----------------
% --- Subfunctions
% ----------------

%*********************************************************************
% Function Name:    cbNumberInputPorts
% Description:      Change ports based on number of ports.
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbNumberInputPorts(block, applyStatus)

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    
    % --- Enable the ports upto and including the value specified by the 
    %     parameter indexed by idxNumberInputPorts
    des_cbenableenumports(block, applyStatus, 'in' , 'SE', ...
        'IN', idxNumberInputPorts);

return;

%*********************************************************************
% Function Name:    cbPortPrecedence
% Description:      Change the random number InitialSeed visibilty based on
%                   port bias Precedence.
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************

function cbPortPrecedence(block, applyStatus)
 % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    PortSelection = Vals{idxInputPortPrecedence};
    priority = Vals{idxPriorityPathCombinerPortPrecedenceSelection};
    switch PortSelection,

    case 'Equiprobable',
        [Vis{[idxSpecifyEventPriority,idxPriorityPathCombinerPortPrecedenceSelection]}] = deal('off');
        [En{[idxSpecifyEventPriority,idxPriorityPathCombinerPortPrecedenceSelection]}] = deal('off');
    	[Vis{[idxInitialSeed]}]   = deal('on');
        [En{[idxInitialSeed]}]   = deal('on');

        des_enableport(block, applyStatus, 'in' , 'SL', 'p', 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );
        
        % set the visiblity parameters first, then call the
        % dependent callbacks and leave
        set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
        
    return;
    case 'Round robin',
        [Vis{[idxSpecifyEventPriority,idxPriorityPathCombinerPortPrecedenceSelection]}] = deal('off');
        [En{[idxSpecifyEventPriority,idxPriorityPathCombinerPortPrecedenceSelection]}] = deal('off');
        [Vis{[idxInitialSeed]} ] = deal('off');
        [En{[idxInitialSeed]} ] = deal('off');
        
        des_enableport(block, applyStatus, 'in' , 'SL', 'p', 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );

    case 'IN1 port',
        [Vis{[idxSpecifyEventPriority,idxPriorityPathCombinerPortPrecedenceSelection]}] = deal('off');
        [En{[idxSpecifyEventPriority,idxPriorityPathCombinerPortPrecedenceSelection]}] = deal('off');
    	[Vis{idxInitialSeed}]   = deal('off');
        [En{idxInitialSeed}]   = deal('off');
        
        des_enableport(block, applyStatus, 'in' , 'SL', 'p', 'no', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );

    case 'From signal port p',
        [Vis{[idxInitialSeed idxPriorityPathCombinerPortPrecedenceSelection]}  ]   = deal('off');
        [En{[idxInitialSeed idxPriorityPathCombinerPortPrecedenceSelection]}  ]   = deal('off');
        [Vis{[idxSpecifyEventPriority]}]   = deal('on');
        [En{[idxSpecifyEventPriority]}]   = deal('on');

        des_enableport(block, applyStatus, 'in' , 'SL', 'p', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );

        set_param(block, 'MaskVisibilities', Vis, 'MaskEnables',En);
        cbSpecifyEventPriority(block, applyStatus);
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Service Time Source' ]);
    end

    % No dependent callabacks -- just set the visibilities and leave
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
return;

function cbSpecifyEventPriority(block, applyStatus)

% --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    % Execute this callback only if the selection criterion is 'From
    % Simulink'
    PortPrecedence = Vals{idxInputPortPrecedence};

    if(~isequal(PortPrecedence,'From signal port p'))
        return;
    else
        %do nothing
    end


    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    updateOpt = Vals{idxSpecifyEventPriority};
    switch updateOpt,
    case 'on',
        [Vis{[idxPriorityPathCombinerPortPrecedenceSelection]}]   = deal('on');
        [En{[idxPriorityPathCombinerPortPrecedenceSelection]}]   = deal('on');
    case 'off',
        [Vis{[idxPriorityPathCombinerPortPrecedenceSelection ]}]   = deal('off');
        [En{[idxPriorityPathCombinerPortPrecedenceSelection ]}]   = deal('off');
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Input port selection' ]);
    end

    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
    return;
return;

function cbInitialSeed(block, applyStatus)
% do nothing
return;
% --- end of des_pathcombinermask.m
