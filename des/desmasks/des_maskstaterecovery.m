function des_maskstaterecovery(block)
% des_maskstaterecovery  
% Instead of recovering mask state to the last known state, a error is
% thrown.
%
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/02/13 15:11:45 $

msg = sprintf(['The internal state of the SimEvents block, %s, has been corrupted.\n' ...
        'Please get an new copy from the library. \n\n'...
        'Please report this error to The MathWorks Inc.\n'], block);
des_mask_error(block,'DES_MASK_InternalMaskError',msg);    
    
% b_ud = get_param(block,'userdata');
% if( b_ud.in_init)
%     return;
% else
%     msg = sprintf(['The internal state of the SimEvents block, %s, has been corrupted.\n\n' ...
%         'Attempting repair by reverting to last known state.'], block);
% %    errordlg(msg,[ get_param(block,'name') ' Dialog Error'],'modal');
%     warning([des_getproductname 'DES_BlockMaskRecoveryFailed'],msg);
% end
% 
% b_ud.in_init = 1;  % set to  initing
% set_param(block,'userdata',b_ud);  % need this set right away
% [child childName] = des_getchildblockname(block);
% ud = get_param(child,'userdata');
% 
% PinfoName = {'ipInfoSE', 'opInfoSE', 'ipInfoSL', 'opInfoSL'};
% Ptag = {ud.dip.PTagSL, ud.dop.PTagSL, ud.dip.PTagSL, ud.dop.PTagSL};
% Ptype = {'SE', 'SE', 'SL','SL'};
%     
% try,        
%     if findstr(action,'clearlines'),
%         % --- Remove old lines
%         theseLines = get_param(block, 'Lines');
%         for idx = 1:length(theseLines),
%             delete_line(theseLines(idx).Handle);
%         end
%     end
%     if findstr(action,'clearblocks'),
%         % --- Remove old blocks
%         TheseBlocks = get_param(block, 'Blocks');
%         for idx = 1:length(TheseBlocks),
%             toDeleteName = TheseBlocks{idx};
%             if ~strcmp(toDeleteName, childName)
%                 delete_block([block '/' toDeleteName]);
%             end
%         end
%     end
%     
%     % --- UPDATE ports in the block according to the constants in 'ud'
%     if findstr(action,'update'),
%         for idxType = 1:length(PinfoName),
%             Pinfo = getfield(ud, PinfoName{idxType});
%  %           for idx = 1:length(Pinfo.portLabel),
%                 des_enableports(block, Ptag{idxType}, Ptype{idxType}, ...
%                     Pinfo.portLabel, Pinfo.isEnabled,1);
%  %           end
%         end
%     end
% 
% catch,
%     msg = sprintf(['Error occurred while trying to recover the state of the SimEvents block, %s\n' ...
%         '.  Please get an new copy from the library.'],  block);
%     b_ud.in_init = 0;  % no longer initing
%     set_param(block,'userdata',b_ud);  % need this set right away
%     des_mask_error(block,'DES_MASK_InternalMaskError',msg);
% end
%  
% b_ud.in_init = 0;  % no longer initing
% set_param(block,'userdata',b_ud);  % need this set right away
% 
% return