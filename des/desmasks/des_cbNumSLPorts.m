function des_cbNumSLPorts(block)
% Description:      Change ports based on number of ports.
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
    % --- Field data

% Copyright 2004 The MathWorks, Inc.

    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
   
    % --- Set the field index numbers
    des_setfieldindexnumbers(block);


    % --- Update the Mask Parameters if the above switch statement resulted
    %     in new values for the Visibility variables
    portType = 'SL';
    side = 'in';
    labelRoot = 'u';
    
    % enable ports only if the 'Number of Ports' control is visible
    if(strcmp(Vis{idxNumSLPorts},'off'))
        numPorts = '0';
    else
        numPorts = Vals{idxNumSLPorts};
    end
    des_enableenumport(block, side , portType, labelRoot, numPorts);
return;