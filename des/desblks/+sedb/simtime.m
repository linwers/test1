function t = simtime
% SEDB.SIMTIME  Current time in discrete-event simulation.
%
%    T = SIMTIME returns the current simulation time in the
%    discrete-event simulation.
%
%    See also SEDB.CURRENTOP, SEDB.

% check debugger on
des_validateDebugMode;

% call builtin function
t = des_dbg_cmd_simtime();
