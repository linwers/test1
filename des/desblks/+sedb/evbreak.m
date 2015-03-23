function varargout = evbreak(evid)
% SEDB.EVBREAK  Set breakpoint for execution or cancelation of an event.
%
%    EVBREAK('EVID') or EVBREAK EVID sets a breakpoint for execution or
%    cancelation of the event with identifier EVID in the simulation.
%    Use EVCAL to get a list of events in the event calendar at which
%    such breakpoints may be set.
%
%    BID = EVBREAK('EVID') returns the identifier of the breakpoint.
%
%    See also SEDB.EVCAL, SEDB.BREAKPOINTS, SEDB.DISABLE, SEDB.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 

% ensure that debugger is on
des_validateDebugMode;

errID = 'DEBUG_IncorrectArgs';
errMsg = 'Input must be a valid event identifier string.';
errMsgHelper = 'Try using ''evcal'' to inspect scheduled events and their identifiers.';

% arg checking
if ~exist('evid', 'var')
    des_error(errID, [errMsg, char(10), errMsgHelper]);
end
if ~ischar(evid)
    des_error(errID, [errMsg, char(10), errMsgHelper]);
end
toks = regexp(evid, '(ev)(\d+)', 'tokens');
if isempty(toks) || ~strcmp( evid, strcat(toks{1}{:}) )
    des_error(errID, 'Input is not a valid event identifier.');
end

% call builtin
[bpid, evOnCal] = des_dbg_cmd_setEventBreak(evid);

% if evOnCal is false then it implies that we did not find the
% event in the event calendar.
% the event may be scheduled in the future. we issue a warning here

if ~evOnCal
    prev = warning('off', 'backtrace');    
    warning('SimEvents:DebugBreakMayNotHit', ...
        ['Event ', evid, ' was not found on the event calendar. Breakpoint may not be hit.']);
    warning(prev);
end

% if an output was asked for, the provide the breakpoint id
if nargout > 0
    varargout{1} = bpid;
end
