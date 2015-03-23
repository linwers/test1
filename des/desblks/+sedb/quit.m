function quit(varargin)
% SEDB.QUIT  Quit discrete-event simulation debugging session.
%
%    QUIT  stops the simulation and exits the debugging session.
%
%    See also SEDB.RUNTOEND, SEDB.

% check if debug mode; else throw error
des_validateDebugMode;

des_dbg_cmd_abort();
