function [oldSeedStruct, success] = se_setseeds(seedStruct, sysid)
%SE_SETSEEDS Set seed values for SimEvents blocks with random number generators  
%   
%   SE_SETSEEDS(SEEDSTRUCT) uses SEEDSTRUCT to set the seed parameter values for
%   all blocks specified in the seed structure SEEDSTRUCT.  The input structure 
%   is similar in form to that returned by SE_GETSEEDS. SEEDSTRUCT is described in
%   SE_GETSEEDS.
%   
%   SE_SETSEEDS(SEEDSTRUCT, SYSID) applies the seed values instead to the system
%   specified in SYSID, overriding the system specified in the 'system'
%   field of SEEDSTRUCT. This enables the porting of seeds across models that have
%   similar structure. This command issues warnings for each block in SEEDSTRUCT
%   that is not present in the system SYSID.
%   
%   OLDSEEDSTRUCT = SE_SETSEEDS(SEEDSTRUCT, ...) returns a structure containing the
%   original seed values of the model prior to changing them to those specified in
%   the SEEDSTRUCT. Using OLDSEEDSTRUCT as an input to SE_SETSEEDS restores
%   the original seed values.
%   
%   [OLDSEEDSTRUCT, STATUS] = SE_SETSEEDS(SEEDSTRUCT, ...) additionally returns a
%   logical array containing the success/failure STATUS for each block specified in
%   SEEDSTRUCT. If the ith block was not found or did not have a seed parameter then
%   STATUS(i) = false, else  STATUS(i) will be true. 
%
%   See also SE_GETSEEDS, SE_RANDOMIZESEEDS.
   
% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 

% common msg for some errors and warnings
DES_MSG_TYPE_HELP = 'Type ''help se_setseeds'' for more information.';

% check correctness of seedStruct -------------------------------
if exist('seedStruct', 'var')
    try
        seedStruct = helper_check_seedStruct(seedStruct);
    catch ME
        throwAsCaller(ME);
    end
else
    error('SimEvents:RNGSeeds_SetSeedsInvalidSeedStructure', ...
        ['The first argument must be a seed structure. ', DES_MSG_TYPE_HELP]);
end

% check sysid ---------------------------------------------------
if exist('sysid', 'var')
    try
        sysid = des_validateSimulinkSystem(sysid, 'se_SetSeeds');
    catch ME
        throwAsCaller(ME);
    end
else
    sysid = seedStruct.system;
end

% initialize return arg (success tracker)
success = false(length(seedStruct.seeds), 1);

% first grab all old seeds for backup
blks = des_getActiveSeedBlocks(sysid);

if isempty(blks)
    warning('SimEvents:RNGSeeds_SetSeedsNoSeededBlocks', ...
        ['The specified system ' sysid, '\n', 'does not appear to contain ', ...
        'blocks that are using seed values in their current configuration.']);
    oldSeedStruct = struct([]);
else
    
    % we need to keep track of which of the elements of blks are being set
    % so that we can return their old values. The success return argument
    % tells the user which of the input seeds were set and which weren't.
    
    % However, another index tracking variable is needed to keep track of
    % those elements from blks whose seeds were successfully changed, so
    % that they can be returned to the user as oldSeedStruct for backup.
    % blkReturnTracker will be that tracking variable
    
    blkReturnTracker = false(length(blks), 1);
    
    seedStruct = seedStruct.seeds;
    if length(seedStruct) < 1
        warning('SimEvents:RNGSeeds_SetSeedsNoSeedsToSet', ...
            'The specified seed structure does not contain any seeds to set.');
    else

        % counters
        r_idx = 1;    % for blkReturnTracker
        s_idx = 1;    % for success tracker
        
        % loop through the seed structure and setseeds
        arrayfun(@setOneSeed, seedStruct);
        
    end
    
    % filter out those elements from blks whose seeds were changed above
    % and return as oldSeedStruct
    
    blocksToReturn = regexprep({blks(blkReturnTracker).Name}, '\n', ' ');
    blocksToReturn = cellfun(@helper_remove_sysid_from_block_name, blocksToReturn, 'UniformOutput', false);    
    tempStruct = struct( ...
        'block', blocksToReturn, ...
        'value', num2cell(str2double({blks(blkReturnTracker).Value})));
    oldSeedStruct.system = sysid;
    oldSeedStruct.seeds = tempStruct;
    
