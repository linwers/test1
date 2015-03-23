function varargout = blklist
% SEDB.BLKLIST  List blocks and their identifiers.
%
%    BLKLIST displays a list of blocks and block identifiers in the 
%    model being debugged.
%
%    X = BLKLIST returns the same information in a cell array of
%    strings. The first column of X contains block identifiers and the
%    corresponding cells in the second column contain block names.
%
%    See also SEDB.BLKINFO, SEDB.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 

% validate debugger state
des_validateDebugMode;

% call builtin
blks = des_dbg_cmd_blocklist();

% sort ascending
[blks_sort, idx_sort] = sort( blks(2, :) );
blks = [ blks(1, idx_sort); blks_sort ];

if nargout > 0
    
    % return cell array
    varargout{1} = transpose(blks);
    
    % why not have the builtin send out the transpose, instead of
    % transposing it here, you may ask?
    % - because in cpp code it is easier to create a 2xN cell array since
    % mxArrays have column-major ordering.
    
else
    
    if isempty(blks)
        fprintf('\n   This model contains no blocks that can report debugging information.\n\n');
        return;
    end
    
    % display tabular form
    [BLKID, BLKNAME] = deal(1,2); % indices
    
    % create hyperlinks for all blocks
    hlinks = cellfun(@des_createBlockHyperlink, blks(BLKNAME,:), 'uniformoutput', false);
    
    % print out header and model name
    fprintf('\nList of blocks in model: %s\n\n', bdroot(blks{BLKNAME,1}));
    
    % anonymous function to print a single row in table
    printfcn = @(id, name) ...
        fprintf('   %s%s%s\n', id, h_createSpaces(id), name);
    
    % print out all blocks
    cellfun(printfcn, blks(BLKID,:), hlinks);
    fprintf('\n');
    
end

function spaces = h_createSpaces(s)
col_width = 20;
spaces = repmat(' ', 1, col_width - length(s));
