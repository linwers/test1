function MaskWSData = des_ddg_init(h,className)
% This function is the initialization function from the Mask Editor. This
% function is called at the following occasions:
% 1. Get a new block from the library 
% 2. Hit OK or Apply on the dialog
% 3. Update diagram or ctrl+d 
% This block ensures a healthy state of ports in the above cases by calling
% the des_enableports function

% Copyright 2003-2006 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2009/08/11 15:38:45 $

% desdialog is the package containing all the classes corresponding to the
% dynamic dialogs for all DES blocks--So far only Entity Generator (10/27/04)

% b_ud = get_param(h,'userData');
% if(~isfield(b_ud,'in_ddgblockupdate'))
%     b_ud.in_ddgblockupdate = 0;  % updating
%     set_param(h,'userData',b_ud);
% end

% code to prevent recursion
b_ud = get_param(h,'userData');
if ( isfield( b_ud, 'in_blockupdate' ) && b_ud.in_blockupdate )
    MaskWSData = [];
    return;
end

obj = DES.(className)(h);
% GetFullName gives the full pathname to the block with 
% '/' from the block name replaced by '//':
block = getfullname(h);
obj.maskCallback(block,'init');
MaskWSData = obj.processingSpecificToBlock;
