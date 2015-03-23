function varargout = des_setattributemask(block, action, subaction,tabnum)
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/11/13 04:16:10 $

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
    
    MaskParamCheck = struct('UniqueCharCellArray', {idxAttribute1Name, idxAttribute2Name, idxAttribute3Name, idxAttribute4Name});
 
    % Pass the MaskParamCheck array of structures to the error checking
    % sub-function
    des_validateinputs(block, MaskParamCheck);

    % Check the attribute values
    checkAttributeValue(gcb);

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
        cbAttributeFrom(block,subaction,'1');
        % Tab 2
        cbAttributeFrom(block,subaction,'2');
        % Tab 3
        cbAttributeFrom(block,subaction,'3');
        % Tab 4
        cbAttributeFrom(block,subaction,'4');

		% Processing for Warning generation for obsolete blocks.  Event
		% though this is not a 'first use' message, the preference are
		% being used to enable the warnings to allow for convienent testing.
		% processing is identical to des_getattributemask.m
		% 
		% First check value of the preference for the warning
		warnName = 'ObsoletedSetAttributeBlockV1';
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
case 'cbAttributeFrom',
    cbAttributeFrom(block,subaction,tabnum);
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
    des_def_setattributemask(block,mfilename);
    % Statistics pane
    des_cbStats(block, 'StatNumberDeparted','#d',subaction);
    % Tab 1
    cbAttributeFrom(block,subaction,'1');
    % Tab 2
    cbAttributeFrom(block,subaction,'2');
    % Tab 3
    cbAttributeFrom(block,subaction,'3');
    % Tab 4
    cbAttributeFrom(block,subaction,'4');
% --- End of case 'default'
end; % End of switch(action)
return;

% ----------------
% --- Subfunctions
% ----------------

%*********************************************************************
% Function Name:    cbAttributeFrom
% Description:      Deal with the different Attribute Source modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbAttributeFrom(block, applyStatus, tabnum)

    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');
    En = get_param(block,'MaskEnables');
    
    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
    
    % Get the indices to the attribute parameters on a specific tab given
    % by the input argument 'tabnum'
    % The variable names used are not specific to the tab number for
    % consistency with other mask callback files.
    %     e.g. idxAttributeFrom will actually represent idxAttribute1From or
    %     idxAttribute2From ... etc depending on the 'tabnum'
    idxAttributeFrom = eval(['idxAttribute' tabnum 'From']);
    idxAttributeValue = eval(['idxAttribute' tabnum 'Value']);
    idxAttributeName = eval(['idxAttribute' tabnum 'Name']);
    idxAttributeDataType = eval(['idxAttribute' tabnum 'DataType']);
    idxAttributeCreate = eval(['idxAttribute' tabnum 'Create']);
    PortLabel = ['A' tabnum];
      
    % --- Update the Mask Parameters if the below switch statement resulted
    %     in new values for the Visibility variables
    AttributeFrom = Vals{idxAttributeFrom};
    
    switch AttributeFrom,
        
    case 'Off',
        [En{[idxAttributeValue idxAttributeName idxAttributeCreate idxAttributeDataType]}]   = deal('off');
        [Vis{[idxAttributeValue]}]   = deal('off');
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel, 'no');                     

    case 'Specify via dialog',
        [En{[idxAttributeValue idxAttributeName idxAttributeCreate idxAttributeDataType]}]   = deal('on');
    	[Vis{[idxAttributeValue]}]   = deal('on');
    	des_enableport(block, applyStatus, 'in' , 'SL', PortLabel, 'no');                     

    case ['From signal port ' PortLabel]
        [En{[idxAttributeValue]}]   = deal('off');
        [Vis{[idxAttributeValue]} ] = deal('off');
        [En{[idxAttributeName idxAttributeCreate idxAttributeDataType]}]   = deal('on');
        
        des_enableport(block, applyStatus, 'in' , 'SL', PortLabel, 'yes', 'dimsInfo', '-1');
              
    otherwise,
	des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Attribute Source' ]);
    end

    % No dependent callabacks -- just set the visibilities and leave
    set_param(block, 'MaskVisibilities', Vis, 'MaskEnables',En);
return;

function valid = checkAttributeValue(block)
    des_setfieldindexnumbers(block);
    Vals = get_param(block, 'maskvalues');
    WSVals = get_param(block, 'maskwsvariables');
    Vis = get_param(block, 'maskvisibilities');
    
    for count = 1:4 %four tabs
        PortLabel = ['A' num2str(count)];
        idxAttributeFrom = eval(['idxAttribute' num2str(count) 'From']);
        AttributeFrom = Vals{idxAttributeFrom};
        idxAttributeValue = eval(['idxAttribute' num2str(count) 'Value']);
        idxAttributeDataType = eval(['idxAttribute' num2str(count) 'DataType']);
        AttributeDataType = Vals{idxAttributeDataType};
        
        switch AttributeFrom,
            case 'Off',
                isValid(count) = 1;
                %do nothing and return                
            case 'Specify via dialog',
                switch AttributeDataType,
                    case 'Double',
                         MaskParamCheck1 = struct('Numeric', {idxAttributeValue}, ...
                               'isValid', {'IsReal'}, ...
                                'inRange', {[-Inf Inf]}); 
                        isValid(count) = des_validateinputs(block, MaskParamCheck1);
                    case 'Integer',
                        MaskParamCheck1 = struct('Numeric', {idxAttributeValue}, ...
                                                 'isValid',  {'IsInt'      }, ...
                                                 'inRange',  {[-Inf Inf]    }); 
                        isValid(count) = des_validateinputs(block, MaskParamCheck1);
                    otherwise
                       des_mask_error(block, 'DES_InvalidParameter', 'invalid option for attribute data type');
                end                
            case ['From signal port ' PortLabel],
                isValid(count) = 1;
                %do nothing and return
            otherwise,
                des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Attribute Source' ]);
        end            
    end 
    valid = all(isValid);    
return

% --- end of des_setattributemask.m