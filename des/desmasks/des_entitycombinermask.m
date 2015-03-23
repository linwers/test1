function varargout = des_entitycombinermask(block, action, subaction)
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2007/11/07 18:26:15 $

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
    MaskParamCheck = struct('Numeric', {idxNumberInputPorts}, ...
                            'isValid',  {'IsInt'}, ...
                            'inRange',  {[1 Inf]}, ...
                            'rangeOpt', {'openupper'}, ...
                            'checkTiming', {'DlgApply'});
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
%        cbSpecifyEventPriority(block, subaction);
        des_cbStats(block,'StatNumberDeparted','#d',subaction);
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
case 'cbSpecifyRetainStructure',
    cbSpecifyRetainStructure(block,subaction);
case 'cbStatNumberDeparted',
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
    des_def_entitycombinermask(block,mfilename);
    cbNumberInputPorts(block,subaction);
    cbSpecifyRetainStructure(block,subaction);
    des_cbStats(block,'StatNumberDeparted','#d',subaction);

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

function cbSpecifyRetainStructure(block, applyStatus)

% --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    childName = des_getchildblockname(block);

    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    updateOpt = Vals{idxRetainComponentEntities};
    switch updateOpt,
    case 'on',
        [Vis{[idxAttributeAccessibility]}]   = deal('on');
        [En{[idxAttributeAccessibility]}]   = deal('on');
        [Vis{[idxTimerAccessibility]}]   = deal('on');
        [En{[idxTimerAccessibility]}]   = deal('on');
        [Vis{[idxAttributeCopied]}]   = deal('off');
        [En{[idxAttributeCopied]}]   = deal('off');
        [Vis{[idxTimerCopied]}]   = deal('off');
        [En{[idxTimerCopied]}]   = deal('off');
        set_param(childName,'SubClassName','DES_SUBENTITYCOMBINER');
    case 'off',
        [Vis{[idxAttributeAccessibility]}]   = deal('off');
        [En{[idxAttributeAccessibility]}]   = deal('off');
        [Vis{[idxTimerAccessibility]}]   = deal('off');
        [En{[idxTimerAccessibility]}]   = deal('off');
        [Vis{[idxAttributeCopied]}]   = deal('on');
        [En{[idxAttributeCopied]}]   = deal('on');
        [Vis{[idxTimerCopied]}]   = deal('on');
        [En{[idxTimerCopied]}]   = deal('on');
        set_param(childName,'SubClassName','DES_ENTITYCOMBINER');
    otherwise,
         des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Input port selection' ]);
    end

    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables', En);
    %return;
return;

% --- end of des_entitycombinermask.m
