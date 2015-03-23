function varargout = blkinfo(id)
% SEDB.BLKINFO  Block information in discrete-event simulation.
%
%    BLKINFO('BLKID') displays information regarding the state of the
%    block with identifier BLKID. Use BLKLIST to obtain a list of blocks
%    in the model along with their identifiers.
%
%    BLKINFO('BLKNAME') displays information regarding entity contents of
%    the block with path name BLKNAME.
%
%    X = BLKINFO(...) returns a structure containing information regarding
%    entity contents of the block.
%
%    X has these fields:
%      'Time'      Current simulation time
%      'Block'     Path name of the block
%      'ID'        Identifier of the block
%      'Entities'  Structure that lists entities in the block
%
%    Examples: blkinfo(gceb)
%
%    See also SEDB.BLKLIST, SEDB.GCEB, SEDB.ENINFO, SEDB.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date:

% TODO: This file can be refactored to use MCOS objects. -dlad

% validate debugger
des_validateDebugMode;

errID = 'DEBUG_IncorrectArgs';
errMsgHelp = 'Use ''blklist'' to see blocks in this model capable of reporting information.';

% arg checking
if ~exist('id', 'var')
    des_error(errID, ...
        ['A block identifier is required as input.', char(10), errMsgHelp]);
end
if ~ischar(id)
    des_error(errID, ...
        ['Input block identifier must be a string.', char(10), errMsgHelp]);
end

% decide whether or not to return a struct
% if user didn't ask for output variable, then we dont provide a struct
returnStruct = (nargout > 0);

% throw an error if input is solver subsystem block
dbg_throwIfSolverSubsystemBlock( id );

% call builtin to get the raw data
[blockdata, blockid, entitydata] = des_dbg_cmd_blockinfo(id);

