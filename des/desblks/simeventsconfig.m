function simeventsconfig(varargin)
%SIMEVENTSCONFIG Change model settings for discrete-event simulation.
%   SIMEVENTSCONFIG changes settings of the current system to values
%   appropriate for discrete-event simulation modeling.
%
%   SIMEVENTSCONFIG(SYS,'des') changes settings of the specified system to
%   values appropriate for discrete-event simulation modeling.  GCS is the 
%   default SYS name and 'des' is the configuration default argument.
%
%   SIMEVENTSCONFIG(SYS,'hybrid') changes settings of the specified system
%   to values appropriate for modeling systems that combine time-driven and
%   discrete-event-driven behavior.
%
%   See the Model Parameters section of the Using Simulink manual for more
%   information on model settings.
%
%   See also SIMEVENTSSTARTUP.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2008/08/22 20:25:56 $

if nargin > 2,
    error ([des_getproductname ':IllegalNuumberArgument'], ...
        ['Illegal number of arguments for ''' mfilename '''. No more than two arguments are allowed']);
end

des_arg_name = 'des';
hybrid_arg_name = 'hybrid';

% Set default for first argument to gcs. 
if nargin < 1,
    system = gcs;
else
    system = varargin{1};
end

% check for valid system by trying to get the name
try,
    get_param(system,'name');
catch
    error ([des_getproductname ':IllegalArgument'], ...
        ['SYS must be a valid model name.']);    
end
system = bdroot(system);

% check for whether the system is locked. 
if syslocked(system),
    error ([des_getproductname ':SystemIsLocked'], ...
        ['model must not be a locked system.']);    
end

% Set default for the second argument to 'des'. 
if nargin < 2,
    type = des_arg_name;
else
    type = varargin{2};
end

% compare argument to possibilities
if strcmpi(type,des_arg_name)
    
    % DES only settings  using the VariableStepDiscrete solver and
    % setting max time to inf. 
    set_param(system, ...
    'SolverName',            'VariableStepDiscrete', ...
    'SolverType',            'Variable-step', ...
    'MaxStep',               'inf', ...               
    'SaveTime',              'off', ...
    'SaveOutput',            'off', ...
    'AlgebraicLoopMsg',      'error', ...
    'SolverPrmCheckMsg',     'none');

    fprintf(['\nChanged Simulink model settings for ''' system ''' \n' ...
        'for discrete-event modeling.\n\n']);
    
elseif strcmpi(type,hybrid_arg_name),

    % Hybrid DES and Cont. time settings using the ode45 solver and
    % setting max time to inf. 
    set_param(system, ...
    'SolverName',            'ode45', ...
    'SolverType',            'Variable-step', ...
    'MaxStep',               'inf', ...               
    'SaveTime',              'off', ...
    'SaveOutput',            'off', ...
    'AlgebraicLoopMsg',      'error', ...
    'SolverPrmCheckMsg',     'none');

    fprintf(['\nChanged Simulink model settings for ''' system ''' \n' ...
        'for hybrid discrete-event and time-driven modeling.\n\n']);
else
    error ([des_getproductname ':IllegalArgument'], ...
        ['Illegal value for setup type for ''' mfilename ''', The type must be either ''des'' or ''hybrid''']);
end

function y = syslocked(sys)
% SYSLOCKED Determine whether a system is locked.
%  This function is error-protected against calls on
%  subsystems or blocks, which do not have a lock parameter.

y = ~isempty(sys);
if y,
   y = strcmpi(get_param(bdroot(sys),'lock'),'on');
end
% [EOF]