end

    % ===================================================================%
    
    function setOneSeed(currentBlock)
        
        fullBlockName = [sysid, '/', currentBlock.block];

        % first check if this block exists
        sysNotFound = false;
        try
            h = find_system(fullBlockName, 'LookUnderMasks', 'all');
            % this will throw error if first arg doesn't exist
            % alternatively h will be empty if the first arg is an empty
            % subsystem
        catch
            sysNotFound = true;
        end
        if sysNotFound || isempty(h)
            % block does not exist, may have been removed by user
            warning('SimEvents:RNGSeeds_SetSeedsBlockNotFound', ...
                ['Block ', fullBlockName, ' not found. Ignoring this element in the seed structure.']);
            success(s_idx) = false;
            s_idx = s_idx + 1;
            % no updates to blkReturnTracker and r_idx
            % since block does not exist
            return;
        end

        % if we reached here, then this block exists
        % now to check if it is in a configuration that accepts seeds
        thisBlockSeedInfo = des_getActiveSeedBlocks(fullBlockName);
        if isempty(thisBlockSeedInfo)
            % then the configuration of this block has changed, and it no
            % longer accepts any seeds.
            % => this block is not being tracked by blkReturnTracker
            %    but it is being tracked by success
            success(s_idx) = false;
            s_idx = s_idx + 1;

            % need to warn about this block and then return
            warning('SimEvents:RNGSeeds_SetSeedsBlockDoesNotHaveSeed', ...
                ['Block ', currentBlock.block, ' is not a SimEvents ', ...
                'system/block that includes a seed parameter in its ', ...
                'current configuration.']);
            return;
        end
        
        % if we reached here, then this block exists and is able to accept
        % a seed; now try to set the seed
        set_param(fullBlockName, thisBlockSeedInfo.Parameter, num2str(currentBlock.value));
        success(s_idx) = true;
        blkReturnTracker(r_idx) = true;
        s_idx = s_idx + 1;
        r_idx = r_idx + 1;

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

% =======================================================================%

function [seedStruct] = helper_check_seedStruct(seedStruct)
DES_MSG_TYPE_HELP = 'Type ''help se_setseeds'' for more information.';

if ~isstruct(seedStruct)
    error('SimEvents:RNGSeeds_SetSeedsInvalidSeedStructure', ...
        ['First input argument to se_setseeds must be a seed structure. ', DES_MSG_TYPE_HELP]);
else
    fnames = fieldnames(seedStruct);
    if length(intersect(fnames, {'system', 'seeds'})) ~= 2
        error('SimEvents:RNGSeeds_SetSeedsInvalidSeedStructureFields', ...
            ['Incorrect fields present in input seed structure. ', DES_MSG_TYPE_HELP]);
    else
        fnames = fieldnames(seedStruct.seeds);
        if length(intersect(fnames, {'block', 'value'})) ~= 2
            error('SimEvents:RNGSeeds_SetSeedsInvalidSeedStructureFields', ...
                ['Incorrect fields present in input seed structure. ', DES_MSG_TYPE_HELP]);
        else
            try
                temp = cell2mat({seedStruct.seeds.value}');
            catch
                error('SimEvents:RNGSeeds_SetSeedsInvalidSeedValues', ...
                    ['Seed values in the input structure must all be numeric. ', DES_MSG_TYPE_HELP]);
            end
            if ~isnumeric(temp) || any(isnan(temp)) || any(isinf(temp)) || ...
                    ~isreal(temp) || isempty(temp) || any(temp<0)
                error('SimEvents:RNGSeeds_SetSeedsInvalidSeedValues', ...
                    ['Seed values in the input structure must all be real numeric (0 <= seed < Inf). ', DES_MSG_TYPE_HELP]);
            end
        end
    end

end

end
