function varargout = des_basicqueuemask(block, action, subaction)
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2009/11/13 04:16:01 $

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
    MaskParamCheck = struct('Numeric', {idxCapacity}, ...
                            'isValid',  {'IsInt'    }, ...
                            'inRange',  {[0 Inf]    });
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
        cbCapacity(block,subaction);
        cbEnableTOPort(block, subaction);
        des_cbStats(block,'StatAverageWait', 'w',subaction);
        des_cbStats(block,'StatNumberDeparted', '#d', subaction);
        des_cbStats(block,'StatNumberInBlock','#n',subaction);

        % obsoleted parameter
        des_cbStats_obsoleted(block, 'StatPendingEntity','pe',subaction, idxStatPendingEntity);

        des_cbStats(block, 'StatAverageQueueLength','len',subaction);
        des_cbStats(block, 'StatNumberTimedout','#to',subaction);    
    end
% Set the block position back to what it was     
set_param(block, 'position', blockPosition);
% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbCapacity',
    cbCapacity(block,subaction);
case 'cbEnableTOPort',
    cbEnableTOPort(block, subaction);    
case 'cbStatAverageWait',
    des_cbStats(block,'StatAverageWait','w',subaction);
case 'cbStatNumberDeparted',
    des_cbStats(block,'StatNumberDeparted', '#d', subaction);
case 'cbStatNumberInBlock',
    des_cbStats(block,'StatNumberInBlock','#n',subaction);
case 'cbStatAverageQueueLength'
    des_cbStats(block, 'StatAverageQueueLength','len',subaction);
case 'cbStatNumberTimedout',
    des_cbStats(block, 'StatNumberTimedout','#to',subaction);       
    
%----------------------------------------------------------------------
%   Setup/Utility functions
%----------------------------------------------------------------------
%*********************************************************************
% Case:             'default'
% Description:      Set the block defaults (development use only)
% Inputs:           current block
% Return Values:    none
%*********************************************************************
case 'default',
    des_def_basicqueuemask(block,mfilename);
    cbCapacity(block, action);
    cbEnableTOPort(block, subaction);
    des_cbStats(block,'StatAverageWait','w',subaction);
    des_cbStats(block,'StatNumberDeparted', '#d', subaction);
    des_cbStats(block,'StatNumberInBlock','#n', subaction);
    des_cbStats(block, 'StatAverageQueueLength','len',subaction);
    des_cbStats(block, 'StatNumberTimedout','#to',subaction);    
    % Do nothing for obsoleted parameter
   
% --- End of case 'default'
end; % End of switch(action)

return; % End of the 'function des_basicqueuemask.m'


%*********************************************************************
% Function Name:    cbCapacity
% Description:      Deal with zero capacity queue.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbCapacity(block, subaction)

if(strcmp(subaction,'noapply'))
    return;
end
 % --- Field data
 Vals = get_param(block, 'maskvalues');
 Vis = get_param(block, 'maskvisibilities');
 En = get_param(block,'MaskEnables');

 % --- Set the field index numbers
 des_setfieldindexnumbers(block);
 childName = des_getchildblockname(block);

 % --- Update the Mask Parameters if the below switch statement resulted
 %     in new values for the Visibility variables
 updateOpt = Vals{idxCapacity};

 if(~strcmp(updateOpt,'0'))
     set_param(childName,'SubClassName','DES_FIFOQUEUE');
     return;
 end
 
 % else (updateOpt = 0) zero capacity 
 path2Blk = [get_param(block,'Parent') '/' get_param(block,'name')]; % Get the path to block
 warningID = 'ObsoletedZeroCapQ';
 warningMsg = ['The Capacity parameter of queue blocks will not accept a value of 0 in a future release. '...
               'Use a positive integer as the capacity of ''' path2Blk ''', or remove this block from your model.'];
 des_warning(warningID, warningMsg);
 set_param(childName,'SubClassName','DES_ZEROCAPACITYQUEUE');
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

     
% --- end of des_basicqueuemask.m
