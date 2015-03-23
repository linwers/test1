function varargout = des_outputswitchmask(block, action, subaction)
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.14 $ $Date: 2009/10/16 04:48:30 $

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
    Vals = get_param(block, 'maskvalues');
   
    % this is needed for setting the boundaries of IC parameter checking.
    numPorts = str2num(Vals{idxNumberOutputPorts});
    numPortsSize = size(numPorts);
    if numPortsSize(1) ~= 1,
        numPorts = numPorts';
    end
    
    MaskParamCheck{1} = struct('Numeric', {idxNumberOutputPorts, idxPriorityOutputSwitchSelectPort, idxInitialSeed}, ...
                             'isValid',  {'IsInt',       'IsInt',     'IsInt'}, ...
                             'inRange',  {[1 Inf],         [1 Inf],     [0 Inf]   }, ...
                             'rangeOpt', {'openupper','closeboth','openupper'}, ...
                            'checkTiming', {'DlgApply','CompileTime', 'CompileTime'});                             
    MaskParamCheck{2} = struct('CharString', {idxAttributeName});
    
    % since there is a dependency between numports and IC, check the
    % numports first before checking IC.
    ICMaskParamCheck = struct('Numeric',{idxInitialConditions}, ...
                               'isValid',{'IsInt'},...
                               'inRange',{[1 numPorts]},...
                               'rangeOpt',{'closeboth'});
                           
    % Pass the MaskParamCheck array of structures to the error checking
    % sub-function
    if(~des_validateinputs(block, MaskParamCheck))
        return;
    end
  
    if( ~des_validateinputs(block, ICMaskParamCheck))
        return;
    end
    
    % --- check if we are in a block update (and don't want to
    %     be called)  This reduces flicker in the mask and ports.
    b_ud = get_param(block,'userdata');
    if b_ud.in_blockupdate,
        return;
    end

    % --- call independent callback functions in block that have other
    %     callback function that depend on it.  These functions
    %     will call, in turn, the dependent callback functions.
    cbNumberOutputPorts(block,subaction);
    cbSwitchingCriterion(block,subaction); 
    cbInitialConditionsOpt(block,subaction);
    cbEntityBufferOpt(block,subaction);
    %cbSpecifyEventPriority(block, subaction);
    %cbTimeoutPortOpt(block,subaction); called from cbEntityBufferOpt
    des_cbStats(block,'StatNumberDeparted','#d',subaction);
    des_cbStats(block,'StatNumberTimedOut','#to',subaction);
    des_cbStats(block,'StatLastDeparturePort','last',subaction);
    des_cbStats(block,'StatPendingEntity','pe',subaction);
    set_param(block, 'EvaluatedNumPorts',get_param(block,'NumberOutputPorts'));    
    % Set the block position back to what it was
    set_param(block, 'position', blockPosition);

	% warning about updated pe 
	des_first_use_warning(block);
	
% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------

case 'cbNumberOutputPorts',
    cbNumberOutputPorts(block,subaction);
case 'cbSwitchingCriterion',
    cbSwitchingCriterion(block,subaction);
case 'cbSpecifyEventPriority',
    cbSpecifyEventPriority(block, subaction);
case 'cbStatNumberDeparted',
    des_cbStats(block,'StatNumberDeparted','#d',subaction);
case 'cbLastSelectPort',
    des_cbStats(block,'StatLastDeparturePort','last',subaction);
case 'cbStatPendingEntity',
    des_cbStats(block,'StatPendingEntity','pe',subaction);
case 'cbNumberTimedOut',
    des_cbStats(block,'StatNumberTimedOut','#to', subaction);
case 'cbEntityBufferOpt',
    cbEntityBufferOpt(block,subaction);
case 'cbTimeoutPortOpt',
    cbTimeoutPortOpt(block,subaction);
case 'cbInitialConditionsOpt',
    cbInitialConditionsOpt(block, subaction);

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
    des_def_outputswitchmask(block,mfilename);
    cbNumberOutputPorts(block,subaction);
    cbSwitchingCriterion(block,subaction);
    cbInitialConditionsOpt(block,subaction);
    cbEntityBufferOpt(block,subaction);
    %cbSpecifyEventPriority(block, subaction);
    %cbTimeoutPortOpt(block,subaction);  called from cbEntityBufferOpt
    des_cbStats(block,'StatNumberDeparted','#d',subaction);
    des_cbStats(block, 'StatNumberTimedOut', '#to', subaction);
    des_cbStats(block, 'StatPendingEntity', 'pe', subaction);
    des_cbStats(block,'StatLastDeparturePort','last',subaction);
% --- End of case 'default'
end; % End of switch(action)
return;

% ----------------
% --- Subfunctions
% ----------------

