function disable(varargin)
% SEDB.DISABLE  Disable breakpoints in discrete-event simulation.
%
%    DISABLE ID1 ID2 ... disables the breakpoints having identifiers ID1,
%    ID2 and so on.
%
%    DISABLE ALL disables all breakpoints in the simulation.
%
%    DISABLE(C) disables the breakpoints in the cell array C.
%
%    To see breakpoints and their identifiers, use BREAKPOINTS.
%
%    See also SEDB.BREAKPOINTS, SEDB.ENABLE, SEDB.BDELETE, SEDB.

% call helper function
des_dbg_breakpointhelper('des_dbg_cmd_disableBreakPoints', varargin);
