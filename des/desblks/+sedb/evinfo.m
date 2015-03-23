function varargout = evinfo(id)
% SEDB.EVINFO  Event information in discrete event simulation.
%
%    X = EVINFO('EVID') returns a structure containing information about
%    the event with identifier 'EVID'. 
%
%    The returned structure has the following fields:
%      'ID'           identifier of event
%      'EventType'    type of event
%      'EventTime'    time of event
%      'Priority'     priority of event
%      'Entity'       identifier of associated entity
%      'Block'        block which will execute the event
%
%    Use EVCAL to obtain a list of events in the event calendar and their
%    identifiers.
%
%    See also SEDB.EVCAL, SEDB.

% validate debugger
des_validateDebugMode;

errID = 'DEBUG_IncorrectArgs';

if ~exist('id', 'var')
    des_error(errID, 'An event identifier is required as input.');
end
if ~ischar(id)
    des_error(errID, 'Input argument must be a string event identifier.');
end
toks = regexp(id, '(ev)(\d+)', 'tokens');
if isempty(toks) || ~strcmp( id, strcat(toks{1}{:}) )
    des_error(errID, 'Input is not a valid event identifier.');
end

% call builtin
ev = des_dbg_cmd_eventinfo(id);

% if the id is not found, then the builtin will return scalar 0
% else it will return a cell array of event params
if ~iscell(ev)
    des_error(errID, ...
        ['The identifier ', id, ' does not represent an event currently on the event calendar.']);
end

[EVTIME, BLOCK] = deal(3,6);
fieldNames = {'ID', 'EventType', 'EventTime', 'Priority', 'Entity', 'Block'};

if nargout == 0
    
    % we need to print a text information and not return a variable
    
    MAXLEN = 55;

    % first line of header
    str1 = sprintf('\nEvent (%s) Current State', id);
    str2 = sprintf('T = %.15f', sedb.simtime);
    
    % right indent the time value
    % create appropriate number of spaces
    spaces = repmat( ' ', 1, MAXLEN - length(str1) );
    str = [  str1  spaces  str2  ];
    fprintf('%s\n', str);
    
    % now print out the event information
    
    fcnSpaces = @(x) repmat(' ', 1, 15-length(fieldNames{x}));
    
    % data type handling; convert everything to string
    ev{EVTIME} = num2str(ev{EVTIME});
    ev{BLOCK} = des_createBlockHyperlink(ev{BLOCK});
    
    fprintf('\n');
    for i = 2: length(ev) % skip id
        fprintf('  %s%s:%s%s\n', ...
            fieldNames{i}, ...
            fcnSpaces(i), ...
            '   ', ...
            ev{i});
    end
    fprintf('\n');
    
else

    % we need to return a structure
    
    % convert to struct
    out = cell2struct(ev, fieldNames,  2);
    
    % if entity is none then make it empty
    if strcmp(out.Entity, '<none>')
        out.Entity = '';
    end
    
    varargout{1} = out;

end
