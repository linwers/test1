function varargout = des_getattributemask(block, action, subaction,tabnum)
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/11/13 04:16:05 $

%*********************************************************************
% --- Action switch -- Determines which of the callback functions is called
%*********************************************************************

switch(action)
%*********************************************************************
% Function Name:     init
% Description:       Main initialization code
% Inputs:            current block and any parameters from the mask
%                    required for parameter calculation.
% Return Values:     params - Parameter structure
%********************************************************************
case 'init',
    % Get the block position
    blockPosition =  get_param(block, 'position');

    % Create the idxParamName variables
    des_setfieldindexnumbers(block);
    MaskParamCheck{1} = struct('CharString', {idxAttribute1Name, idxAttribute2Name, idxAttribute3Name, idxAttribute4Name});
    MaskParamCheck{2} = struct('Numeric', {idxAttribute1DefaultValue,idxAttribute2DefaultValue, idxAttribute3DefaultValue, idxAttribute4DefaultValue}, ...
                               'isValid', {'IsReal'       ,'IsReal'       , 'IsReal'       , 'IsReal'       }, ...
                               'inRange', {[-Inf Inf]     ,[-Inf Inf]     , [-Inf Inf]     , [-Inf Inf]    });

    % Pass the MaskParamCheck array of structures to the error checking
    % sub-function
    des_validateinputs(block, MaskParamCheck);

        % --- check if we are in a block update (and don't want to
        %     be called)  This reduces flicker in the mask and ports.
        b_ud = get_param(block,'userdata');
        if b_ud.in_blockupdate,
            return;
        end

        % --- Set Field index numbers and mask variable data
        [child childName] = des_getchildblockname(block);

        % --- call independent callback functions in block that have other
        %     callback function that depend on it.  These functions
        %     will call, in turn, the dependent callback functions.

        % Statistics pane
        des_cbStats(block, 'StatNumberDeparted','#d',subaction);
        % Tab 1
        cbAttributeTo(block,subaction,'1');
        % Tab 2
        cbAttributeTo(block,subaction,'2');
        % Tab 3
        cbAttributeTo(block,subaction,'3');
        % Tab 4
        cbAttributeTo(block,subaction,'4');
    
		% Processing for Warning generation for obsolete blocks.  Event
		% though this is not a 'first use' message, the preference are
		% being used to enable the warnings to allow for convienent testing.
		% processing is identical to des_setattributemask.m
		% 
		% First check value of the preference for the warning
		warnName = 'ObsoletedGetAttributeBlockV1';
		preference = getpref('simevents_firstuse', warnName,'on');
		if strcmp(preference, 'on')
			% obsolescence warning message
			blockName = get_param(block,'name');
			blockPath = [get_param(block,'parent') '/' blockName];
			blockPath = strrep(blockPath,char(10),' ');
			blockPath = strrep(blockPath,char(13),' ');
			blockPathLink = strrep(blockPath,'//','/');
			blockType = get_param(block,'masktype');
			blockType = strrep(blockType,char(10),' ');
			blockType = strrep(blockType,char(13),' ');
			warningFormat = ['The <a href="matlab:hilite_system(''%s'',''find'')">' ...
						'%s</a> block will be removed in a future release. '...
						'Please replace this block with the ' ...
						'<a href="matlab:simeventsattributes2;hilite_system(''%s'',''find'')">' ...
						'%s</a> block from the simeventsattributes2 library.'];
			warningMsg = sprintf(warningFormat,blockPath, blockPathLink, ...
						['simeventsattributes2/' blockType], blockType);
			des_warning(warnName, warningMsg);
		end
	

    % Set the block position back to what it was     
    set_param(block, 'position', blockPosition);    
% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbAttributeTo',
    cbAttributeTo(block,subaction,tabnum);
case 'cbAttributeMissing'
    cbAttributeMissing(block, tabnum);
case 'cbStatNumberDeparted',
    des_cbStats(block, 'StatNumberDeparted','#d',subaction);
%----------------------------------------------------------------------
%   Setup/Utility functions
%----------------------------------------------------------------------

