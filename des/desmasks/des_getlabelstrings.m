function labelStr = des_getlabelstrings(conn, labels, offset, enabled)
% DES_GETLABELSTR coin the label str to be set as port labels

% Copyright 2004 The MathWorks, Inc.

if nargin < 3,
    offset = 0;
    numPorts = length(labels);
    enabled(1:numPorts) = deal({'yes'});
end

if nargin >= 3 && nargin < 4,
    numPorts = length(labels);
    enabled(1:numPorts) = deal({'yes'});
end

labelStr  = '';
for idx = 1:length(labels)
    if strcmp(enabled(idx),'no')
        continue;
    else
        port = num2str(idx + offset);
        if iscell(labels),
            label = strcat( '''', labels{idx}, '''');
        else
            label = strcat( '''', num2str(labels(idx)), '''');
        end
        labelStr  = strvcat(labelStr,strcat('port_label(' , '''',conn,'''', ...
                                        ',', port , ',' ,  label , ');'));
    end
end