%*********************************************************************
% Function Name:    cbSwitchingCriterion
% Description:      Deal with the different Service Time modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbSwitchingCriterion(block,applyStatus)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    
    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    SwitchingCriterion = Vals{idxSwitchingCriterion};
       
    switch SwitchingCriterion,

    case 'Equiprobable',
    	[Vis{[idxInitialSeed]}]   = deal('on');
        [En{[idxInitialSeed]}]   = deal('on');
        [Vis{[idxInitialConditionsOpt,idxInitialConditions,idxSpecifyEventPriority, idxPriorityOutputSwitchSelectPort, idxAttributeName, idxEntityBufferOpt]}]   = deal('off');
        [En{[idxInitialConditionsOpt,idxInitialConditions,idxSpecifyEventPriority, idxPriorityOutputSwitchSelectPort, idxAttributeName,idxStatPendingEntity, idxEntityBufferOpt,idxTimeoutPortOpt ]}]   = deal('off');
 
    case 'Round robin',
        [Vis{[idxInitialSeed,idxInitialConditionsOpt,idxInitialConditions,idxSpecifyEventPriority, idxPriorityOutputSwitchSelectPort, idxAttributeName, idxEntityBufferOpt]}]   = deal('off');
        [En{[idxInitialSeed,idxInitialConditionsOpt,idxInitialConditions,idxSpecifyEventPriority, idxPriorityOutputSwitchSelectPort, idxAttributeName, idxStatPendingEntity,idxEntityBufferOpt,idxTimeoutPortOpt]}]   = deal('off');
    
    case 'First port that is not blocked',
        [Vis{[idxInitialConditionsOpt,idxInitialConditions,idxAttributeName, idxInitialSeed, idxSpecifyEventPriority, idxPriorityOutputSwitchSelectPort, idxEntityBufferOpt]} ] = deal('off');
        [En{[idxInitialConditionsOpt,idxInitialConditions,idxAttributeName, idxInitialSeed, idxSpecifyEventPriority, idxPriorityOutputSwitchSelectPort,idxEntityBufferOpt,idxStatPendingEntity, idxTimeoutPortOpt]} ] = deal('off');
        
    case 'From signal port p',
        [Vis{[idxInitialConditions,idxInitialSeed, idxPriorityOutputSwitchSelectPort, idxAttributeName]}  ]   = deal('off');
        [En{[idxInitialConditions,idxInitialSeed,idxPriorityOutputSwitchSelectPort,idxAttributeName,idxStatPendingEntity,idxTimeoutPortOpt]}] = deal('off');
        
        [Vis{[idxInitialConditionsOpt,idxEntityBufferOpt]}]   = deal('on');
        [En{[idxInitialConditionsOpt,idxEntityBufferOpt]}]   = deal('on');
        
    case 'From attribute',
        [Vis{[idxInitialConditionsOpt,idxInitialConditions,idxInitialSeed idxPriorityOutputSwitchSelectPort idxSpecifyEventPriority,idxEntityBufferOpt]} ]   = deal('off');
        [En{[idxInitialConditionsOpt,idxInitialConditions,idxInitialSeed idxPriorityOutputSwitchSelectPort idxSpecifyEventPriority,idxEntityBufferOpt,idxStatPendingEntity, idxTimeoutPortOpt]}  ]   = deal('off');
        [Vis{[idxAttributeName]}]              = deal('on');
        [En{[idxAttributeName]}]              = deal('on');
               
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', 'Illegal value for Output port selection' );
    end
    
    %Set the visibilities and enables.
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
    
    % Call dependent callbacks.
    setPportVisibility(block,applyStatus);
    cbInitialConditionsOpt(block, applyStatus);
    cbEntityBufferOpt(block,applyStatus); % This calls TO callback and Specify event prio callback.
    setChildBlockType(block,applyStatus);
    
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
    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    paramVisible = Vis{idxSpecifyEventPriority};
   
    updateOpt = Vals{idxSpecifyEventPriority};
   
    % if the control is visible and is checked turn on the dependent visibilities
    % this particular control is doesn't affect the dependent controls
    % based on its enable status.
    if strcmp(paramVisible,'on') && strcmp(updateOpt,'on')
        [Vis{[idxPriorityOutputSwitchSelectPort]}]   = deal('on');
        [En{[idxPriorityOutputSwitchSelectPort]}]   = deal('on');
    else
        % The parameter is not visible or the parameter is visible but is not
        % checked. Turn off the dependent visibilities.
        [Vis{[idxPriorityOutputSwitchSelectPort ]}]   = deal('off');
        [En{[idxPriorityOutputSwitchSelectPort ]}]   = deal('off');       
    end
    
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
    return;
    
