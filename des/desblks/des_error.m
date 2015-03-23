function des_error(msgID, varargin)

% DES_ERROR SimEvents wrapper for throwing errors
%
% DES_ERROR is the SimEvents wrapper function for throwing errors 
% to the matlab command line.  It creates an MException object with
% the product name added to the identifier and throws the error at 
% the command line as if it were thrown from the calling functions. 
%
% NOTE: Do not call this function directly.  
% 
% Input Arguments: 
% msgID          - Message ID for setting LASTERROR for testing purposes
%                  (A character string) The message ID should follow the
%                  Simulink convention which is to set the message ID to
%                  DES_XXXX e.g. 'DES_InvalidNumber'
% msg            - The error message used to set lasterror and a subset
%                  of the message on the error dialog. 
% 
% Return Values: none at this point
%
% Example Usage: 
%	des_error('DES_InvalidNumber','Invalid value for parameter');
%
%   See also des_mask_error, MException, error, lasterror


%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/29 08:22:47 $

% Add product name and file to identifier
% myStack = dbstack;
% FullMsgID = [des_getproductname ':' myStack(end-1).name ':' char(msgID)];

if any( cellfun( @isempty, varargin ) ) return; end
FullMsgID = [des_getproductname ':' char(msgID)];

me = MException(FullMsgID,varargin {:});
throwAsCaller(me);
