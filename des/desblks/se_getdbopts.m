function opts = se_getdbopts
% SE_GETDBOPTS  Get SimEvents debugger options structure
%
% OPTS = SE_GETDBOPTS returns an empty options structure that you can
% configure for your debugging session. This structure can be used as an 
% input to the SEDEBUG function. 
% 
% The options structure has the following fields:
%
% 'StartFcn' - Use this field to provide a startup script of debugging
% commands for your session in the form of a cell array of strings.
%
% Example:
%
%    opts = se_getdbopts;
%    opts.StartFcn = {'step', 'step', 'quit'};
%    sedebug('sedemo_timeout', opts);
%
%    The above example will start the debugger and immediately execute
%    the commands in the StartFcn specified in the debugger.


opts = struct( 'StartFcn', [] );
