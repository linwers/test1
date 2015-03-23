function runtoend(varargin)
% SEDB.RUNTOEND  Run until end of discrete-event simulation.
%
%    RUNTOEND  continues the simulation until the end ignoring any
%    breakpoints that have been set
%
%    See also SEDB.QUIT, SEDB.

% check if debug mode; else throw error
des_validateDebugMode;

des_dbg_cmd_runtoend();
