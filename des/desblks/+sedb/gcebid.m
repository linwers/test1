function blkid = gcebid
% SEDB.GCEBID  Get identifier of currently executing block.
%
%    X = GCEBID returns the identifier of the block that is currently
%    undergoing an operation in a discrete-event simulation.
%
%    Example:
%
%    When the debugger reports that an event is being scheduled,
%    GCEBID returns the identifier of the block that schedules
%    the event.
%
%    Use GCEB to get the full path name of the block.
%
%    See also SEDB.GCEB, SEDB.BLKINFO, SEDB.GCEV, SEDB.GCEN, SEDB.

% debugger on check
des_validateDebugMode;

% call builtin
blkid = des_dbg_cmd_getCurrentBlockId();