%*********************************************************************
% Function Name:    'default'
% Description:      Set the block defaults (development use only)
% Inputs:           current block
% Return Values:    none
%*********************************************************************
case 'default',
    des_def_getattributemask(block,mfilename);
    % Statistics pane
    des_cbStats(block, 'StatNumberDeparted','#d',subaction);
    % Tab 1
    cbAttributeTo(block,subaction,'1');
    % Tab 2
    cbAttributeTo(block,subaction,'2');
    % Tab 3
    cbAttributeTo(block,subaction,'3');
    % Tab 4
    cbAttributeTo(block,subaction,'4');
% --- End of case 'default'
end; % End of switch(action)
return;

% ----------------
% --- Subfunctions
% ----------------

%*********************************************************************
% Function Name:    cbAttributeTo
% Description:      Deal with the different Attribute Source modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbAttributeTo(block, applyStatus, tabnum)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    En = get_param(block,'MaskEnables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    % Get the indices to the attribute parameters on a specific tab given
    % by the input argument 'tabnum'
    % The variable names used are not specific to the tab number for
    % consistency with other mask callback files.
    %     e.g. idxAttributeTo will actually represent idxAttribute1To or
    %     idxAttribute2To ... etc depending on the 'tabnum'
    idxAttributeTo = eval(['idxAttribute' tabnum 'To']);
    idxAttributeName = eval(['idxAttribute' tabnum 'Name']);
    idxAttributeMissing = eval(['idxAttribute' tabnum 'Missing']);
    idxAttributeDefaultValue = eval(['idxAttribute' tabnum 'DefaultValue']);
    PortLabel = ['A' tabnum];

    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    AttributeTo = Vals{idxAttributeTo};

    switch AttributeTo,

    case 'Off',
        [En{[idxAttributeName idxAttributeMissing idxAttributeDefaultValue]}]   = deal('off');
        des_enableport(block, applyStatus, 'out' , 'SL', PortLabel, 'no');
        set_param(block, 'MaskEnables',En);
        return;
      case 'On',
        [En{[idxAttributeName idxAttributeMissing]}]   = deal('on');
        des_enableport(block, applyStatus, 'out' , 'SL', PortLabel, 'yes', 'dimsInfo', '-1');    
        
        % case 'Before entity departure',
        %[En{[idxAttributeName idxAttributeMissing]}]   = deal('on');
    	%des_enableport(block, applyStatus, 'out' , 'SL', PortLabel, 'yes');

        %case 'After entity departure',
        %[En{[idxAttributeName idxAttributeMissing]}]   = deal('on');
    	%des_enableport(block, applyStatus, 'out' , 'SL', PortLabel, 'yes');

    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Attribute Source' ]);
    end

    % set the visibilities and leave
    set_param(block, 'MaskEnables',En);
    % Call dependent callabacks
    cbAttributeMissing(block, tabnum);
return;

%*********************************************************************
% Function Name:    cbAttributeMissing
% Description:      Deal with the different Attribute Source modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbAttributeMissing(block, tabnum)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block, 'maskenables');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    % Get the indices to the attribute parameters on a specific tab given
    % by the input argument 'tabnum'
    % The variable names used are not specific to the tab number for
    % consistency with other mask callback files.
    %     e.g. idxAttributeMissing will actually represent idxAttribute1Missing or
    %     idxAttribute2Missing ... etc depending on the 'tabnum'
    idxAttributeMissing = eval(['idxAttribute' tabnum 'Missing']);
    idxAttributeDefaultValue = eval(['idxAttribute' tabnum 'DefaultValue']);
    PortLabel = ['A' tabnum];

    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    AttributeMissing = Vals{idxAttributeMissing};
    AttributeDefaultValue = Vals{idxAttributeDefaultValue};

    switch AttributeMissing,

    case 'Error',
        [Vis{[idxAttributeDefaultValue]}]   = deal('off');
        [En{[idxAttributeDefaultValue]}]   = deal('off');

    case 'Output default value',
        [En{[idxAttributeDefaultValue]}]   = deal('on');
        [Vis{[idxAttributeDefaultValue]}]   = deal('on');

    case 'Output default value and warn',
        [En{[idxAttributeDefaultValue]}]   = deal('on');
        [Vis{[idxAttributeDefaultValue]}]   = deal('on');

    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Action on missing attribute' ]);
    end

    % No dependent callabacks -- just set the visibilities and leave
    set_param(block, 'MaskEnables',En,'MaskVisibilities',Vis);
return;
% --- end of des_getattributemask.m
