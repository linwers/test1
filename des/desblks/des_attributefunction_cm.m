function state = des_attributefunction_cm(callbackInfo)
% This function is called if all of the following conditions are true:
% 1. A model with an Attribute Function block was opened in this MATLAB
% session
% 2. The user right clicks on any block to view the context menu

% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/06/08 15:56:32 $

% If this block is an Attribute Function block,
% Disable the Edit Mask opption from the context menu

state = 'Enabled';
try
    if(~isempty(callbackInfo.getSelection) && numel(callbackInfo.getSelection)<2 && isequal(callbackInfo.getSelection.Type,'block'))
        if(des_isaAttributeFunction(callbackInfo.getSelection.getFullName))
            state = 'Disabled';
        end
    end
catch
    state = 'Disabled';
end