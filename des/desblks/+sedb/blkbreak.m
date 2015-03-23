function varargout = blkbreak(blk)
% SEDB.BLKBREAK  Set breakpoint for a discrete-event block.
%
%    BLKBREAK('BLKID') or BLKBREAK BLKID sets a breakpoint for the 
%    discrete-event block with identifier BLKID in the simulation.
%    Use BLKLIST to get a list of blocks at which such breakpoints 
%    may be set.
%
%    BLKBREAK('BLOCKNAME') sets a breakpoint for the discrete-event
%    block whose path name is BLOCKNAME.
%
%    BID = BLKBREAK(...) returns the identifier of the breakpoint.
%
%    See also SEDB.CONT, SEDB.BLKLIST, SEDB.BREAKPOINTS, SEDB.DISABLE, SEDB.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 

% ensure that debugger is on
des_validateDebugMode;

errID = 'DEBUG_IncorrectArgs';
errMsg = 'Input must be a valid block identifier string.';
errMsgHelper = 'Try using ''blklist'' to inspect blocks and their identifiers.';

% arg checking
if ~exist('blk', 'var')
    des_error(errID, [errMsg, char(10), errMsgHelper]);
end
if ~ischar(blk)
    des_error(errID, [errMsg, char(10), errMsgHelper]);
end

% throw an error if input is solver subsystem block
dbg_throwIfSolverSubsystemBlock( blk );

% call builtin to get the block list
all_blks = des_dbg_cmd_blocklist();
if isempty(all_blks)
    des_error(errID, [errMsg, char(10), errMsgHelper]);
end

[BLKID, BLKNAME] = deal(1,2); % indices    

% the input could either be a block ID or a block name
% so we check both rows of blks
% first row is block ids and second row is corresp names

block_id_set = all_blks( BLKID, : );
id_match = strmatch( blk, block_id_set, 'exact' );

blk_id_to_set = '';
if ~isempty( id_match )
    
    % then it is a block id
    blk_id_to_set = all_blks{ BLKID, id_match(1) };
    
else
    % it could be a block name
    block_name_set = all_blks( BLKNAME, : );
    
    % remove the newlines for comparison
    block_name_set = strrep( block_name_set, char(10), ' ' );
    blk = strrep( blk, char(10), ' ' );
    
    % compare
    name_match = strmatch( blk, block_name_set, 'exact' );
    if ~isempty( name_match )
        % it is a block name
        blk_id_to_set = all_blks{ BLKID, name_match(1) };
    end
    
end

% if we still haven't found anything then throw error
if isempty( blk_id_to_set )
    des_error(errID, ...
        ['Input ''', blk,''' is not the identifier or name of a SimEvents block that can report information.', ...
        char(10), errMsgHelper]);
end

% actually set the breakpoint
bpid = des_dbg_cmd_setBlockBreak( blk_id_to_set );
if ( isnumeric(bpid) )
    des_error(errID, 'Error occurred when trying to set block breakpoint.');
end

% return an output if one was asked
if nargout > 0
    varargout{1} = bpid;
end

% EOF
