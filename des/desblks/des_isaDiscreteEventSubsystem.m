function result = des_isaDiscreteEventSubsystem(blockHandle)

% Initialize return value
result = 0;

if ~isempty(blockHandle)
    try
        h = get_param(blockHandle, 'UserData');
        if isfield(h, 'BlockType')
            if strcmp(h.BlockType, 'DESsubsystem')
                result = 1;
            end
        end
    catch e %#ok<NASGU>
        % do nothing
    end
end

end
