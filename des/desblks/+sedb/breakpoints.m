function varargout = breakpoints
% SEDB.BREAKPOINTS  List breakpoints in discrete-event simulation.
%
%    BREAKPOINTS displays a list of breakpoints in the simulation.
%
%    S = BREAKPOINTS returns a structure containing information about
%    breakpoints in the simulation. The fields are:
%
%       'ID'        Identifier of the breakpoint
%       'Type'      Type of breakpoint
%       'Value'     Value associated with the breakpoint
%       'Enabled'   1 if the breakpoint is enabled, and 0 otherwise
%
%    See also SEDB.TBREAK, SEDB.EVBREAK, SEDB.BLKBREAK, SEDB.BDELETE,
%             SEDB.DISABLE, SEDB.

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/11/13 04:15:05 $

% validate debug mode
des_validateDebugMode;

% constants
[IDX_ID, IDX_Type, IDX_Value, IDX_Enabled] = deal(1,2,3,4);

% call builtin function to get all breakpoint info
list = des_dbg_cmd_getAllBreakPoints();

% 'list' is a cell array (4xN) of breakpoint info where N is the total
% number of breakpoints. In each column, the 4 elements (in order) are the
% same as the struct fields described above in the help.

% eliminate empty columns
% breakpoints that have been expired, but not yet deleted result in 
% empty columns in 'list'
idxToKeep = ~cellfun(@isempty, list(IDX_ID,:));
list = list(:, idxToKeep);

% sort breakpoints according to ids
% the builtin function returns breakpoints by collection (active, then expired)
% the user would like to see them in the order they were set
ID = 1;
[~, sortIdx] = sort(list(ID,:));
list = list(:,sortIdx);

if nargout > 0 % if user asked for output argument
    
    % give out a struct
    varargout{1} = struct( ...
        'ID', list( IDX_ID, : ), ...
        'Type', list( IDX_Type, : ), ...
        'Value', list( IDX_Value, : ), ...
        'Enabled', list( IDX_Enabled, : ) ...
        );
    
else
    
    % print a nice looking table
    fprintf('\nList of Breakpoints: ');

    if isempty(list)
        fprintf('None\n\n');
        return;
    else
        fprintf('\n\n'); % some spacing
    end

    % convert enabled status to string
    % enabled status comes out as 1 or 0, and we want to convert it into
    % the string 'yes' or 'no'
    list(4,:) = cellfun(@convertEnabledToStr, list(IDX_Enabled,:), ...
        'uniformoutput', false);

    % add column headers to cell array
    list = [ [{'ID'}; {'Type'}; {'Value'}; {'Enabled'}], list]';
    
    % minimum spacing between columns [indent, ID, Type, Value]
    minColWidths = [1 8 10 10];
    
    % adjust minimum column widths if necessary
    % we will need to increase minimum column width if any data being printed
    % in that column has a length more than it
    % colWidths contains the actual column widths
    
    colWidths = minColWidths;
    for i = 2: length(minColWidths) % first row contains headers
        colWidths(i) = max( minColWidths(i), max(cellfun(@length, list(:,i-1))) ) + 2;
    end
    
    % print out all breakpoints in tabular form
    for i = 1: size(list, 1)
        currBP = list(i, :);

        % create appropriate number of spaces
        % num_spaces = column_width - length_of_column_data
        s = @(x) repmat(' ', 1, colWidths(x)-length(currBP{x-1}));
        sp = { ' ' s(2) s(3) s(4) };
        
        % intersperse spaces and text for each row into one cell in
        % the correct order
        listRow = cell(1, (length(currBP) + length(colWidths)));
        [listRow(2:2:end)] = deal(currBP(:)); % text to be printed
        [listRow(1:2:end-1)] = deal(sp(:)); % spaces to be left
        
        % print out the row in breakpoint table
        formatStr = '%s%s%s%s%s%s%s%s\n';
        fprintf(1, formatStr, listRow{:});
        
        % repeat for next row
    end
    fprintf('\n');
    
end


function enabledStr = convertEnabledToStr(enabledLogical)
if (enabledLogical)
    enabledStr = 'yes';
else
    enabledStr = 'no';
end
