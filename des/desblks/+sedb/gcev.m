function evid = gcev
% SEDB.GCEV  Get identifier of event currently undergoing operation.
%
%    X = GCEV returns the identifier of the event that is currently
%    undergoing an operation in a discrete-event simulation.
%
%    Example:
%
%    When the debugger reports that an event is being scheduled, 
%    GCEV returns the identifier of that event.
%
%    See also SEDB.GCEN, SEDB.GCEB, SEDB.CURRENTOP, SEDB.

% debugger on check
des_validateDebugMode;

% call builtin
evid = des_dbg_cmd_getCurrentEvent();
