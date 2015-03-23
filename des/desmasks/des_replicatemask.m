function varargout = des_replicatemask(block, action, subaction)
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2007/11/07 18:26:45 $

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
    MaskParamCheck = struct('Numeric', {idxNumberOutputPorts, idxInitialSeed}, ...
                            'isValid',  {'IsInt',        'IsInt'}, ...
                            'inRange',  {[1 Inf],          [0 Inf]}, ...
                            'rangeOpt', {'openupper','openupper'}, ...
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
        cbNumberOutputPorts(block,subaction);
        cbPortPrecedence(block, subaction);
        cbReplicateEntityWhen(block, subaction);
        des_cbStats(block,'StatNumberArrived','#a',subaction);
        des_cbStats(block,'StatNumberDeparted','#d',subaction);
    end
    set_param(block, 'EvaluatedNumPorts',get_param(block,'NumberOutputPorts'));        
     % Set the block position back to what it was     
    set_param(block, 'position', blockPosition);
    % --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------

case 'cbNumberOutputPorts',
    cbNumberOutputPorts(block,subaction);
case 'cbReplicateEntityWhen',
    cbReplicateEntityWhen(block, subaction);
case 'cbPortPrecedence',
    cbPortPrecedence(block, subaction);
case 'cbStatNumberArrived',
    des_cbStats(block,'StatNumberArrived','#a',subaction);
case 'StatNumberDeparted',
    des_cbStats(block,'StatNumberDeparted','#d',subaction);
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
    des_def_replicatemask(block,mfilename);
    cbNumberOutputPorts(block,subaction);
    cbPortPrecedence(block, subaction);
    cbReplicateEntityWhen(block,subaction);
    des_cbStats(block,'StatNumberArrived','#a',subaction);
    des_cbStats(block,'StatNumberDeparted','#d',subaction);
% --- End of case 'default'
end; % End of switch(action)
return;

% ----------------
% --- Subfunctions
% ----------------

%*********************************************************************
% Function Name:    cbNumberOutputPorts
% Description:      Change ports based on number of ports.
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbNumberOutputPorts(block, applyStatus)


    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    
    % --- Enable the ports upto and including the value specified by the 
    %     parameter indexed by idxNumberInputPorts
    des_cbenableenumports(block, applyStatus, 'out' , 'SE', ...
        'OUT', idxNumberOutputPorts);


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
    PortSelection = Vals{idxOutputPortPrecedence};
    switch PortSelection,

    case 'Equiprobable',
    	[Vis{[idxInitialSeed]}]   = deal('on');
        [En{[idxInitialSeed]}]   = deal('on');
        % set the visiblity parameters first, then call the
        % dependent callbacks and leave
        set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
    return;
    case 'OUT1 port',
        [Vis{[idxInitialSeed]} ] = deal('off');
        [En{[idxInitialSeed]} ] = deal('off');
    case 'Round robin',
        [Vis{[idxInitialSeed]}]   = deal('off');
        [En{[idxInitialSeed]}]   = deal('off');
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Departure Port Precedence' ]);
    end
    % No dependent callabacks -- just set the visibilities and leave
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
return;

%*********************************************************************
% Function Name:    cbReplicateEntityWhen
% Description:      Change the subclassname of under the mask block
%                   Change the visibility of ActionUponBlocking
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************

function cbReplicateEntityWhen(block, applyStatus)
% --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    % --- Set child block name
    childName = des_getchildblockname(block);
    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    ReplicateEntityWhen = Vals{idxReplicateEntityWhen};
    switch ReplicateEntityWhen,
    case 'All entity output ports are not blocked',
      	[Vis{[idxActionUponBlocking]}]   = deal('on');
        [En{[idxActionUponBlocking]}]   = deal('on');
        set_param(childName,'SubClassName','DES_REPLICATE_ALL');
    case 'Any entity output port is not blocked',
      	[Vis{[idxActionUponBlocking]}]   = deal('off');
        [En{[idxActionUponBlocking]}]   = deal('off');
        set_param(childName,'SubClassName','DES_REPLICATE_ANY');        
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Replication Entity When' ]);
    end
    % No dependent callabacks -- just set the visibilities and leave
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
return;

% --- end of des_replicatemask.m