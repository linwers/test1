function sedebug(varargin)
% SEDEBUG  Debug discrete event simulation.
%   SEDEBUG('MODEL') runs discrete event simulation in the SimEvents debugger. 
%
%   SEDEBUG('MODEL', OPTS) runs the model in the debugger with
%   the options specified in OPTS. Use SE_GETDBOPTS to get the format 
%   of the options structure.
%
%   To see a list of SimEvents debugger functions, enter 'help' at the
%   debugger prompt or 'help sedb' at the MATLAB prompt.
%
%   See also SE_GETDBOPTS, SEDB.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 

% check to see if debugger is already running
try
    throwIfDebuggerOn();
catch me
    me.throwAsCaller;
end

% check args - if user did not provide an opts struct then one will be
% created for the next step
[mdl, opts] = parseArgs(varargin);

% add package import to StartFcn
% when debugger starts, it will execute the import command so that all
% debugger package functions will be on path
[~, dim] = max(size(opts.StartFcn));
opts.StartFcn = cat(dim, {'import sedb.*'}, opts.StartFcn);

% open the model if not opened
if isempty(find_system(0, 'Name', mdl))
    open_system(mdl); % will throw error if model doesn't exist
end

% check that we were provided with a top level model
% one cannot debug individual subsystems
if ~strcmp(mdl, bdroot(mdl))
    des_error('SEDEBUG_CannotDebugSubsystem', ...
        ['The name ', strrep(mdl, char(10), ' '), ...
        ' is not the name of a SimEvents model.', char(10), ...
        'Try: sedebug( bdroot(''', strrep(mdl, char(10), ' '), ''') )']);
end

% check if this is a SimEvents model
cfg = getActiveConfigSet(mdl);
try
    get_param(cfg, 'SimEventsActiveTab');
catch me
    UnusedVariable(me);
    des_error('SEDEBUG_NotASimEventsModel', ...
        ['The model ', mdl, ' does not contain any SimEvents blocks.']);
end

% check that the model is not running
actualSimStatus = get_param(mdl, 'SimulationStatus');
if ~strcmpi(actualSimStatus, 'stopped')
    des_error('SEDEBUG_ModelIsRunning', ...
        ['The model ', mdl, ' is currently running. Cannot start a debugger session.']);
end

% set debuggee data
des_dbg_int_SetDBData(mdl, opts);
sldesCleaner = onCleanup( @() des_dbg_int_cleanup() );

% start the model
sim(mdl, [], simset('DstWorkspace', 'parent'));



% ----------------------------------------------------------------------- %
% parse arguments
% return model name mdl and options structure opts
%
function [mdl, opts] = parseArgs(inputargs)
errorID = 'SEDEBUG_IncorrectArgs';
try
    % first arg - model name
    if isempty(inputargs)
        des_error(errorID, ...
            ['First input argument must be a SimEvents model name.', char(10), ...
            'Try: sedebug(bdroot)']);
    end
    mdl = inputargs{1};
    
    % second arg if provided - options struct
    opts = struct();
    if length(inputargs) > 1
        opts = inputargs{2};
    end
    if ~isstruct(opts)
        des_error(errorID, ...
            ['Second input argument, if provided, must be an options structure.', char(10), ...
            'Type ''help se_getdbopts'' for more information on options structures.']);
    end
    opts = validateOptionsStruct(opts);

catch me
    me.throwAsCaller;
end


% ----------------------------------------------------------------------- %
% throw an error if the debugger is on
%
function throwIfDebuggerOn
errID = 'SEDEBUG_OnlyOneDebugInstance';
errMsg = 'Another model is currently running in the SimEvents debugger. Cannot start another instance.';
dbgIsOn = 0;
try
    dbgIsOn = feature('des_getIsDebugModeOn');
catch me
    UnusedVariable(me);
    % simevents is not even loaded; we are okay to start debugger
end
if dbgIsOn
    % simevents is loaded and debugger is on; need to error out
    des_error(errID, errMsg);
end


% ----------------------------------------------------------------------- %
% check the options structure
% create one if not provided
%
function testStruct = validateOptionsStruct(testStruct)
errorID = 'SEDEBUG_IncorrectOptionsStruct';
more_info_msg = 'Type ''help se_getdbopts'' for more information on options structures.';
if isfield(testStruct, 'StartFcn')
    if ischar(testStruct.StartFcn)
        testStruct.StartFcn = cellstr(testStruct.StartFcn);
    end
    if ~iscell(testStruct.StartFcn)
        des_error(errorID, ...
            ['The ''StartFcn'' field in the options structure must be a cell array.', ...
            char(10), more_info_msg]);
    end
    % check each row
    if (~any(cellfun(@ischar, testStruct.StartFcn)))
        des_error(errorID, ...
            ['Incorrect format for StartFcn field in options structure.',...
            char(10), more_info_msg]);
    end
else
    % create a StartFcn field with empty value
    % we need to do this for the package import command
    testStruct.StartFcn = [];
end


% used to indicate unused variable
% will be here until matlab implements ~ operator to indicate this
function UnusedVariable(varargin)
% empty function
