function seedStruct = se_getseeds(sysid)
%SE_GETSEEDS  Get seed values of random number generators in SimEvents blocks
%
%   SEEDSTRUCT = SE_GETSEEDS(SYSID) accepts system, SYSID, and  returns a 
%   structure, SEEDSTRUCT, containing the names and seed values of all blocks in  
%   SYSID that use random number generators during simulation.
%   SYSID can be a model name, a subsystem pathname, or a block pathname. 
%   
%   The SEEDSTRUCT  returned has the following fields:
%   
%   'system'    system identifier, SYSID, for block, subsystem, or model that was 
%               used to create the structure
%               
%   'seeds'     structure array containing names and seed values of blocks 
%               that have random number generators
%   
%   Each element of the 'seeds' structure array contains the following
%   fields:
%   
%   'block'     name of the block.  This name excludes the path specified in SYSID.
%   
%   'value'     seed value of the block (numeric)
%   
%   See also SE_SETSEEDS, SE_RANDOMIZESEEDS.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/12/10 21:24:39 $

DES_MSG_TYPE_HELP = 'Type ''help se_getseeds'' for more information.';

if nargin < 1
    error('SimEvents:RNGSeeds_SysIdMissing', ...
        ['First argument must be a single block/subsystem/model name. ', ...
        DES_MSG_TYPE_HELP]);
end

try
    sysid = des_validateSimulinkSystem(sysid, 'se_GetSeeds');
catch ME
    throwAsCaller(ME);
end

blks = des_getActiveSeedBlocks(sysid);
if isempty(blks)
    seedStruct = struct([]);
else
    seedStruct = helper_get_seeds_for_system();
end

    % ===================================================================%

    function seeds = helper_get_seeds_for_system()
        if length(blks) == 1 && strcmp(blks(1).Name, sysid)
            % then sysid is a single block
            seeds.system = get_param(sysid, 'Parent');
        else
            % sysid is a subsystem or a model
            seeds.system = sysid;
        end
        f = @(x) struct(...
            'block', helper_remove_sysid_from_block_name(regexprep(x.Name, '\n', ' ')), ...
            'value', str2double(x.Value));
        tempParentStruct = arrayfun(f, blks);
        seeds.seeds = tempParentStruct;
    end

    % ===================================================================%

    function newBlkName = helper_remove_sysid_from_block_name(blkName)
        if strcmp(sysid, blkName)
            newSysid = get_param(blkName, 'Parent');
            newBlkName = strrep(blkName, [newSysid, '/'], '');
        else
            newBlkName = strrep(blkName, [sysid, '/'], '');
        end
    end

end
