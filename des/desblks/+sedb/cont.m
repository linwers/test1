function cont
% SEDB.CONT  Continue simulation until next breakpoint.
%
%    CONT continues the simulation until the next breakpoint or until
%    the simulation ends.
%
%    See also SEDB.RUNTOEND, SEDB.QUIT, SEDB.STEP, SEDB.

% check debugger on
des_validateDebugMode;

% call builtin function
des_dbg_cmd_continue();
