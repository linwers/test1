function se_randomizeseeds(sysid, varargin)
%SE_RANDOMIZESEEDS  Randomize seeds of SimEvents blocks to make them unique
%
%   SE_RANDOMIZESEEDS(OBJ) makes the seeds of all blocks that use random number
%   generators within OBJ making sure they are unique. OBJ can be a single model,
%   subsystem or a block, or alternatively a cell array of these names.
%   
%   SE_RANDOMIZESEEDS(OBJ, PARAMETER1, VALUE1, PARAMETER2, VALUE2, ...) allows
%   options in randomizing the seeds. 
%
%   PARAMETER         VALUES                  DESCRIPTION
%   
%   'Mode'        {'All' |             Randomize all seeds within OBJ or just  
%                 'Identical' |        the seeds that are identical, or just the
%                 'SpecifySeeds',sv}   seeds specified in the seed vector sv.
%                                      All' is default.
%                                      e. g. se_randomizeseeds(gcs, 'Mode', 'Identical') 
%                                      e. g. se_randomizeseeds(gcs, 'Mode', 'SpecifySeeds', [122, 453])
%                                       
%   'GlobalSeed'  {seed}               Global seed to use to generate seeds.  
%                                      If not specified, the system clock is used
%                                      to create the global seed. This is the default behavior.
%                                      e. g. se_randomizeseeds(gcs, 'GlobalSeed', 234)
%   
%   'Verbose'     {'on'|'off'}         Explicitly reports status of each seed 
%                                      change, if set to 'on'. 'off' is default. 
%
%   See also SE_GETSEEDS, SE_SETSEEDS.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 

des_msg_type_help = 'Type ''help se_randomizeseeds'' for more information.';

if nargin < 1
    des_error('RNGSeeds_IncorrectNumArgs', ...
        ['Missing block(s) or system(s) as first input argument. ', ...
        des_msg_type_help]);
end

% check sysid
try 
    sysid = des_validateSimulinkSystem(sysid, ...
        'se_RandomizeSeeds', 'AllowMultiple');
catch ME
    throwAsCaller(ME);
end

% parse varargin
try
    [randomizationMode, globalSeed, globalSeedIsUserSpecified, seedsToChange, verbose] = ...
        helper_parse_inputs(varargin);
catch ME
    throwAsCaller(ME);
end

