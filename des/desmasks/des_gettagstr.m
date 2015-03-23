function tagStr = des_gettagstr(str,numPorts)
% DES_GETTAGSTR coin the tag str to be set in the port labels.

% Copyright 2004 The MathWorks, Inc.

if numPorts,
    tagStr = str;
else
    tagStr = '';
end
for idx = 2:numPorts
    tagStr = strcat(tagStr,'|',str);
end
