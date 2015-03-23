function step(varargin)
% SEDB.STEP  Single step in discrete-event simulation.
%    STEP  goes to the next step in the simulation.
%
%    STEP IN  steps to the next level in the simulation hierarchy.
%
%    STEP OUT steps to the previous level in the simulation hierarchy.
%
%    STEP OVER  steps over the current action to the next step at the same
%    level in the simulation hierarchy.
%
% See also SEDB.RUNTOEND, SEDB.

des_validateDebugMode;

if nargin == 0
    varargin{1} = 'in';
end

if strcmp(varargin{1}, 'over')
    level = 0;
elseif strcmp(varargin{1}, 'in')
        level = 1;
elseif strcmp(varargin{1}, 'out')
        level = -1;
else
    me = MException('SEDEBUG:IncorrectFcnArgs', ...
        'If an argument to STEP is provided, then it must be ''in'', ''out'', or ''over'' only.');
    me.throwAsCaller;
end

% call the builtin function
des_dbg_cmd_step(level);
