function des_changeCfgPrmTab(hDlg, tag, index)
% DES_CHANGECFGPRMTAB

% Copyright 2003-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $

hSrc = getDialogSource(hDlg);
set(hSrc, 'SimEventsActiveTab', index);    