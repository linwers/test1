function varargout = des_terminatormask(block, action, subaction)
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/07 18:27:01 $

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
    % --- check if we are in a block update (and don't want to
    %     be called)  This reduces flicker in the mask and ports.
    b_ud = get_param(block,'userdata');
    if b_ud.in_blockupdate,
        return;
    end

    % --- call independent callback functions in block that have other
    %     callback function that depend on it.  These functions
    %     will call, in turn, the dependent callback functions.
    cbAvailableForArrivals(block, subaction);
    des_cbStats(block,'StatNumberArrived','#a',subaction);
% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------

case 'cbAvailableForArrivals',
    cbAvailableForArrivals(block, subaction);

case 'cbStatNumberArrived',
    des_cbStats(block,'StatNumberArrived','#a',subaction);
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
    des_def_terminatormask(block,mfilename);
    cbAvailableForArrivals(block, subaction);
    des_cbStats(block,'StatNumberArrived','#a',subaction);
% --- End of case 'default'
end; % End of switch(action)
return;

%*********************************************************************
% Function Name:    cbAvailableForArrivals
% Description:      Choose the input that is used for the x axis, time or other
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbAvailableForArrivals(block,applyStatus)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    childName = des_getchildblockname(block);
    
    AvailableForArrivals = Vals{idxAvailableForArrivals};
    switch AvailableForArrivals,
    case 'on',
    	[Vis{[idxStatNumberArrived]}]   = deal('on');
        set_param(childName,'SubClassName','DES_TERMINATOR');
    case 'off',
    	[Vis{[idxStatNumberArrived]} Vals{[idxStatNumberArrived]}]   = deal('off');
        set_param(block, 'maskvalues', Vals);
        set_param(childName,'SubClassName','DES_PATHNOTAVAIL');
    otherwise,
        des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Path Available checkbox' ]);
    end

    set_param(block, 'MaskVisibilities', Vis);
return;

% --- end of des_terminatormask.m