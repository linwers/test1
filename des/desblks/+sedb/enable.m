function enable(varargin)
% SEDB.ENABLE  Enable breakpoints in discrete-event simulation.
%
%    ENABLE ID1 ID2 ... enables breakpoints having identifiers ID1, ID2 and
%    so on.
%
%    ENABLE ALL enables all breakpoints in the simulation.
%
%    ENABLE(C) enables the breakpoints in the cell array C.
%
%    To see breakpoints and their identifiers, use BREAKPOINTS.
%
%    See also SEDB.BREAKPOINTS, SEDB.DISABLE, SEDB.BDELETE, SEDB.

% call helper function
des_dbg_breakpointhelper('des_dbg_cmd_enableBreakPoints', varargin);
