function des_enableports(block, applyStatus, IOType, PortType, portLabel, enable, cycle)
% DES_ENABLEPORTS Enable a port on a des block
%
% Inputs:           IOType - 'in' or 'out'
%                   PortType - 'SE' or 'SL'
%                   portlable - cell array of port lables
%                   enable - cell array of enable strings: 'yes' or 'no'
% Modified Values:  Modified Value, Visibility and Enable cell arrays

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/11/23 20:28:01 $

for idx = 1:length(portLabel)
    if cycle,
        des_enableport(block, applyStatus, IOType, PortType, portLabel{idx}, 'yes');
        des_enableport(block, applyStatus, IOType, PortType, portLabel{idx}, 'no');
    end
    des_enableport(block, applyStatus, IOType, PortType, portLabel{idx}, enable{idx});
end
 
return