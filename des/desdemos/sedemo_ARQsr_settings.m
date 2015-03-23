function sedemo_ARQsr_settings
% Parameter settings for ARQsr model

% Copyright 2005 The MathWorks, Inc.

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
ControlDialogName = 'a Simulation Settings';
N = str2num(get_param([bdroot '/' ControlDialogName],'N'));
Tforward = str2num(get_param([bdroot '/' ControlDialogName],'Tforward'));
Treturn = str2num(get_param([bdroot '/' ControlDialogName],'Treturn'));
Pe = str2num(get_param([bdroot '/' ControlDialogName],'Pe'));
hideDisp = get_param([bdroot '/' ControlDialogName],'hideDisp');

% Assign values in base workspace
params.N = N;
params.Tforward = Tforward;
params.Treturn = Treturn;
params.Pe = Pe;
assignin('base','params',params);

% Hide or show scopes
if strcmp(hideDisp,'on')
    set_param([bdroot '/Transmitted Packets'],'OpenScopeAtSimStart','off');
    set_param([bdroot '/Sorted Packets'],'OpenScopeAtSimStart','off');
    set_param([bdroot '/Receiver/Received Packets'],'OpenScopeAtSimStart','off');
    set_param([bdroot '/Receiver/crc_check'],'OpenScopeAtSimStart','off');
else
    set_param([bdroot '/Transmitted Packets'],'OpenScopeAtSimStart','on');
    set_param([bdroot '/Sorted Packets'],'OpenScopeAtSimStart','on');
    set_param([bdroot '/Receiver/Received Packets'],'OpenScopeAtSimStart','on');
    set_param([bdroot '/Receiver/crc_check'],'OpenScopeAtSimStart','on');
end