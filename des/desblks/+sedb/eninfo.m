function varargout = eninfo(id)
% SEDB.ENINFO  Entity information in discrete event simulation.
%
%    ENINFO ENID or ENINFO('ENID') displays information about the location,
%    attributes, timers and timeouts on the entity with identifier 'ENID'.
%
%    X = ENINFO('ENID') returns a structure containing information about
%    the entity with identifier 'ENID'.
%
%    The returned structure has the following fields:
%      'Time'         current simulation time (at which this is a snapshot)
%      'Location'     block in which the entity is currently present
%      'Attributes'   structure containing attribute values (if any)
%      'Timers'       structure containing elapsed times on timers (if any)
%      'Timeouts'     structure containing times of timeout (if any)
%
%    Use BLKINFO to obtain a list of entities in a specific block along
%    with their identifiers.
%
%    See also SEDB.BLKINFO, SEDB.EVINFO, SEDB.

% validate debugger
des_validateDebugMode;

errID = 'DEBUG_IncorrectArgs';

if ~exist('id', 'var')
    des_error(errID, 'An entity identifier is required as input.');
end
if ~ischar(id)
    des_error(errID, 'Input argument must be a string entity identifier.');
end

% call builtin
[att, tmr, tou, loc] = des_dbg_cmd_entityinfo(id);

% check for empty attributes and eliminate them
% we need to do this because the attribute definition may contain
% attributes that haven't actually been set yet.
if iscell(att)
    att(:,cellfun(@isempty, att(1,:))) = [];
else
    % if the id is not found, then the builtin will return scalar 0
    % else it will return a cell array of event params
    des_error(errID, ...
        ['Could not find entity ', id, ' in the simulation.']);
end

% eliminate empty cells in timeouts (these are timeouts that have been
% executed and hence no longer live on the entity)
tou( :, cellfun( @isempty, tou(1,:) ) ) = [];

% decide whether to print out table or return struct
if nargout == 0 % then we are going to print out a table
    
    MAXLEN = 55;

    % first line of header
    str1 = sprintf('\nEntity (%s) Current State', id);
    str2 = sprintf('T = %.15f', sedb.simtime);
    
    % right indent the time value
    % create appropriate number of spaces
    spaces = repmat( ' ', 1, MAXLEN - length(str1) );
    str = [  str1  spaces  str2  ];
    
    % second line of header (location)
    fprintf('%s\n', str);
    fprintf('Location: %s\n\n', ...
        des_createBlockHyperlink(loc)); % hyperlink the block name
    
    % initialize string that contains which fields the entity does not have
    noString = '';

    % print attributes if any
    if (~isempty(att))
        fprintf('Attributes:\n');
        printTable(att, {'Name', 'Value'});
    else
        noString = 'Attributes, ';
    end

    % print timeouts if any
    if (~isempty(tou))
        fprintf('Timeouts:\n');
        printTable(tou, {'Tag', 'TimeOfTimeout', 'Event'});
    else
        noString = [noString, 'Timeouts, '];
    end

    % print timers if any
    if (~isempty(tmr))
        fprintf('Timers:\n');
        printTable(tmr, {'Tag', 'ElapsedTime'});
    else
        noString = [noString, 'Timers, '];
    end
    
    % print out which fields the entity does not have
    if ~isempty(noString)
        noString = noString(1:end-2); % eliminate last space and comma
        fprintf('%s: None\n\n', noString);
    end
    
else % we are going to return a struct
    
    % process cell arrays and convert to structs
    att = convert_cell_to_struct(att);
    tmr = convert_cell_to_struct_specify_fields(tmr, {'Tag', 'ElapsedTime'});
    tou = convert_cell_to_struct_specify_fields(tou, {'Tag', 'TimeOfTimeout', 'Event'});
    
    % form output
    out.Time = sedb.simtime;
    out.Location = loc;
    out.Attributes = att;
    out.Timers = tmr;
    out.Timeouts = tou;
    
    varargout{1} = out;
    
end

% ======================================================================= %

function s = convert_cell_to_struct(s)
% CONVERT_CELL_TO_STRUCT Convert a cell array to structure with first row
% of cell array containing the field names.
%
%    Used for entity attribute structure. In the attribute structure, the
%    attribute names are the field names and the attribute values are the
%    field values.

if isempty(s)
    s = struct([]);
else
    s = cell2struct(s(2,:), s(1,:), 2);
end

% ======================================================================= %

function s = convert_cell_to_struct_specify_fields(s, fnames)
% CONVERT_CELL_TO_STRUCT_SPECIFY_FIELDS Convert a cell array to structure
% with externally specified field names.
%
%    Used for entity timer and timeout structures. In these structures, the
%    fields are specified in a cell array fnames.

if isempty(s)
    s = struct([]);
else
    s = cell2struct(s', fnames, 2);
end

% ======================================================================= %

function printTable(data, colHeaders)
% PRINTTABLE Print entity data table (either attributes or timers or
% timeouts).
%
%    PRINTTABLE(DATA, COLHEADERS) prints an entity data table where the
%    table data is in the cell array DATA while the column headers are in
%    the cell array COLHEADERS.

% minimum column widths
minColWidths = [2 8 13 6];
minColWidths = minColWidths(1: size(data, 1)); % adjust to suit size of data

% convert scalars in data to strings since we want to print them
idx = cellfun(@isscalar, data);
data( idx ) = cellfun( @num2str, data(idx), 'UniformOutput', false );

% convert numeric non-scalars to their dimensions
% since we want to print non-scalars as their dimensions only
idx = cellfun( @(x) isnumeric(x) && ~isscalar(x), data );
data( idx ) = cellfun( @(x) ['[', num2str(size(x,1)), 'x', num2str(size(x,2)), ']'], ...
    data(idx), 'UniformOutput', false );

% add column headers to the data to be printed
% list now contains all the data that needs to be printed
list = [colHeaders; data'];

% adjust minimum column widths if necessary
% we will need to increase minimum column width if any data being printed
% in that column has a length more than it
% colWidths contains the actual column widths

colWidths = minColWidths;
for i = 2: length(minColWidths) % first row contains headers
    colWidths(i) = max( minColWidths(i), max(cellfun(@length, data(1,:))) ) + 2;
end

% print out all data in tabular form
for i = 1: size(list, 1)
    curr = list(i, :);
    
    % create appropriate number of spaces
    % num_spaces = column_width - length_of_column_data
    s = @(x) repmat(' ', 1, colWidths(x)-length(curr{x-1}));
    temp = arrayfun(s, 2:length(colWidths), 'UniformOutput', false);
    sp = { '  '  temp{:}};
    
    % intersperse spaces and text for each row into one cell in
    % the correct order
    listRow = cell(1, (length(curr) + length(colWidths)));
    [listRow(2:2:end)] = deal(curr(:)); % text to be printed
    [listRow(1:2:end-1)] = deal(sp(:)); % spaces to be left
    
    % print out the row in breakpoint table
    formatStr = [repmat('%s', 1, length(listRow)), '\n'];
    fprintf(1, formatStr, listRow{:});
    
    % repeat for next row
end
fprintf('\n');

% [eof]
