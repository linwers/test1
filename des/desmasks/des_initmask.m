function des_initmask(block, action, subaction)
% des_initmask - common initialization function
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/11/23 20:28:15 $


% --- Ensure that the mask is correct 
if (nargin >= 3),
    if strcmp(subaction,'porttest'),
        des_cbrunporttest(block);
    end
end

% --- try to change the linkstatus to resolved
status = get_param(block,'linkstatus');
if ~strcmp(status, 'resolved'),
    try
        b_ud = get_param(block,'userdata');
        b_ud.in_blockupdate = 1;
        set_param(block,'userdata',b_ud);
%        set_param(block,'linkstatus','restore');
    catch
    end
    b_ud = get_param(block,'userdata');
    b_ud.in_blockupdate = 0;
    set_param(block,'userdata', b_ud);
end

return;

