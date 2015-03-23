function enid = gcen
% SEDB.GCEN  Get identifier of entity currently undergoing operation.
%
%    X = GCEN returns the identifier of the entity that is currently
%    undergoing an operation in a discrete-event simulation.
%
%    Example:
%
%    When the debugger reports that an entity is advancing, GCEN
%    returns the identifier of that entity.
%
%    See also SEDB.GCEV, SEDB.GCEB, SEDB.CURRENTOP, SEDB.

% debugger on check
des_validateDebugMode;

% call builtin
enid = des_dbg_cmd_getCurrentEntity();

if strcmp(enid, '<none>')
    enid = '';
end
