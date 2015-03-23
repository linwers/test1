function portInfoOut = des_convertportinfo(portInfoIn)
% Description:      convert compact format port information to expanded
%                   format
% Inputs:           portInfoIn
% Return Values:    portInfoOut

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/23 19:32:43 $
outIdx = 1;
for InIdx = 1:length(portInfoIn.portLabel),

    % Start with all of the ports being enabled
    if ischar(portInfoIn.isEnabled{InIdx}),
        portInfoOut.isEnabled{outIdx} = portInfoIn.isEnabled{InIdx};
        portInfoOut.portLabel{outIdx} = portInfoIn.portLabel{InIdx};
        outIdx = outIdx + 1;
    else
        for num = 1:portInfoIn.isEnabled{InIdx},
            portInfoOut.isEnabled{outIdx} = 'yes';
            portInfoOut.portLabel{outIdx} = [portInfoIn.portLabel{InIdx} num2str(num)];
            outIdx = outIdx + 1;
        end
    end
end