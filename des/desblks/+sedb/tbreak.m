function varargout = tbreak(time)
% SEDB.TBREAK  Set timed breakpoint in discrete-event simulation.
%
%    TBREAK(T) or TBREAK T sets a breakpoint for time T in the discrete- 
%    event simulation. During debugging, the simulation stops at the first
%    operation at or after time T. T is a numeric scalar or a string that
%    represents a number.
%
%    ID = TBREAK(T) returns the identifiers of the breakpoint.
%
%    See also SEDB.EVBREAK, SEDB.BREAKPOINTS, SEDB.

% ensure that debugger is on
des_validateDebugMode;

errID = 'DEBUG_IncorrectArgs';
errMsg = 'Input argument must either be a numeric scalar or a string that represents a number.';

if ischar(time)
    % convert to number
    time = str2double(time);
    if isnan(time) || length(time) > 1
        des_error(errID, errMsg);
    end
end

if isnumeric(time)
    if length(time) > 1
        des_error(errID, errMsg);
    end
else
    des_error(errID, errMsg);
end

% we now set the breakpoint
id = des_dbg_cmd_setTimedBreak(time);

% check break tme against current time
if (time < sedb.simtime)
    des_warning('DebugBreakMayNotHit', ...
        'Specified time of break is in the past. Breakpoint will not be hit.');
end
if (time == sedb.simtime)
    des_warning('DebugBreakMayNotHit', ...
        'Specified time of break is the current time. Breakpoint will not be hit.');
end

% check break time against sim stop time
dbgmodel = des_dbg_int_getModelName;
if ( time > str2double(get_param(dbgmodel, 'StopTime')) )
    des_warning('DebugBreakMayNotHit', ...
        'Specified time of break is beyond simulation stop time. Breakpoint will not be hit.');
end

if nargout > 0
    varargout{1} = id;
end