% if a cell is not returned by builtin then it means that the block was not
% found in the debug collection. Either it doesn't exist or has no state to
% report
if ~iscell(blockdata)
    % need to throw an error
    des_error(errID, ...
        ['Input ''', id,''' is not the identifier or name of a SimEvents block that can report information.', ...
        char(10), errMsgHelp]);
end

% depending on which kind of block it is, do appropriate stuff

% check block type
BTYPE = 1;
switch blockdata{BTYPE}
    
    % ----- Storage Blocks ----------------------------------------------%
    
    case {'Single Server', 'N-Server', 'Infinite Server'}
        % server blocks
        out = storageblockstate ( ...
            blockdata, blockid, entitydata, ... % raw data
            returnStruct, ... % want struct?
            {'Pos', 'ID', 'Status', 'Event', 'EventTime'}, ... % col headers / field names of struct
            [1 8 10 25 10] ); % column spacing
        
    case {'FIFO Queue', 'LIFO Queue'}
        % queue blocks (except priority queue)
        out = storageblockstate ( ...
            blockdata, blockid, entitydata, ... % raw data
            returnStruct, ... % want struct?
            {'Pos', 'ID', 'Status', 'TimeInQueue'}, ... % col headers / field names
            [1 8 10 20] ); % column spacing
        
    case {'Priority Queue'}
        out = priorityqueuestate ( ...
            blockdata, blockid, entitydata, ... % raw data
            returnStruct, ... % want struct?
            {'Pos', 'ID', 'SortingValue', 'Status', 'TimeInQueue'}, ... % col headers / field names
            [1 8 10 15 15] ); % column spacing
        
    % ----- Pseudo-Storage Blocks (one entity only) ---------------------%
    
    case {'Buffered Output Switch', 'Time-Based Entity Generator', ...
            'Event-Based Entity Generator'}
        % blocks that can store one entity
        canStoreOneEntity = true;
        out = nonstorageblockstate ( ...
            blockdata, blockid, entitydata, ...
            returnStruct, ...
            {'Pos', 'ID'}, ...
            canStoreOneEntity);

    % ----- Multi-Entity Blocks -----------------------------------------%
        
    case {'Entity Combiner'}
        out = entitycombinerstate ( ...
            blockdata, blockid, entitydata, returnStruct );
        
    case {'Entity Splitter'}
        out = entitysplitterstate ( ...
            blockdata, blockid, entitydata, returnStruct );
        
    case {'Replicate'}
        out = replicatestate ( ...
            blockdata, blockid, entitydata, returnStruct );
        
    % ----- Blocks with Internal States ---------------------------------%
    
    case {'Signal Latch'}
        blockAcceptsEntities = false;
        state_tag = 'Memory Value';
        out = blockWithInternalState ( ...
            blockdata, blockid, entitydata, returnStruct, ...
            blockAcceptsEntities, state_tag );
        
    case {'Enabled Gate'}
        blockAcceptsEntities = true;
        state_tag = 'Gate Status';
        out = blockWithInternalState ( ...
            blockdata, blockid, entitydata, returnStruct, ...
            blockAcceptsEntities, state_tag );
        
    case {'Input Switch'}
        blockAcceptsEntities = true;
        state_tag = 'Selected Input Port';
        out = blockWithInternalState ( ...
            blockdata, blockid, entitydata, returnStruct, ...
            blockAcceptsEntities, state_tag );
        
    case {'Output Switch'}
        blockAcceptsEntities = true;
        state_tag = 'Selected Output Port';
        out = blockWithInternalState ( ...
            blockdata, blockid, entitydata, returnStruct, ...
            blockAcceptsEntities, state_tag );
        
    case {'Entity Departure Counter'}
        blockAcceptsEntities = true;
        state_tag = 'Count';
        out = blockWithInternalState ( ...
            blockdata, blockid, entitydata, returnStruct, ...
            blockAcceptsEntities, state_tag );

    % ----- Other Non-Storage Blocks ------------------------------------%
    
    otherwise
        % non-storage blocks
        canStoreOneEntity = false;
        out = nonstorageblockstate ( ...
            blockdata, blockid, entitydata, ...
            returnStruct, ...
            {'Pos', 'ID'}, ...
            canStoreOneEntity);        
end

% assign output argument if one was asked for
if returnStruct
    varargout{1} = out;
end

% ----------------------------------------------------------------------- %

function out = storageblockstate(...
    blockdata, blockid, entitydata, returnStruct, col_headers, col_widths)
% STORAGEBLOCKSTATE Report state of all storage blocks except Priority
% Queue.

% constants
BCAPACITY = 3;

% if capacity is being reported as intmax, then it is Inf
if str2double(blockdata{BCAPACITY}) == intmax
    blockdata{BCAPACITY} = 'Inf';
end

if returnStruct % user asked for struct

    out = h_createBasicStruct(blockdata, blockid); % with id and name etc.
    out.Capacity = str2double(blockdata{BCAPACITY}); % add storage block info
    
    % entities struct
    s = h_createEntityStruct(entitydata, col_headers);
    out.Entities = s;
    
else
    
    % we print a neat table
    out = ''; % no output
    
    % print header info
    h_printheader(blockdata, blockid);
    
    % print entities
    fprintf('\nEntities (Capacity = %s): ', blockdata{BCAPACITY});
    if isempty(entitydata)
        fprintf('None\n\n');
        return;
    end
    fprintf('\n');
    h_printEntityTable(entitydata, col_headers', col_widths);
    fprintf('\n');

end

% ----------------------------------------------------------------------- %

function out = priorityqueuestate(...
    blockdata, blockid, entitydata, ...
    returnStruct, col_headers, col_widths)
% PRIORITYQUEUESTATE Report state of priority queue block

[BCAPACITY, SORTATTR, SORTDIR] = deal(3,4,5);

% if capacity is being reported as intmax, then it is Inf
if str2double(blockdata{BCAPACITY}) == intmax
    blockdata{BCAPACITY} = 'Inf';
end

if returnStruct

    out = h_createBasicStruct(blockdata, blockid);
    out.Capacity = str2double(blockdata{BCAPACITY});
    out.SortingAttributeName = blockdata{SORTATTR};
    out.SortingDirection = blockdata{SORTDIR};
    
    % entities struct
    s = h_createEntityStruct(entitydata, col_headers);
    out.Entities = s;
    
else
    
    out = '';
    
    % print header
    h_printheader(blockdata, blockid);
    
    % print customized information
    fprintf('\n');
    fprintf('Sorting Attribute Name  =  %s\n', blockdata{SORTATTR});
    fprintf('Sorting Direction       =  %s\n', blockdata{SORTDIR});
    
    % print entities
    fprintf('\nEntities (Capacity = %s): ', blockdata{BCAPACITY});
    if isempty(entitydata)
        fprintf('None\n\n');
        return;
    else
        fprintf('\n');
    end
    h_printEntityTable(entitydata, col_headers', col_widths);
    fprintf('\n');

end

% ----------------------------------------------------------------------- %

function out = nonstorageblockstate ( ...
    blockdata, blockid, entitydata, returnStruct, field_names, canStoreOneEntity)
% NONSTORAGESTATE Report states of non-storage blocks in the debugger.

ENID = 1;

if returnStruct
    
    out = h_createBasicStruct(blockdata, blockid);    
    s = h_createEntityStruct(entitydata, field_names);
    out.Entities = s;
    
else
    
    out = '';
    h_printheader(blockdata, blockid);
    if canStoreOneEntity
        fprintf('\nEntity = ');
    else
        fprintf('\nAdvancing Entity = ');
    end
    if isempty(entitydata)
        fprintf('<none>\n\n');
    else
        fprintf('%s\n\n', entitydata{ENID});
    end
    
end


% ----------------------------------------------------------------------- %

function out = entitycombinerstate ( ...
    blockdata, blockid, entitydata, returnStruct )
% ENTITYCOMBINERSTATE Report state of entity combiner block in the
% debugger.

NUMINPUTS = 3;

% get the ids of component and composite entities
% in entitydata, elements 1 to NUMINPUTS are the component entity ids while
% the last element is the composite entity id

numInputPorts = str2double( blockdata{NUMINPUTS} );
componentEntities = entitydata(1:numInputPorts); % cell
compositeEntity = entitydata{end}; % string

% determine block status
numEntitiesReceived = sum(~cellfun(@isempty, componentEntities));
if numEntitiesReceived == 0
    status = 'Inactive'; % block isn't doing anything right now
else
    status = 'Combining'; % we are in a combining operation
end

if returnStruct
    
    % create struct with name and id info
    out = h_createBasicStruct(blockdata, blockid);

    % assign customized outputs
    out.Status = status;
    out.Entities.ComponentEntities = componentEntities;
    out.Entities.CompositeEntity = compositeEntity;
    
else
   
    out = '';
    h_printheader(blockdata, blockid);
    
    % component ids
    fprintf('\nComponent Entities =  ');
    
    % need some analysis here. the combiner needs to receive NUMINPUTS
    % entities in order to produce an output. hence we will always show
    % NUMINPUTS placeholders of the form [-]. If an entity has been
    % received from the ith input port, then that placeholder will be
    % replaced with the id of that received entity.
    %
    % example output is:
    %
    % Component Entities =  en1, [-], [-]
    % Composite Entity   =  [-]
    % Status             =  Combining
    
    % find which elements of componentEntities are empty
    emptyIds = cellfun(@isempty, componentEntities);
    
    % create a new cell formattedComponentIds and assign emptyIds to [-]
    formattedComponentIds(emptyIds) = deal(repmat({'[-]'}, 1, sum(emptyIds)));
    
    % assign ~emptyIds to be the entity ids received
    formattedComponentIds(~emptyIds) = componentEntities(~emptyIds);
    
    % print each id or [-] out
    cellfun(@(x) fprintf([x, ', ']), formattedComponentIds);
    
    % print composite id
    fprintf('\nComposite Entity   =  ');
    if isempty(compositeEntity)
        fprintf('[-]');
    else
        fprintf(compositeEntity);
    end
    
    % status
    fprintf('\nStatus             =  %s\n\n', status);
    
end

% ----------------------------------------------------------------------- %

function out = entitysplitterstate ( ...
    blockdata, blockid, entitydata, returnStruct )
% ENTITYSPLITTERSTATE Report state of entity splitter block in the
% debugger.

% analyze entity info
compositeEntity = entitydata{1}; % string
componentEntities = entitydata(2:end); % cell

% determine block status
if isempty(compositeEntity)
    status = 'Inactive';
else
    status = 'Splitting';
end

if returnStruct
    
    out = h_createBasicStruct(blockdata, blockid);
        
    % assign outputs
    out.Status = status;
    out.Entities.CompositeEntity = compositeEntity;
    out.Entities.ComponentEntities = componentEntities;
    
else
   
    out = '';
    % header
    h_printheader(blockdata, blockid);
    
    % composite id
    fprintf('\nComposite Entity   =  ');
    if isempty(compositeEntity)
        fprintf('[-]');
    else
        fprintf(compositeEntity);
    end
    
    % component ids
    fprintf('\nComponent Entities =  ');
    
    % refer function entitycombinerstate to see what this block of code is
    % doing in that function
    emptyIds = cellfun(@isempty, componentEntities);
    formattedComponentIds(emptyIds) = deal(repmat({'[-]'}, 1, sum(emptyIds)));
    formattedComponentIds(~emptyIds) = componentEntities(~emptyIds);
    cellfun(@(x) fprintf([x, ', ']), formattedComponentIds);
 
    % status
    fprintf('\nStatus             =  %s\n\n', status);
    
end

% ----------------------------------------------------------------------- %

function out = replicatestate ( ...
    blockdata, blockid, entitydata, returnStruct )
% REPLICATESTATE Report state of replicate (all + any) block in the debugger.

[INPUTENTITY, REPLICA, NUMOUTPORTS, CURRPORT] = deal(1,2,3,4);

% figure out status of replicate block
numOutputPorts = blockdata{NUMOUTPORTS};
currentReplicatingPort = blockdata{CURRPORT};
inputEntity = entitydata{INPUTENTITY};
currentReplica = entitydata{REPLICA};

if isempty(inputEntity) || (str2double(currentReplicatingPort) == 0)
    status = 'Inactive';
else
    status = ['Replicating ', currentReplicatingPort, '/', numOutputPorts];
end


if returnStruct
    out = h_createBasicStruct(blockdata, blockid);
    out.InputEntity = inputEntity;
    out.CurrentReplica = currentReplica;
    out.Status = status;
else
    out = '';
    h_printheader(blockdata, blockid);
    fprintf('\nInput Entity    = ');
    if isempty(inputEntity)
        fprintf('[-]');
    else
        fprintf(inputEntity);
    end
    fprintf('\nCurrent Replica = ');
    if isempty(currentReplica)
        fprintf('[-]');
    else
        fprintf(currentReplica);
    end
    fprintf('\nStatus          = %s\n\n', status);
end

% ----------------------------------------------------------------------- %

% Blocks with Internal States
function out = blockWithInternalState ( ...
    blockdata, blockid, entitydata, returnStruct, blockAcceptsEntities, state_tag )
% BLOCKWITHINTERNALSTATE Report state of blocks with internal states in the
% debugger.
%
% The blocks that have internal states are:
%
%    Input Switch                Selected input port
%    Output Switch               Selected output port
%    Signal Latch                Memory value
%    Enabled Gate                Whether or not the gate is open
%    Entity Departure Counter    Count value
%
% blockAcceptsEntities is a flag that indicates whether the block is
% capable of working with entities. not all blocks with internal states can
% accept entities, e.g. signal latch.
%
% state_tag is the name that will appear for the state parameter in the
% display. example: for input switch, state_tag = 'Selected Input Port'

[ENID, STATEIDX] = deal(1,3); % state info is always the third element in blockdata

if returnStruct
    out = h_createBasicStruct(blockdata, blockid);
    
    % remove spaces from state_tag to make it a valid field name
    stateFieldName = strrep(state_tag, ' ', '');
    
    if isnan(str2double(blockdata{STATEIDX})) % state value is true string
        out.(stateFieldName) = blockdata{STATEIDX};
    else
        out.(stateFieldName) = str2double(blockdata{STATEIDX}); % state value is numeric
    end
    % not all blocks with states accept entities (e.g. signal latch)
    if blockAcceptsEntities
        out.Entities = h_createEntityStruct(entitydata, {'Pos', 'ID'});
    end
else
    out = '';
    h_printheader(blockdata, blockid);
    
    % need to append spaces so that params and values are is aligned
    % one of the params is Advancing Entity, the other one is state_tag.
    % we need to align both of them for a neat display.
    
    params = {'Advancing Entity', state_tag}; % convert to cell
    params = char(params{:}); % append correct number of spaces at the end of each string
    entityParamName = params(1,:); % separate out both params
    stateParamName = params(2,:);
    
    % now print out aligned
    if blockAcceptsEntities
        fprintf('\n%s =  ', entityParamName);
        if isempty(entitydata)
            fprintf('<none>');
        else
            fprintf('%s', entitydata{ENID});
        end
    end
    fprintf('\n%s =  %s\n\n', stateParamName, blockdata{STATEIDX});
end

% ----------------------------------------------------------------------- %
% ---------------- Helper Functions Start ------------------------------- %


function out = h_createBasicStruct(blockdata, blockid)
% H_CREATEBASICSTRUCT Create the basic structure to return as output of
% BLKINFO.
%
% The basic structure contains the time, block id, block name and block
% type. This function is called by all block state reporting functions. The
% basic structure returned by this function is then populated by each
% function differently.

% constants
[BID, BNAME, BTIME] = deal(1,2,2);

out.Time = str2double(blockdata{BTIME});
out.Block = blockid{BNAME};
out.BlockID = blockid{BID};
out.BlockType = get_param(blockid{BNAME}, 'MaskType'); % always mask type

% ----------------------------------------------------------------------- %

function out = h_createEntityStruct(entitydata, fnames)
% H_CREATEENTITYSTRUCT Create entity structure in the output of BLKINFO
%
% All blocks that can store entities call this function when reporting
% their states. This function creates the structure which the callers will
% stuff in output.Entities

fnames = fnames(2:end); % first field name is Pos which we dont want

% we wish to preallocate for the struct 'out' using the function STRUCT
% which accepts input args of the form:
% struct('field1', value1, 'field2', value2, ...)
% so we create a cell containing {'field1', value1, 'field2', value2...}
% called 'inputs'.

inputs = cell(1, 2*length(fnames)); % for each fieldname we have a value cell, hence twice
inputs(1:2:end) = deal(fnames(:)); % deal out fieldnames in alternating cells

% now we need to deal out the other alternating cells for entity data

numEntities = size(entitydata,2);
emptyMatrices = repmat({[]}, 1, numEntities);
inputs(2:2:end) = deal(repmat( {emptyMatrices}, 1, length(inputs(2:2:end))));

% preallocate struct
out = struct(inputs{:});

% fill in the preallocated struct with entity values
for i = 1: size(entitydata,2)
    for j = 1: length(fnames)
        % convert the numeric value to numeric data type
        valueToFill = entitydata{j, i};
        if ~isnan( str2double(valueToFill) )
            valueToFill = str2double(valueToFill);
        end
        out(i).(fnames{j}) = valueToFill;
    end
end

% Why are we doing this in such a seemingly convoluted way?
% Because this function does not know:
% - the number of entities in the block (so we have to determine how much
% to preallocate.
% - and the number and names of fields in each entity struct
% Finally, it is a requirement that if there are no entities then the size
% of the resultant struct must be 0. This method achieves all these
% things in a generic way.

% ----------------------------------------------------------------------- %

function h_printheader(blockdata, blockid)
% H_PRINTHEADER Print block state header information
%
% general format of header is as follows
%
% Single Server Current State                       T = 5.27646754677864
% Block (blk10): Subsystem/Machine1
%
% of which
% str1 = 'Single Server Current State'
% str2 = 'T = 5.27646754677864'
% str3 = 'Block (blk10): Subsystem/Machine1'

[BTIME, BID, BNAME, MAXLEN] = deal(2,1,2, 55);

% mask type
maskType = get_param(blockid{BNAME}, 'MaskType');

% first line of header
str1 = sprintf('\n%s Current State', maskType);
str2 = sprintf('T = %.15f', str2double( blockdata{BTIME} ));

% right indent the time value
% create appropriate number of spaces
spaces = repmat( ' ', 1, MAXLEN - length(str1) );
str = [  str1  spaces  str2  ];

% second line of header
fprintf('%s\n', str);
fprintf('Block (%s): %s\n', ...
    blockid{BID}, ...
    des_createBlockHyperlink(blockid{BNAME})); % hyperlink the block name


% ----------------------------------------------------------------------- %

function h_printEntityTable(entitydata, col_headers, col_widths)
% H_PRINTENTITYTABLE Print entity table as part of output of BLKINFO
%
% For each entity in the table we print a position value which is simply
% linspace(1, NumEntities, NumEntities)

numEntitiesInBlk = size(entitydata, 2);

pos = arrayfun ( @(x) {num2str(x)}, ...
    linspace(1, numEntitiesInBlk, numEntitiesInBlk));
entitydata = [pos;  entitydata];

% add column headers to cell array
list = [ col_headers, entitydata ]';

% print out all table data including col headers
for i = 1: size(list, 1)
    
    currRow = list(i, :); % current row to be printed
    
    % create appropriate number of spaces
    % num_spaces = column_width - length_of_column_data
    % for each element of this row we have to compute the number of spaces
    % to leave after printing it so that all columns will be aligned well
    
    spacesFcn = @(x) repmat(' ', 1, col_widths(x)-length(currRow{x-1}));
    sp = [ {' '}, arrayfun(spacesFcn, 2:length(col_widths), 'uniformoutput', false) ];
    
    % intersperse spaces and text for each row into one cell in
    % the correct order
    listRow = cell(1, (length(currRow) + length(col_widths)));
    [listRow(2:2:end)] = deal(currRow(:)); % text to be printed
    [listRow(1:2:end-1)] = deal(sp(:)); % spaces to be left
    
    % print out single row in table
    formatStr = [repmat('%s', 1, length(listRow)), '\n'];
    fprintf(1, formatStr, listRow{:});
    
    % repeat for next row
end

% ----------------------------------------------------------------------- %

% [eof] blkinfo.m
