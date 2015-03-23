function currentop
% SEDB.CURRENTOP Current operation in discrete-event simulation.
%
%    CURRENTOP displays the current simulation operation. This includes:
%    - Current top-level independent operation being executed
%      This may be an event execution or a time-based signal update that
%      was detected.
%    - Current dependent operation awaiting execution.
%
%    See also SEDB.SIMTIME, SEDB.

% ensure debugger on
des_validateDebugMode;

% call builtin function
des_dbg_cmd_displayCurrentSimState;
