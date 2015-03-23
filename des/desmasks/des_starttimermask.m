function varargout = des_starttimermask(block, action, subaction)
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2005/12/19 07:23:40 $

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
    MaskParamCheck = struct('CharString', {idxTimerTag});
    
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
        des_cbStats(block,'StatNumberDeparted', '#d', subaction);
    end

% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------


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
    des_def_starttimermask(block,mfilename);
% --- End of case 'default'
end; % End of switch(action)
return;

% ----------------
% --- Subfunctions
% ----------------

% --- end of des_starttimermask.m