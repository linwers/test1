function varargout = des_seqgen_sfunmask(block, action, subaction)
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/08/11 15:39:53 $

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
    % Pass the MaskParamCheck array of structures to the error checking   
    % --- common initialization
    des_initmask(block, action, subaction);
    des_setConnectedStatus( block );
    % % --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbFormOutput',

    des_setConnectedStatus( block );
end; % End of switch(action)
return;

% --- end of des_rngsfunmask.m
