function [varargout] = des_basicservermask(block, action, subaction)
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2009/10/16 04:48:23 $

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
    MaskParamCheck{1} = struct('Numeric', {idxServiceTime, idxPriorityServiceCompletion}, ...
                             'isValid',  {'IsReal',        'IsInt'    }, ...
                             'inRange',  {[0 Inf],        [1 Inf]    });
    MaskParamCheck{2} = struct('CharString', {idxAttributeName,idxSortingAttributeName, idxResidualAttributeName});
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
        cbPermitPreemption(block,subaction);
        cbEnableTOPort(block, subaction);
        cbResidualAttributeName(block,subaction);
        des_cbStats(block,'StatAverageWait','w',subaction);
        des_cbStats(block, 'StatNumberDeparted','#d',subaction);
        des_cbStats(block, 'StatNumberTimedout','#to',subaction);    
        des_cbStats(block, 'StatNumberInBlock','#n',subaction);
        des_cbStats(block, 'StatNumberPreempted','#p',subaction);
        des_cbStats(block,'StatUtilization', 'util',subaction);
        des_cbStats(block, 'StatPendingEntity','pe',subaction);
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
case 'cbPermitPreemption',
    cbPermitPreemption(block,subaction);
case 'cbEnableTOPort',
    cbEnableTOPort(block, subaction);
case 'cbResidualAttributeName',
    cbResidualAttributeName(block,subaction);
case 'cbStatNumberDeparted',
    des_cbStats(block, 'StatNumberDeparted','#d',subaction);
case 'cbStatNumberInBlock',
    des_cbStats(block, 'StatNumberInBlock','#n',subaction);
case 'cbStatNumberPreempted',
    des_cbStats(block, 'StatNumberPreempted','#p',subaction);
case 'cbStatUtilization',
    des_cbStats(block,'StatUtilization', 'util',subaction);
case 'cbStatPendingEntity',
    des_cbStats(block, 'StatPendingEntity','pe',subaction);
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
    des_def_basicservermask(block,mfilename);
    cbServiceTimeFrom(block,subaction);
    cbPermitPreemption(block,subaction);
    cbEnableTOPort(block, subaction);
    cbResidualAttributeName(block,subaction);
    des_cbStats(block,'StatAverageWait','w',subaction);
    des_cbStats(block, 'StatNumberDeparted','#d',subaction);
    des_cbStats(block, 'StatNumberInBlock','#n',subaction);
    des_cbStats(block, 'StatNumberPreempted','#p',subaction);
    des_cbStats(block, 'StatNumberTimedout','#to',subaction);    
    des_cbStats(block,'StatUtilization', 'util',subaction);
    des_cbStats(block, 'StatPendingEntity','pe',subaction);
% --- End of case 'default'

%*********************************************************************
% Function Name:    show all
% Description:      Show all of the widgets
% Inputs:           current block
% Return Values:    none
% Notes:            This function is for development use only and allows
%                   All fields to be displayed
%********************************************************************
case 'showall',
    des_mask_showall(block);
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
function cbServiceTimeFrom(block, applyStatus)

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
        enableTPort = 'no';

    case 'Signal port t',
        [Vis{[idxServiceTime idxAttributeName]} ] = deal('off');
        [En{[idxServiceTime idxAttributeName]} ] = deal('off');        
        enableTPort = 'yes';
    case 'Attribute',
    	[Vis{idxAttributeName}]   = deal('on');
    	[Vis{[idxServiceTime]}]   = deal('off');
        [En{idxAttributeName}]   = deal('on');
    	[En{[idxServiceTime]}]   = deal('off');
        enableTPort = 'no';
     otherwise,
	des_mask_error(block,'DES_InvalidParameter','Illegal value for Service Time Source');
    end
    
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
    des_enableport(block, applyStatus, 'in' , 'SL', 't', enableTPort);    
return;

%*********************************************************************
% Function Name:    cbPermitPreemption
% Description:      Deal with the timeout Permit parameters.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************

