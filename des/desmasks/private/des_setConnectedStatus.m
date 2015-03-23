function des_setConnectedStatus(block)
% DES_SETCONNECTEDSTATUS Set the connection status of block.
%                        (internal use only)
%
% Inputs          : current block
% Modified Values : isConnected

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2009/08/11 15:39:54 $

des_setfieldindexnumbers(block);

block_conn = get_param(block,'portconnectivity');
size_conn = size(block_conn.DstBlock);

if (size_conn(1) == 0) || (size_conn(2) == 0)
    newIsConnVal = '0';
else
    newIsConnVal = '1';
end

oldIsConnVal = get_param(block,'isConnected');

if ~strcmp(oldIsConnVal, newIsConnVal)
    vals = get_param(block, 'MaskValues');
    vals{ idxIsConnected } = newIsConnVal;
    set_param(block, 'MaskValues', vals);
end

% eof
