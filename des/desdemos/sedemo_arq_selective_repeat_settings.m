function sedemo_arq_selective_repeat_settings
% Parameter settings for arq_selective_repeat model

% Copyright 2006 The MathWorks, Inc.

% Ensure function is not run twice after first loading model.
persistent postloadFlag;
if isempty(postloadFlag)
    postloadFlag = true;
else
    if postloadFlag
        postloadFlag = false;
        return
    end
end


% Retrieve parameters from settings block
ControlDialogName = 'simulation settings';
SWS = str2double(get_param([bdroot '/' ControlDialogName],'SWS'));
Tframe = str2double(get_param([bdroot '/' ControlDialogName],'Tframe'));
Tprop = str2double(get_param([bdroot '/' ControlDialogName],'Tprop'));
Pe = str2double(get_param([bdroot '/' ControlDialogName],'Pe'));

% Assign values in base workspace
assignin('base','SWS',SWS);
assignin('base','Tframe',Tframe);
assignin('base','Tprop',Tprop);
assignin('base','Pe',Pe);

% Check if Tframe > Tprop
if Tframe > Tprop
    errordlg('Transmit time should be less than propagation time.');
end %if