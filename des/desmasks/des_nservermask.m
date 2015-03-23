function varargout = des_nservermask(block, action, subaction)
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/10/16 04:48:29 $

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
    MaskParamCheck{1} = struct('Numeric', {idxNumberOfServers, idxServiceTime, idxPriorityServiceCompletion}, ...
                               'isValid',  {'IsInt',    'IsReal',      'IsInt'    }, ...
                               'inRange',  {[1 Inf],    [0 Inf],      [1 Inf]    });
    MaskParamCheck{2} = struct('CharString', {idxAttributeName});
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
        cbServiceTimeFrom(block,subaction);
        cbEnableTOPort(block, subaction);        
        des_cbStats(block,'StatAverageWait','w',subaction);
        des_cbStats(block,'StatNumberDeparted','#d',subaction);
        des_cbStats(block,'StatNumberInBlock','#n',subaction);
        des_cbStats(block,'StatNumberPending','#pe',subaction);
        des_cbStats(block,'StatUtilization', 'util',subaction);        
        des_cbStats(block,'StatPendingEntity','pe',subaction);        
        des_cbStats(block, 'StatNumberTimedout','#to',subaction);    
    end
    % Set the block position back to what it was     
    set_param(block, 'position', blockPosition);
	
	% warning about updated pe and/or #pe
	des_first_use_warning(block);
% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------

case 'cbServiceTimeFrom',
    cbServiceTimeFrom(block,subaction);
case 'cbEnableTOPort',
    cbEnableTOPort(block, subaction);    
case 'cbStatAverageWait',
    des_cbStats(block,'StatAverageWait','w',subaction);
case 'cbStatUtilization',
    des_cbStats(block,'StatUtilization', 'util',subaction);    
case 'cbStatNumberDeparted',
    des_cbStats(block,'StatNumberDeparted','#d',subaction);
case 'cbStatNumberInBlock',
    des_cbStats(block,'StatNumberInBlock','#n',subaction);
case 'cbStatNumberPending',
    des_cbStats(block,'StatNumberPending','#pe',subaction);
case 'cbStatPendingEntity',
    des_cbStats(block,'StatPendingEntity','pe',subaction);   
case 'cbStatNumberTimedout',
    des_cbStats(block, 'StatNumberTimedout','#to',subaction);        

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
    des_def_nservermask(block,mfilename);
    cbServiceTimeFrom(block,'apply');
    cbEnableTOPort(block, subaction);
    des_cbStats(block,'StatAverageWait','w',subaction);
    des_cbStats(block,'StatNumberDeparted','#d',subaction);
    des_cbStats(block,'StatNumberInBlock','#n',subaction);
    des_cbStats(block,'StatPendingEntity','pe',subaction);    
    des_cbStats(block,'StatNumberPending','#pe',subaction);
    des_cbStats(block,'StatUtilization', 'util',subaction);    
    des_cbStats(block, 'StatNumberTimedout','#to',subaction);        
% --- End of case 'default'
end; % End of switch(action)
return;

% ----------------
% --- Subfunctions
% ----------------

%*********************************************************************
% Function Name:    cbServiceTimeFrom
% Description:      Deal with the different Service Time modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbServiceTimeFrom(block,applyStatus)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block, 'MaskEnables');    

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    ServiceTimeFrom = Vals{idxServiceTimeFrom};
    switch ServiceTimeFrom,

      case 'Dialog',
        [Vis{[idxServiceTime]}]   = deal('on');
    	[En{[idxServiceTime]}]   = deal('on');           
    	[Vis{[idxAttributeName]} ] = deal('off');
    	[En{[idxAttributeName]} ] = deal('off');           
        des_enableport(block, applyStatus, 'in' , 'SL', 't', 'no');

    case 'Signal port t',
        [Vis{[idxServiceTime idxAttributeName]} ] = deal('off');
        [En{[idxServiceTime idxAttributeName]} ] = deal('off');        
        des_enableport(block, applyStatus, 'in' , 'SL', 't', 'yes');

    case 'Attribute',
        [Vis{[idxServiceTime]}  ]   = deal('off');
    	[Vis{idxAttributeName}]   = deal('on');
        [En{idxAttributeName}]   = deal('on');
    	[En{[idxServiceTime]}]   = deal('off');                
        des_enableport(block, applyStatus, 'in' , 'SL', 't', 'no');
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter',['Illegal value for Delay Time Source' ]);
    end

    % No dependent callabacks -- just set the visibilities and leave
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
return;

%*********************************************************************
% Function Name:    cbEnableTOPort
% Description:      Deal with the timeout Permit parameters.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************

function cbEnableTOPort(block, subaction)
 % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    childName = des_getchildblockname(block);
    
    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    updateOpt = Vals{idxEnableTOPort};
  
    switch updateOpt,
        case 'on',
            des_enableport(block, subaction, 'out' , 'SE', 'TO', 'yes');
        case 'off',
            des_enableport(block, subaction, 'out' , 'SE', 'TO', 'no');
        otherwise,
            des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for timeout update.' ]);
        end
    return;

% --- end of des_nservermask.m
