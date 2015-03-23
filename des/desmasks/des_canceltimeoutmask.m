function varargout = des_canceltimeoutmask(block, action, subaction)
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/11/07 18:26:02 $

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
    MaskParamCheck = struct('CharString', {idxTimeoutTag});
    
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
        des_cbStats(block, 'StatNumberDeparted' ,'#d',subaction);
        des_cbStats(block, 'StatTimeoutNumberDeparted', '#t', subaction);
        des_cbStats(block, 'StatAverageResidualTimeout' , 'w', subaction);
        cbStatResidualTimeout(block, subaction);
    end
% Set the block position back to what it was     
set_param(block, 'position', blockPosition);
% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
% cbStatsTimeout(block, action);

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
    des_def_canceltimeoutmask(block,mfilename);
    des_cbStats(block, 'StatNumberDeparted' ,'#d',subaction);
    des_cbStats(block, 'StatTimeoutNumberDeparted', '#t', subaction);
    des_cbStats(block, 'StatAverageResidualTimeout' , 'w', subaction);
    cbStatResidualTimeout(block, subaction);
    
% --- End of case 'default'
case 'cbStatNumberDeparted'
    des_cbStats(block, 'StatNumberDeparted' ,'#d',subaction);
case 'cbStatTimeoutNumberDeparted',
   des_cbStats(block, 'StatTimeoutNumberDeparted', '#t', subaction);
case 'cbStatResidualTimeout',
    cbStatResidualTimeout(block, subaction);
case 'cbStatAverageResidualTimeout'
   des_cbStats(block, 'StatAverageResidualTimeout' , 'w', subaction);
end; % end of switch statement.

return;




%*********************************************************************
% Function Name:    cbStatStatResidualTimeout
% Description:      Deal with the different options to display the   
%                   the elapsed time in every passing entity with the
%                   tagged timeout.
% Inputs:           current block, apply status
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbStatResidualTimeout(block, applyStatus)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    elapsedTimeOpt = Vals{idxStatResidualTimeout};
 
    switch elapsedTimeOpt,

    case 'On',
        des_enableport(block, applyStatus, 'out' , 'SL', 'rt', 'yes');
    case 'Off',
        des_enableport(block, applyStatus, 'out' , 'SL', 'rt', 'no');
    otherwise,
	 des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for elapsed time port option ' elapsedTimeOpt ]);
    end
return;


% ----------------
% --- Subfunctions
% ----------------
function cbStatsTimeout(block, applyStatus)
ParamNameArray = {'StatResidualTimeout', 'timeAvg'};
PortLabelArray = {'et'         , 'w'      };

for count=1:length(ParamNameArray)
    paramValue = get_param(block, ParamNameArray{count});
    switch paramValue
        case 'on'
            enablingAction = 'yes';
        case 'off'
            enablingAction = 'no';
    end
    des_enableport(block, applyStatus, 'out' , 'SL', PortLabelArray{count}, enablingAction);
end


% --- end of des_starttimeoutmask.m