%*********************************************************************
% Function Name:    cbInitialConditionsOpt
% Description:      Change the visibility of IC
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************    
function cbInitialConditionsOpt(block, applyStatus)
    
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');
    
    des_setfieldindexnumbers(block);

    paramVisible = Vis{idxInitialConditionsOpt};   
    updateOpt = Vals{idxInitialConditionsOpt};
   
    % if the control is visible and is checked turn on the dependent visibilities
    % this particular control is doesn't affect the dependent controls
    % based on its enable status.
    if strcmp(paramVisible,'on') && strcmp(updateOpt,'on')
        [Vis{idxInitialConditions}]   = deal('on');
        [En{idxInitialConditions}]   = deal('on');
    else
        % The parameter is not visible or the parameter is visible but is not
        % checked. Turn off the dependent visibilities.
        [Vis{idxInitialConditions }]   = deal('off');
        [En{idxInitialConditions }]   = deal('off');       
    end

    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
    return;

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
% Function Name:    cbEntityBufferOpt
% Description:      Enable dependent visibilities based on store entity
% option.
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbEntityBufferOpt(block, applyStatus)

    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block, 'MaskEnables');

    % Set the field index numbers
    des_setfieldindexnumbers(block);
    
    entityBufferOpt = Vals{idxEntityBufferOpt};
    entityBufferVisible = Vis{idxEntityBufferOpt};
   
    % if the control is visible and is checked turn on the dependent visibilities
    % this particular control doesn't affect the dependent controls
    % based on its enable status.
    if strcmp(entityBufferVisible,'on') && strcmp(entityBufferOpt,'on')
       [En{[idxTimeoutPortOpt,idxStatPendingEntity ]}]   = deal('on');
       [En{idxSpecifyEventPriority}] = deal('off');
       [Vis{idxSpecifyEventPriority}] = deal('off');
    else if strcmp(entityBufferVisible,'on') && strcmp(entityBufferOpt,'off')
       [En{[idxTimeoutPortOpt,idxStatPendingEntity]}]   = deal('off');
       [En{idxSpecifyEventPriority}] = deal('on');
       [Vis{idxSpecifyEventPriority}] = deal('on');
    else if strcmp(entityBufferVisible,'off')
        [En{[idxTimeoutPortOpt,idxSpecifyEventPriority, idxStatPendingEntity]}]   = deal('off');
        [Vis{idxSpecifyEventPriority}] = deal('off');
        end
        end
    end
   
   set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
   
   cbTimeoutPortOpt(block,applyStatus);
   cbSpecifyEventPriority(block,applyStatus);
   setPendingEntityState(block,entityBufferVisible,entityBufferOpt);
   return;
   
 %*********************************************************************
% Function Name:    setPendingEntityState
% Description:      Set the pending entity stats value.
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function setPendingEntityState(block,entityBufferVisible,entityBufferOpt)
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block, 'MaskEnables');
    % Set the field index numbers
    des_setfieldindexnumbers(block);
    
    if (~strcmp(entityBufferVisible,'on')) || (~strcmp(entityBufferOpt,'on'))
        if(~strcmp(Vals{idxStatPendingEntity}, 'Off'))
            set_param(block, 'StatPendingEntity', 'Off');
        end
    end
     
 return
 
  %*********************************************************************
% Function Name:    cbTimeoutPortOpt
% Description:      Enable TO port based on controls.
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbTimeoutPortOpt(block, applyStatus)
    Vals = get_param(block, 'maskvalues');
    En = get_param(block, 'MaskEnables');

    % Set the field index numbers
    des_setfieldindexnumbers(block);
    timeOutOptVal = Vals{idxTimeoutPortOpt};
    timeOutOptEnabled = En{idxTimeoutPortOpt};
   
    % if the control is enabled and is checked turn on the dependent visibilities
    
    if strcmp(timeOutOptEnabled,'on') && strcmp(timeOutOptVal,'on')
        des_enableport(block, applyStatus, 'out', 'SE', 'TO', 'yes');
     else
        des_enableport(block, applyStatus, 'out', 'SE', 'TO', 'no');
     end
     
 return


%*********************************************************************
% Function Name:    setChildBlockType
% Description:      Sets the block type to the right value based on
% switching criteria and the Store entity option value
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function setChildBlockType(block, applyStatus)

    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    % Set the field index numbers
    des_setfieldindexnumbers(block);
    childName = des_getchildblockname(block);
    
    entityBufferOptVis = Vis{idxEntityBufferOpt};
    entityBufferOptVal = Vals{idxEntityBufferOpt};
    
    currentBlockType = get_param(childName,'SubClassName');

    % If the entity buffer option is visible and is checked, then set the
    % block type to Buffered output switch. Else set it to just output switch
    if strcmp(entityBufferOptVis,'on') && strcmp(entityBufferOptVal,'on')
        if strcmp(currentBlockType,'DES_OUTPUTSWITCH')
            set_param(childName,'SubClassName','DES_BUFFERED_OUTPUTSWITCH');
        end
    else
        if strcmp(currentBlockType, 'DES_BUFFERED_OUTPUTSWITCH')
            set_param(childName,'SubClassName','DES_OUTPUTSWITCH');
        end
    end
return;

 %*********************************************************************
% Function Name:    setPportVisibility
% Description:      Turn the p port on or off based on switching criteria
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function setPportVisibility(block, applyStatus)

    Vals = get_param(block, 'maskvalues');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block); 
    
    priority = Vals{idxPriorityOutputSwitchSelectPort};
    switchingCriteria = Vals{idxSwitchingCriterion};
    
    % If the switching criteria is from p port then enable the p port
    % else disable the p port.
    if (~strcmp(switchingCriteria, 'From signal port p'))
        des_enableport(block, applyStatus, 'in' , 'SL', 'p', 'no');
        
    else
         des_enableport(block, applyStatus, 'in' , 'SL', 'p', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority );
     end
     
 return
% --- end of des_outputswitchmask.m
