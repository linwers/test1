function simeventsstartup(varargin)
%SIMEVENTSSTARTUP Set default model settings for discrete-event simulation.
%   SIMEVENTSSTARTUP('des') changes the default Simulink model settings to
%   values appropriate for discrete-event simulation modeling.   'des' is
%   the default argument.
%
%   SIMEVENTSSTARTUP('hybrid') changes the default Simulink model settings
%   to values appropriate for modeling systems that combine time-driven and
%   discrete-event-driven behavior.  
%
%   Invoke this function in your own STARTUP.M file to install these
%   defaults each time you run MATLAB.
%
%   See the Model Parameters section of the Using Simulink manual for more
%   information on model settings.
%
%   See also SIMEVENTSCONFIG.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2008/08/22 20:25:57 $


if nargin > 1,
    error ([des_getproductname ':IllegalNuumberArgument'], ...
        ['Illegal number of arguments for ''' mfilename '''. No more than one argument is allowed']);
end

des_arg_name = 'des';
hybrid_arg_name = 'hybrid';

% Set default to 'des'. 
if nargin < 1,
    type = des_arg_name;
else
    type = varargin{1};
end

% compare argument to possibilities
if strcmpi(type,des_arg_name)
    
    % DES only settings  using the VariableStepDiscrete solver and
    % setting max time to inf. 
    set_param(0, ...
    'SolverName',            'VariableStepDiscrete', ...
    'SolverType',            'Variable-step', ...
    'MaxStep',               'inf', ...               
    'StartTime',             '0.0', ...
    'StopTime',              '10.0', ...
    'SaveTime',              'off', ...
    'SaveOutput',            'off', ...
    'AlgebraicLoopMsg',      'error', ...
    'SolverPrmCheckMsg',     'none');

    fprintf(['\nChanged default Simulink settings for SimEvents models \n' ...
        'for discrete-event modeling (simeventsstartup.m).\n\n']);
    
elseif strcmpi(type,hybrid_arg_name),

    % Hybrid DES and Cont. time settings using the ode45 solver and
    % setting max time to auto. 
    set_param(0, ...
    'SolverName',            'ode45', ...
    'SolverType',            'Variable-step', ...
    'MaxStep',               'inf', ...               
    'StartTime',             '0.0', ...
    'StopTime',              '10.0', ...
    'SaveTime',              'off', ...
    'SaveOutput',            'off', ...
    'AlgebraicLoopMsg',      'error', ...
    'SolverPrmCheckMsg',     'none');

    fprintf(['\nChanged default Simulink settings for SimEvents models \n' ...
        'for hybrid discrete-event and time-driven modeling (simeventsstartup.m).\n\n']);
else
    error ([des_getproductname ':IllegalArgument'], ...
        ['Illegal value for setup type for ''' mfilename ''', The type must be either ''des'' or ''hybrid''']);
end

% [EOF]
