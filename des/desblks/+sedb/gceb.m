function blkname = gceb
% SEDB.GCEB  Get name of currently executing block.
%
%    X = GCEB returns the full path name of the block that is currently
%    undergoing an operation in a discrete-event simulation.
%
%    Example:
%
%    When the debugger displays that an event is being scheduled, GCEB
%    returns the path name of the block that schedules that event.
%
%    See also SEDB.GCEBID, SEDB.BLKINFO, SEDB.GCEV, SEDB.GCEN, SEDB.

% debugger on check
des_validateDebugMode;

% call builtin
blkname = des_dbg_cmd_getCurrentBlock();