% find all current seed values and keep for use when determining the
% uniqueness of newly generated seeds
mdl = bdroot(sysid);
allSeededBlksInModel = des_getSeededBlocks(mdl);
currentSeeds = str2double({allSeededBlksInModel.Value}');

% loop through sysid
cellfun(@randomizeEachSysId, sysid);

    % ===================================================================%

    function randomizeEachSysId(sys)
        blks = des_getActiveSeedBlocks(sys);
        if isempty(blks)
            % this is a system or block with no seed
            fullName = regexprep(sys, '[\n\r]', ' ');
            warning('SimEvents:RNGSeeds_SystemWithNoSeed', ...
                [fullName, ' is not a SimEvents system/block that includes ',... 
                'a seed parameter in its present configuration.']);
        else
            % safe to assume that this is a subsystem
            helper_randomize_seeds_for_system(sys, blks);
        end
    end

    % ===================================================================%

    function newSeed = helper_generate_seed(globalSeedIsUserSpecified)

        % This function will generate a new seed.
        % It will guarantee uniqueness throughout the whole model, if the
        % globalSeedIsUserSpecified = false
        
        MAX_TRIES = 5000;
        count = 0;
        newSeed = ''; % define in this scope
        
        % pseudo do-while loop since the first try will 
        % succeed most of the time
        if ~generate_trial_seed()
            while ~generate_trial_seed()
            end
        end
        
        % ===============================================================%
        
        function success = generate_trial_seed()
            success = false;
            trialSeed = mod( fix( 2^10 * globalSeed * pi ), 2^32 );
            newSeed = num2str(trialSeed);
            globalSeed = globalSeed + 1;
            if globalSeedIsUserSpecified
                success = true;
            else
                if ~ismember(trialSeed, currentSeeds) % uniqueness check
                    success = true;
                end
            end
            count = count + 1;
            if count > MAX_TRIES
                warning('SimEvents:RNGSeeds_CannotGenerateSeed',...
                    ['Could not generate a unique seed even after ', ...
                    num2str(MAX_TRIES), ' tries. Returning seed 0.']);
                newSeed = '0';
                success = true;
            end
        end
    end

    % ===================================================================%

    function helper_randomize_seeds_for_system(sys, blks)
        
        % gather blocks to change depending on randomizationMode
        if strncmpi(randomizationMode, 'AllSeeds', length(randomizationMode))
            changeBlks = blks;
        elseif strncmpi(randomizationMode, 'IdenticalSeedsOnly', ...
                length(randomizationMode))
            changeBlks = des_getIdenticalSeedBlocks(blks);
            changeBlks = [changeBlks{:}];
            if isempty(changeBlks)
                warning('SimEvents:RNGSeeds_NoIdenticalSeeds', ...
                    ['The specified system ', sys, ...
                    '\ndoes not contain blocks that are using identical '...
                    'seed values in their current configurations.']);
                return;
            end
        else % mode is SpecifySeeds
            idx = ismember(str2double({blks.Value}'), seedsToChange);
            changeBlks = blks(idx);
            if isempty(changeBlks)
                warning('SimEvents:RNGSeeds_NoSpecifiedSeeds', ...
                    ['The specified system ', sys, ...
                    '\ndoes not contain blocks that have seed values ', ...
                    mat2str(seedsToChange), '.']);
                return;
            end
        end
        
        % now change these seeds
        arrayfun(@randomizeEachBlock, changeBlks);
        
        % =============================================================== %
        
        function randomizeEachBlock(oneBlk)
            newSeed = helper_generate_seed(globalSeedIsUserSpecified);
            set_param(oneBlk.Name, oneBlk.Parameter, newSeed);
            if verbose
                disp(['Generated unique seed ', newSeed, ...
                    ' for block ', regexprep(oneBlk.Name, '\n', ' ')]);
            end
        end
        
    end

end

% =======================================================================%

function [randomizationMode, globalSeed, globalSeedIsUserSpecified, seedsToChange, verbose] = ...
    helper_parse_inputs(inputArgs)
des_msg_type_help = 'Type ''help se_randomizeseeds'' for more information.';

% default values
randomizationMode = 'AllSeeds';
globalSeed = floor(sum(clock));
globalSeedIsUserSpecified = false;
seedsToChange = NaN;
verbose = false;

if isempty(inputArgs)
    return;
else
    inputArgs = cellfun(@lower, inputArgs, 'UniformOutput', false);
    i = 1;
    while i <= length(inputArgs)
        switch inputArgs{i}

            case 'mode',
                if i+1 > length(inputArgs)
                    des_error('RNGSeeds_ModeValueMissing', ...
                        ['Randomization mode not specified for ''Mode'' ', ...
                        'input argument. It must be ''All'' or ', ...
                        '''Identical'' or ''SpecifySeeds''. ', des_msg_type_help]);
                else
                    len = length(inputArgs{i+1});
                    if ~ischar(inputArgs{i+1})
                        des_error('RNGSeeds_InvalidModeValue', ...
                            ['Randomization mode must be a string with ',...
                            'value ''All'' or ''Identical''', ...
                            ' or ''SpecifySeeds''. ', des_msg_type_help]);
                    else
                        if ~strncmp(inputArgs{i+1}, 'identical', len) && ...
                                ~strncmp(inputArgs{i+1}, 'all', len) && ...
                                ~strncmp(inputArgs{i+1}, 'specifyseeds', len)
                            des_error('RNGSeeds_InvalidModeValue',...
                                ['Randomization mode must be either ',...
                                '''All'' or ''Identical'' ',...
                                'or ''SpecifySeeds''. ', des_msg_type_help]);
                        end
                    end
                    randomizationMode = inputArgs{i+1};
                    if strncmp(randomizationMode, 'specifyseeds', ...
                            length(randomizationMode))
                        if i+2 > length(inputArgs)
                            des_error('RNGSeeds_SeedsToChangeMissing', ...
                                ['Seeds to change not specified for mode ', ...
                                '''SpecifySeeds''. ', des_msg_type_help]);
                        else
                            if ~isnumeric(inputArgs{i+2})
                                des_error('RNGSeeds_InvalidSeedsToChange', ...
                                    ['Seeds specified for mode ',...
                                    '''SpecifySeeds'' must all be numeric. ',...
                                    des_msg_type_help]);
                            else
                                seedsToChange = inputArgs{i+2};
                            end
                        end
                        i = i + 3;
                    else
                        i = i + 2;
                    end
                end
                
            case 'globalseed',
                if i+1 > length(inputArgs)
                    des_error('RNGSeeds_GlobalSeedValueMissing', ...
                        ['Global seed value not specified for ',...
                        '''GlobalSeed'' input argument. It must be a ',...
                        'numeric value. ', des_msg_type_help]);
                else
                    if ~isnumeric(inputArgs{i+1})
                        des_error('RNGSeeds_InvalidGlobalSeedValue', ...
                            ['The global seed must be a scalar numeric value. ',...
                            des_msg_type_help]);
                    end
                    if ~isscalar(inputArgs{i+1})
                        des_error('RNGSeeds_GlobalSeedIsVector', ...
                            ['Global seed value must be a scalar real number. ', ...
                            des_msg_type_help]);
                    end
                    if (inputArgs{i+1} < 0) || (fix(inputArgs{i+1}) ~= inputArgs{i+1})
                        des_error('RNGSeeds_GlobalSeedIsNegative', ...
                            ['The global seed must be a scalar non-negative integer. ', ...
                            des_msg_type_help]);
                    end
                    globalSeed = double(inputArgs{i+1});
                    globalSeedIsUserSpecified = true;
                end
                i = i + 2;
                
            case 'verbose',
                if i+1 > length(inputArgs)
                    des_error('RNGSeeds_VerboseValueMissing', ...
                        ['Missing value for parameter ''Verbose''. Parameter ',...
                        'value must be either ''on'' or ''off''. ', des_msg_type_help]);
                else
                    if ~ischar(inputArgs{i+1})
                        des_error('RNGSeeds_VerboseValueNotChar', ...
                            ['The value for input parameter ''verbose'' must be ', ...
                            'either ''on'' or ''off''. ', des_msg_type_help]);
                    end
                    if isempty(intersect(inputArgs{i+1}, {'on', 'off'}))
                        des_error('RNGSeeds_InvalidVerboseValue', ...
                            ['The value for input parameter ''verbose'' must be. ',...
                            'either ''on'' or ''off''. ', des_msg_type_help]);
                    end
                    if strcmp(inputArgs{i+1}, 'on')
                        verbose = true;
                    else
                        verbose = false;
                    end
                end
                i = i + 2;
                                
            otherwise
                des_error('RNGSeeds_InvalidParameterValuePair', ...
                    ['Invalid parameter-value pair specified as input arguments. ',...
                    des_msg_type_help]);
                
        end
    end
end
end 


