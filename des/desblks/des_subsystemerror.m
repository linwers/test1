function msg = des_subsystemerror(blk, id)
%DES SUBSYSTEM ERROR HANDLER - redirect an error message from Discrete
%Event Subsystem
  
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/12/10 21:24:37 $ 

%
% get the last simulink error message, this is our error
%
slerr = sllasterror;
msg   = slerr.Message;

% Replace complex signal mismatch error by a SimEvents defined one
try
    if(strcmp(id,'SL_InputPortComplexSignalMismatch'))
        start_idx = strfind(msg,'Input port');
        if(~isempty(start_idx))
            msg1 = msg(start_idx+11:end);
            toc = strtok(msg1);
            if(~isempty(toc))
                msg = ['Complex signals cannot execute discrete event ' ...
                    'subsystems when ''Type of signal-based event'' is ' ...
                    '''Change in signal'' or ''Trigger''. At input port ' ...
                    toc ', use a real signal or set ''Type of signal-' ...
                    'based event'' to ''Sample time hit'''];
            end
        end
    end
catch %#ok<CTCH>
  % do not replace error message, use original Simulink error message
end
  