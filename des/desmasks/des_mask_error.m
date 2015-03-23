function des_mask_error(block, msgID, msg)
% DES_MASK_ERROR creates an error message, sets SLLastError and throws an
% error in the form of an error dialog. This function one of the DES
% functions for checking mask dialog errors.
% 
% Input Arguments: 
% block          - The source of error  (A character string that has the
%                  full path to the block) e.g. 'MyModel/Input Switch'
% msg            - The error message used to set sllasterror and a subset
%                  of the message on the error dialog. (A character string)
%                  e.g. 'Number of entity input ports must be a scalar
%                  integer in the range 1 <= Number of entity input ports
%                  <= 4'
% msgID          - Message ID for setting SLLastError for testing purposes
%                  (A character string) The message ID should follow the
%                  Simulink convention which is to set the message ID to
%                  DES_MASK_XXXX e.g. 'DES_MASK_InvalidNumber'
% 
% Return Values: none at this point
%
% Example Usage: 
% msg = 'Number of entity input ports must be a scalar integer in the range
%       1 <= Number of entity input ports <= 4'
%       (See the calls from DES_VALIDATEINPUTS for details of the message
%       construction.)
% des_mask_error(block, msg, 'DES_MASK_InvalidNumber');
%
%   See also des_error, des_throwerror, sllasterror

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/02/13 15:11:44 $



des_throwerror(block, {msg}, {msgID});


