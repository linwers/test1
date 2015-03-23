function varargout = des_scheduletimeoutmask(block, action, subaction)
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2008/05/12 21:24:16 $

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
    % Create the idxParamName variables
    des_setfieldindexnumbers(block);
    
    MaskParamCheck{1} = struct('Numeric', {idxTimeoutInterval}, ...
                             'isValid',  {'IsReal'}, ...
                             'inRange',  {[0 Inf]});
    MaskParamCheck{2} = struct('CharString', {idxTimeoutTag,idxAttributeName});
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
        cbTimeoutIntervalFrom(block,subaction);
        des_cbStats(block,'StatNumberDeparted', '#d', subaction);
    end

% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbTimeoutIntervalFrom',
    cbTimeoutIntervalFrom(block,subaction);

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
    des_def_scheduletimeoutmask(block,mfilename);
% --- End of case 'default'
end; % End of switch(action)
return;

% ----------------
% --- Subfunctions
% ----------------
%*********************************************************************
% Function Name:    cbTimeoutIntervalFrom
% Description:      Deal with the different Service Time modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbTimeoutIntervalFrom(block, applyStatus)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block, 'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    TimeoutIntervalFrom = Vals{idxTimeoutIntervalFrom};
    switch TimeoutIntervalFrom,

    case 'Dialog',
    	[Vis{idxTimeoutInterval}]   = deal('on');
    	[En{idxTimeoutInterval}]   = deal('on');        
    	[Vis{idxAttributeName} ] = deal('off');
    	[En{idxAttributeName} ] = deal('off');        
        des_enableport(block, applyStatus, 'in' , 'SL', 'ti', 'no');

        % set the visiblity parameters first, then call the
        % dependent callbacks and leave
        set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
    return;

    case 'Signal port ti',
        [Vis{[idxTimeoutInterval idxAttributeName]} ] = deal('off');
        [En{[idxTimeoutInterval idxAttributeName]} ] = deal('off');        
        des_enableport(block, applyStatus, 'in' , 'SL', 'ti', 'yes');

    case 'Attribute',
    	[Vis{idxAttributeName}]   = deal('on');
    	[Vis{idxTimeoutInterval}]   = deal('off');
        [En{idxAttributeName}]   = deal('on');
    	[En{idxTimeoutInterval}]   = deal('off');
        des_enableport(block, applyStatus, 'in' , 'SL', 'ti', 'no');
    otherwise,
	 des_mask_error(block, 'DES_InvalidParameter', 'Illegal value for Service Time Source');
    end

    % No dependent callabacks -- just set the visibilities and leave
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
return;


% --- end of des_scheduletimeoutmask.m
