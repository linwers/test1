function varargout = detail(varargin)
% SEDB.DETAIL  Set debugger display options in discrete-event simulation.
%
%     DETAIL('PARAM1', VALUE1, 'PARAM2', VALUE2, ...) configures the
%     debugger to include or omit certain kinds of information in debugger
%     displays.
%
%     Parameter names:
%        'ev'   Event operations (see Exception below)
%        'en'   Entity operations
%        'cal'  Event calendar information
%
%     Parameter values:
%        1      Include information 
%        0      Omit information, except upon reaching a breakpoint
%
%     Exception: Independent operations representing event executions are
%     included in debugger displays if at least one of the detail
%     settings is 1 (on), even if the 'ev' setting is 0 (off). 
%
%     DETAIL('none') configures the debugger to omit all displays, except
%     upon reaching breakpoints. This syntax is the same as
%     detail('en', 0, 'ev', 0, 'cal', 0).
%
%     DETAIL('default') sets the debugger to its default detail
%     configuration. This syntax is the same as
%     detail('en', 1, 'ev', 1, 'cal', 0).
%
%     DETAIL('all') configures the debugger to include all displays.
%     This syntax is the same as detail('en', 1, 'ev', 1, 'cal', 1).
%
%     PREV = DETAIL(...) additionally returns a structure that describes the 
%     previous detail configuration. The fields of S and their values are 
%     the same as the parameter names and values above.
%
%     DETAIL(S) uses the structure S to set the detail configuration. The
%     three fields of S and their values are the same as the parameter
%     names and values above.
%
%     Examples:
%        detail('en', 1, 'ev', 0, 'cal', 0);
%        prev = detail('en', 1, 'cal', 0, 'ev', 0) % Return previous detail configuration
%        detail('en', 0)  % Change configuration of entity display only.
%        detail(prev)  % Restore previous configuration.
%  
%     See also SEDB.BLKINFO, SEDB.EVINFO, SEDB.EVCAL, SEDB.ENINFO, SEDB.


% check if debugger on
des_validateDebugMode;

errID = 'DEBUG_IncorrectArgs';

% function behavior:
% if no output argument then we print the newest configuration
% if output argument then we return the previous configuration

% note: the builtin function always requires three input arguments.
% if no change is to be made to a particular logging parameter then an
% empty matrix is passed in to the builtin function.

% before we begin processing inputs, let's save the current detail value
% which we might have to return as previous config

[ev_prev, en_prev, cal_prev] = des_dbg_cmd_currLogOpts([],[],[]);

if nargin == 0
    
    [ev, en, cal] = des_dbg_cmd_currLogOpts([],[],[]);

elseif nargin == 1

    % if one arg, then it should either be
    % struct or string ('none' / 'default' / 'all')

    if isstruct(varargin{1})
        
        s = varargin{1};
        
        % check fields of struct
        if ~isequal(fieldnames(s), {'ev'; 'en'; 'cal'})
            des_error(errID, 'Incorrect structure format provided.');
        end
        
        % check values of struct fields; they must all be numeric
        structvals = struct2cell(s);
        if ~any(cellfun(@isnumeric, structvals))
            des_error(errID, 'Incorrect structure field values provided.');
        end
        
        % all is well; prepare inputs to builtin function
        [ev, en, cal] = deal(structvals{:});
        
    elseif ischar(varargin{1})
        
        switch varargin{1}
            case {'default'}
                [ev, en, cal] = deal(1, 1, 0);
            case {'none'}
                [ev, en, cal] = deal(0, 0, 0);
            case {'all'}
                [ev, en, cal] = deal(1, 1, 1);
            otherwise
                des_error(errID, ...
                    'Incorrect input argument provided. Predefined detail policies are only ''default'' and ''none''.');
        end
        
    else
        
        des_error(errID, 'Incorrect input arguments provided.');
        
    end
    
    % call the builtin function and get policies that were set
    [ev, en, cal] = des_dbg_cmd_currLogOpts(ev, en, cal);
    
else
    
    % we expect name value pair inputs
    
    if mod(length(varargin), 2)
        des_error(errID, ...
            'If multiple inputs are provided, they must be parameter-value pairs.');
    end
    
    % ensure that parameter names are all chars
    % and parameter values are all numeric
    if ~any(cellfun(@ischar, varargin(1:2:end))) || ...
        ~any(cellfun(@isnumeric, varargin(2:2:end)))
        des_error(errID, ...
            'Parameter names must be strings and parameter values must be numeric.');
    end
    
    % get all values
    for i = 1: 2: length(varargin)
        if strcmp(varargin{i}, 'ev')
            ev_in = double(varargin{i+1});
        elseif strcmp(varargin{i}, 'en')
            en_in = double(varargin{i+1});
        elseif strcmp(varargin{i}, 'cal')
            cal_in = double(varargin{i+1});
        else
            des_error(errID, ...
                ['Incorrect parameter ', varargin{i}, ...
                ' provided. Valid parameters are ''ev'', ''en'' and ''cal''.']);
        end
    end
    
    % assign values read to a cell
    % if a particular value is not provided then the cell defaults to an
    % empty matrix
    % this allows users to specify less than 3 param-value pairs making
    % this function more convenient.
    
    inputcell = cell(1,3);
    if exist('ev_in', 'var')
        inputcell{1} = ev_in;
    end
    if exist('en_in', 'var')
        inputcell{2} = en_in;
    end
    if exist('cal_in', 'var')
        inputcell{3} = cal_in;
    end
    
    % call the builtin functions
    [ev, en, cal] = des_dbg_cmd_currLogOpts(inputcell{:});
    
end

% at this point we have finished processing the input arguments provided
% now we either print newest values or return previous structure

if nargout > 0
    
    % return the previous value in structure
    
    out.ev = ev_prev;
    out.en = en_prev;
    out.cal = cal_prev;
    varargout{1} = out;
    
else
    
    % print the newest values as text
    fprintf('\n');
    fprintf( '  Event Operations  (ev)   :  %s\n', bool2onoff(ev) );
    fprintf( '  Entity Operations (en)   :  %s\n', bool2onoff(en) );
    fprintf( '  Event Calendar    (cal)  :  %s\n', bool2onoff(cal));
    fprintf('\n');
    
end

% we are done with everything, so we now decide whether to throw warning
% a warning will occur if the detail has been set to 'none' and there are
% no breakpoints currently set

% disable throwing of this warning; need further design review

% if ~all( [ev, en, cal] )
%     bp = sedb.breakpoints;
%     if isempty(bp)
%         % need to throw warning
%         warnID = 'DEBUG_DetailNoneMayEndSim';
%         warnMsg = [ ...
%             'The debugger''s detail level is set to ''none'' and there are no breakpoints set.', char(10), ...
%             'Continuing the simulation will result in the model running until completion.', char(10)];
%         des_warning(warnID, warnMsg);
%     end
% end


function out = bool2onoff(in)
% BOOL2ONOFF Convert logical input to 'on' or 'off' strings

if in
    out = 'on';
else
    out = 'off';
end

% eof
