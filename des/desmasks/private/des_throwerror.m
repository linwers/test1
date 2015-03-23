function des_throwerror(block, msg, msgID)
% DES_THROWERROR creates an error message, sets SLLastError and throws an
% error in the form of an error dialog. This function one of the DES
% functions for checking mask dialog errors.
% NOTE: Do not call this function directly.  It needs to be called from the
% des_validateinputs function
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
% Example: 
% msg = 'Number of entity input ports must be a scalar integer in the range
%       1 <= Number of entity input ports <= 4'
%       (See the calls from DES_VALIDATEINPUTS for details of the message
%       construction.)
% des_throwerror(block, msg, 'DES_MASK_InvalidNumber');
% 
% NOTE: The Message returned by SLLastError at the end of execution of this
% function is the input argument 'msg'. The input argument msg is a subset
% of the error message displayed on the error dialog.


%   Copyright 1996-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2008/08/22 20:26:10 $


% Concatenate the multiple error messages
errmsg = '';
for count = 1:length(msg)
    errmsg = [errmsg msg{count} char(10)]; %#ok<AGROW>
end
FullMsg = [char(10) errmsg];

% add product name to identifier
fullMsgID = [des_getproductname ':' char(msgID)];

% Set SLLastError for testing purposes:
BlockHandle = get_param(block,'Handle'); % Handle to the block 

% Create the structure for SLLastError:
errStruct = struct('Type',     repmat({'error'}, 1, length(msg)), ...
                   'MessageID',fullMsgID, ...% Full ID; SimEvents:DES_MASK_XXXX
                   'Message',  msg, ... % The input error message text
                   'Handle',BlockHandle);
               
% Determine the way to throw an error
SimStatusWithErrorChecking = {'initializing';'running';'updating'};
if(isempty(intersect(SimStatusWithErrorChecking,get_param(bdroot(block),'simulationstatus'))))
    % Non-Compile time error checking - use the nag controller
    % Using the error command does not work in this case since Simulink
    % ignores the error.
    CallSLDiagnostic(errStruct);    
else
    % Compile time error checking - use the error function and let Simulink
    % handle the error display part
    error(fullMsgID,FullMsg);
end
    
%---------------------------------------------------
function CallSLDiagnostic(errStruct)
% This function is called when the prefix is not present and an error has
% to be reported. This is done through the SL-SF nag controller.

block = errStruct.Handle;

% compose a NAG 
nag                =  slsfnagctlr('NagTemplate');
nag.type           = 'Error';                             % type of NAG (Error, Warning, Log, Diagnostic)
nag.msg.type       = 'SimEvents Parsing';                  % the type of message
nag.msg.details    = errStruct.Message;                              % your detailed message
nag.msg.summary    =  nag.msg.details;                    % typically, the same as details (will truncate)
nag.sourceFullName = getfullname(block);                  % complete path to the error source
nag.sourceName     = get_param(block,'Name');             % blockName or modelName or stateName, etc.
nag.component      = 'SimEvents';                         % who's
nag.blkHandles     = get_param(block,'handle');
nag.objHandles = get_param(block,'handle');               % Set the object handles so that the block hilites

%  clear any existing old errors from the nag controller?s error stack
%  before pushing new errors onto it
model = bdroot(block);
% This needs to be enhanced to take into account multiple errors from the
% same model. This was added as a response to Code Review comments from
% PaulK. We need to consult with the Simulink team on this enhancement
slsfnagctlr('Clear', model, 'SimEvents');
% Push it to the diagnostic viewer
slsfnagctlr('Push',nag);

% Set sllasterror:
sllasterror(errStruct);

% finished process, display pushed NAGs
%
slsfnagctlr('View');