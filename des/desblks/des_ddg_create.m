function obj = des_ddg_create(h,className)
% This function is called when you doubleclick on a block with its
% DialogController parameter is set to desDDGCreate to create the dynamic
% dialog corresponding to the block. The className is specified in the
% DialogControllerArgs parameter.
% Example:
% For the dynamic dialog to work for the Entity Generator block you will
% have to execute the following two commands as a part of the configuration
% of the block.
% set_param(gcbh,'dialogcontroller','des_ddg_create');
% set_param(gcbh,'dialogcontrollerargs','EntityGenerator')

% Copyright 2003-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2005/11/23 20:25:22 $

% desdialog is the package containing all the classes corresponding to the
% dynamic dialogs for all DES blocks--So far only Entity Generator (10/27/04)
obj = DES.(className)(h);