function cbPermitPreemption(block, subaction)
 % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
   
    preemptOpt = Vals{idxPermitPreemption};
  
    switch preemptOpt,
        case 'on',
            [Vis{[idxSortingAttributeName]}]   = deal('on');
            [En{[idxSortingAttributeName]}]   = deal('on');
            [Vis{[idxSortingDirection]}]   = deal('on');
            [En{[idxSortingDirection]}]   = deal('on');
            [Vis{[idxWriteToAttribute]}]   = deal('on');
            [En{[idxWriteToAttribute]}]   = deal('on');
            [En{[idxStatNumberPreempted]}]   = deal('on');
            if ~strcmp(Vals{[idxStatAverageWait]},'Off')
                set_param(block, 'StatAverageWait', 'Off');
            end
            [En{[idxStatAverageWait]}]   = deal('off');
            enablePPort = 'yes';
        case 'off',
            [Vis{[idxSortingAttributeName]}]   = deal('off');
            [En{[idxSortingAttributeName]}]   = deal('off');
            [Vis{[idxSortingDirection]}]   = deal('off');
            [En{[idxSortingDirection]}]   = deal('off');
            [Vis{[idxWriteToAttribute]}]   = deal('off');
            [En{[idxWriteToAttribute]}]   = deal('off');
            [En{[idxStatNumberPreempted]}]   = deal('off');
            [En{[idxStatAverageWait]}]   = deal('on');
            enablePPort = 'no';                   
        otherwise,
             des_mask_error(block,'DES_InvalidParameter', ['Illegal value for preemption update.' ]);
    end
    
    des_enableport(block, subaction, 'out' , 'SE', 'P', enablePPort);
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);    
    
    cbResidualAttributeName(block, subaction);
    setChildBlockType(block,subaction);
    
    return;
%*********************************************************************
% Function Name:    cbResidualAttributeName
% Description:      Deal with assignment of attribute name to residual service time value.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************

function cbResidualAttributeName(block, subaction)
 % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    
    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    writeToAttrib = [Vals{idxWriteToAttribute},Vis{idxWriteToAttribute}];
    expVals = ['on','on'];
           
    %if strcmp(writeToAttribVis, 'on') && strcmp(writeToAttribVals,'on')
    if strmatch(writeToAttrib,expVals,'exact')
        [Vis{[idxResidualAttributeName]}]   = deal('on');
        [En{[idxResidualAttributeName]}]   = deal('on');
        [Vis{[idxCreateAttribute]}]   = deal('on');
        [En{[idxCreateAttribute]}]   = deal('on');
    else
        [Vis{[idxResidualAttributeName]}]   = deal('off');
        [En{[idxResidualAttributeName]}]   = deal('off');
        [Vis{[idxCreateAttribute]}]   = deal('off');
        [En{[idxCreateAttribute]}]   = deal('off');
    end

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

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    enableT0PortOpt = Vals{idxEnableTOPort};
  
    switch enableT0PortOpt,
        case 'on',
            des_enableport(block, subaction, 'out' , 'SE', 'TO', 'yes');
        case 'off',
            des_enableport(block, subaction, 'out' , 'SE', 'TO', 'no');
        otherwise,
             des_mask_error(block,'DES_InvalidParameter', ['Illegal value for timeout update.' ]);
    end
    return;

    %*********************************************************************
% Function Name:    setChildBlockType
% Description:      Sets the block type to the right value based on
% switching criteria and the Store entity option value
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function setChildBlockType(block, applyStatus)

    Vals = get_param(block, 'maskvalues');
   
    % Set the field index numbers
    des_setfieldindexnumbers(block);
    childName = des_getchildblockname(block);
    
    preemptionOpt = Vals{idxPermitPreemption};
    
    currentBlockType = get_param(childName,'SubClassName');

    if strcmp(preemptionOpt,'on') 
        if strcmp(currentBlockType,'DES_BASICSERVER')
            set_param(childName,'SubClassName','DES_PBASICSERVER');
        end
    else
        if strcmp(currentBlockType, 'DES_PBASICSERVER')
            set_param(childName,'SubClassName','DES_BASICSERVER');
        end
    end
return;


% --- end of des_basicservermask.m
