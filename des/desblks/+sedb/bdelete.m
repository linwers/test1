function bdelete(varargin)
% SEDB.BDELETE  Delete breakpoints in discrete-event simulation.
%
%    BDELETE ID1 ID2 ... deletes the breakpoints having identifiers ID1,
%    ID2 and so on. 
%
%    BDELETE ALL deletes all breakpoints in the simulation.
%
%    BDELETE(C) deletes the breakpoints in the cell array C.
%
%    To see breakpoints and their identifiers, use BREAKPOINTS.
%
%    See also SEDB.BREAKPOINTS, SEDB.DISABLE, SEDB.ENABLE, SEDB.

% call a helper function
des_dbg_breakpointhelper('des_dbg_cmd_deleteBreakPoints', varargin);
