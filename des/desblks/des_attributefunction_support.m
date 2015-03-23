function varargout = des_attributefunction_support(attrFunctionBlk,action, varargin)
% This function has the implementation of various block callbacks for the
% Attribute Function block such as OpenFcn, CopyFcn, Error redirect etc.

% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/11/07 18:23:33 $

[emblkName, chartHandle] = getAttrFcnData(attrFunctionBlk);

switch action
    case 'OpenFcn'       
        % Open the editor
        chartHandle.view; 
    case 'CopyFcn'
        refBlk = 'simeventsuserdefined1/Attribute Function';
        % Break the library link if this block is linked to the 
        % AFB from SimEvents User Defined library
        if(strcmp(get_param(attrFunctionBlk,'ReferenceBlock'),refBlk))
            if ~strcmp(get_param(attrFunctionBlk,'LinkStatus'),'none')
                set_param(attrFunctionBlk, 'LinkStatus', 'none');
            end  
        end
    case 'LoadFcn'
        % Add a callback filter that disables the Edit Mask menu item from
        % the context menu:
        AddEditMaskFilter();        
        if strcmp(get_param(attrFunctionBlk,'LinkStatus'),'none')
            % Configure the AFB block.
            des_eml_manager(chartHandle.id,'update');
        end
    case 'Error'
        % This case is called from des_error_redirect.m when The blocks in
        % the AFB subsystem throw an error.
        
        msg   = varargin{1};

        % Replace the strings 'Attribute Function/*' by 'Attribute Function'
        blkName = get_param(attrFunctionBlk,'name');
        msg = regexprep(msg,[blkName '\/\w*'],blkName);
        % Some error messages have the string 'Error occurred in' and some
        % have the string 'Error in' - we need to get rid of both.
        str1  = strcat('Error occurred in',' ''',attrFunctionBlk,'''.');
        msg = regexprep(msg, str1, '');
        str2  = strcat('Error in ',' ''',getfullname(attrFunctionBlk),'''.');
        msg = regexprep(msg, str2, '');
        varargout{1} = msg;
    case 'StartFcn'
        % Check the output argument prefix before starting the simulation
        des_eml_manager(chartHandle.id,'errorcheck');
    otherwise
        des_error('DES_InvalidParam','Invalid action specified in Attribute Editor mask');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
function [emblkName, chartHandle] = getAttrFcnData(attrFunctionBlk)
% Get the EML block name and the chart Handle

emblkName = 'Embedded MATLAB Function';
emPath = [attrFunctionBlk '/' emblkName];     

if any(strcmp(get_param(attrFunctionBlk,'LinkStatus'),{'resolved','implicit'}))
    % The Attribute Function block is linked to a library
    % This library must be loaded in order to get the chart handle
    % The chart handle is the handle to the library chart
    LoadLibraryWithAFB(attrFunctionBlk, emPath)
    % Get the path to the library chart
    refAttrFcnBlk = get_param(attrFunctionBlk,'ReferenceBlock');
    refEmPath = [refAttrFcnBlk '/' emblkName];     
    emblk = handle(get_param(refEmPath,'handle'));
    % Get the chart handle to the EML block from the library
    chartHandle = emblk.find('-isa','Stateflow.EMChart','Path',refEmPath);
else
    rt = slroot;
    parent_mdl = bdroot(attrFunctionBlk);
    % The EML block is not linked to a library block.
    sfmach = rt.find('-isa','Stateflow.Machine','name',parent_mdl);    
    % Get the handle to the chart from this model
    chartHandle = sfmach.find('-isa','Stateflow.EMChart','path',emPath);     
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
function AddEditMaskFilter
% This function adds a filter function to the simulink customization
% manager so that the 'Edit Mask' menu item from the context menu of the
% Attribute Function block can be disabled.

% DES function that sets the state of the 'Edit Mask' context menu
% item:        
fhandle = @des_attributefunction_cm;
% Running the following two commands enables the display of the
% menu tags: 
% cm = sl_customization_manager;
% cm.showWidgetIdAsToolTip=true;
MenuTag1ForEditMask = 'Simulink:ContextCreateMask';
MenuTag2ForEditMask = 'Simulink:CreateMask';
% Get the current customization settings for the EditMask
% menu
cm = sl_customization_manager;
customFiltersCell1 = cm.getCustomFilterFcns(MenuTag1ForEditMask);
customFiltersCell2 = cm.getCustomFilterFcns(MenuTag2ForEditMask);
% Check if the Edit Mask menu has been already customized with the
% des function 
if(~any(cellfun(@(u)isequal(u,fhandle), customFiltersCell1)))            
    cm.addCustomFilterFcn(MenuTag1ForEditMask,@des_attributefunction_cm);
end

if(~any(cellfun(@(u)isequal(u,fhandle), customFiltersCell2)))
    cm.addCustomFilterFcn(MenuTag2ForEditMask,@des_attributefunction_cm);
end
% -----------------------------------------------
function LoadLibraryWithAFB(attrFunctionBlk, emPath)
% This function is called when the Attribute Function block is linked to a
% library. This function loads the library with the reference block.

linkStatus = get_param(attrFunctionBlk,'LinkStatus');
switch linkStatus
    case 'implicit'
        % implicit linkstatus indicates that the Attribute Function block
        % is inside a block (subsystem) linked to a library.
        % Get the parent block with resolved library link:
        BlockWithResolvedLink = GetLinkedParent(attrFunctionBlk);
        libdata=libinfo(BlockWithResolvedLink);
    case 'resolved'
        BlockWithResolvedLink = attrFunctionBlk;
        libdata = libinfo(attrFunctionBlk);            
    otherwise
         des_error('DES_InvalidParam',['SimEvents internal error: Atttribute Function block' attrFunctionBlk ' has invalid library link status']);
end
% Get the reference block
refBlk = get_param(BlockWithResolvedLink,'ReferenceBlock');
blkidx = find(strcmp({libdata.Block},BlockWithResolvedLink));
if(isempty(blkidx))
     des_error('InternalNoLibrary',['SimEvents Internal Error: The Attribute Function block ' attrFunctionBlk ' has a resolved library link.' ...
             'But libinfo is unable to find the library.']);
end        
% Get the library name:
libName = libdata(blkidx).Library;
try
    load_system(libName);
catch
    warning([des_getproductname 'DES_AFB_CannotLoadLibrary'], ...
        ['Unable to load the ' libName ' library when opening the Embedded MATLAB script for the ' attrFunctionBlk 'block.']);
end

% ----------------------------------------
function LinkedParent = GetLinkedParent(attrFunctionBlk)
% This function is called for an Attribute Function block with linkstatus
% set to implicit. This function returns the parent block that has the
% linkstatus resolved to a library link.
temp_parentBlk = attrFunctionBlk;
parent_linkstatus = get_param(attrFunctionBlk,'LinkStatus');
while(~strcmp(parent_linkstatus,'resolved'))
    LinkedParent = get_param(temp_parentBlk, 'parent');
    parent_linkstatus = get_param(LinkedParent,'LinkStatus');
    temp_parentBlk = LinkedParent;
end    
