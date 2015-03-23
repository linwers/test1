function varargout = des_scopemask2(block, action, subaction)
% DES_SCOPEMASK@ mask helper function for NEW DES scope block

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2007/11/07 18:26:50 $

%*********************************************************************
% --- Action switch -- Determines which of the callback functions is called
%*********************************************************************
% dbstop if error

sfunname = 'des_scope2'; % default value for sfunction name

switch(action)
%*********************************************************************
% Function Name:     init
% Description:       Main initialization code
% Inputs:            current block and any parameters from the mask
%                    required for parameter calculation.
% Return Values:     params - Parameter structure
%********************************************************************
case 'init',
    % --- check if we are in a block update (and don't want to
    %     be called)  This reduces flicker in the mask and ports.
    b_ud = get_param(block,'userdata');
    if isempty(b_ud) || b_ud.in_blockupdate,
        return;
    end

    % --- Set Field index numbers and mask variable data
    des_setfieldindexnumbers(block);
    [child childName] = des_getchildblockname(block);

    % --- get variables and indexes
    des_setfieldindexnumbers(block);
    Vals = get_param(block, 'maskvalues');

    cbInputType(block, subaction);
    cbPlotType(block, subaction);
    cbXInputOptionEntity(block, subaction);
    cbXInputOptionSignal(block, subaction);
    InputType = Vals{idxInputType};
    switch InputType,
    case 'Signal',
        des_cbStats(block,'StatNumberArrived', '#c', subaction);
    case 'Attribute',
        des_cbStats(block,'StatNumberArrived', '#a', subaction);
    otherwise,
        des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for input type', InputType ]);
    end

        
    % pack mask dialog into a struct and call sfunction
    oldParams = getWorkspaceVarsAsStruct(block);

    status    =  get_param(bdroot(block),'simulationstatus');
    isRunning = strcmp(status,'running') | strcmp(status,'initializing') ...
        | strcmp(status,'updating');
    
    % Get new parameters
    newParams = getWorkspaceVarsAsStruct(block);

    feval(sfunname,[],[],[],'DialogApply', newParams, block);  

    % compare to the old parameters
    if hasRelevantParamChanged(block, newParams, oldParams),
        feval(sfunname,[],[],[],'resetToFirstCall',block); 
    end

% --- End of case 'init'

%----------------------------------------------------------------------
%   Callback interfaces
%----------------------------------------------------------------------
case 'cbInputType',
    cbInputType(block, subaction);
case 'cbPlotType',
    cbPlotType(block, subaction);
case 'cbNumInports'
    cbNumInports(block, subaction);
case 'cbXInputOptionSignal',
    cbXInputOptionSignal(block, subaction);  % FIX
case 'cbXInputOptionEntity',
    cbXInputOptionEntity(block, subaction);  % FIX
case 'cbCount',
   des_cbStats(block,'StatNumberArrived', '#a', subaction);
case 'cbEnableEntityOutport',
   cbEnableEntityOutport(block, subaction);
case 'cbXGrowthOpt',
%   cbXGrowthOpt(block, subaction);
case 'cbYGrowthOpt',
%   cbYGrowthOpt(block, subaction);
case 'cbPlotPointsUpon',
   cbPlotPointsUpon(block, subaction);

case 'OpenScope',
   % Open scope figure window:
    feval(sfunname,[],[],[],'OpenScope',block);    
case 'cbDataStoreOption',
   cbDataStoreOption(block, subaction);


%----------------------------------------------------------------------
%   Setup/Utility functions
%----------------------------------------------------------------------
case 'default',
    return;
    
    Vals = get_param(block, 'maskvalues');
    des_setfieldindexnumbers(block);
    des_def_scopemask2(block,mfilename);

    cbInputType(block, subaction);
    cbPlotType(block, subaction);

    InputType = Vals{idxInputType};
    switch InputType,
    case 'Signal',
        des_cbStats(block,'StatNumberArrived', '#c', subaction);
    case 'Attribute',
        des_cbStats(block,'StatNumberArrived', '#a', subaction);
    otherwise,
        des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for input type', InputType ]);
    end
%    cbNumInports(block, subaction);

% --- End of case 'default'
end; % End of switch(action)

return; % End of the 'function des_scopemask.m'

% ------------------------ Subfunctions ------------------------

%*********************************************************************
% Function Name:    cbInputType
% Description:      Update the input type to the mask value
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbInputType(block,applyStatus)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    InputType = Vals{idxInputType};
    switch InputType,
    case 'Signal',
    	[Vis{[idxXInputOptionSignal]}]  = deal('on');
    	[Vis{[idxAttributeNameX idxAttributeNameY ...
            idxXInputOptionEntity idxEnableEntityOutport]} ] = deal('off');
        priority = num2str(1);
        des_enableport(block, applyStatus, 'in' , 'SE', 'IN', 'no');
        des_enableport(block, applyStatus, 'in' , 'SL', 'in', 'yes', ...
            'timingcontrol', 'Simulink', 'execIndex', priority, 'IsMonitorOnly','on');

        set_param(block, 'MaskVisibilities', Vis);
        cbXInputOptionEntity(block,applyStatus);
        des_enableport(block, applyStatus, 'out' , 'SE', 'OUT', 'no');
    case 'Attribute',
    	[Vis{[idxXInputOptionSignal]}]  = deal('off');
    	[Vis{[idxAttributeNameX idxAttributeNameY ...
            idxXInputOptionEntity idxEnableEntityOutport]} ] = deal('on');
        des_enableport(block, applyStatus, 'in' , 'SE', 'IN', 'yes');
        des_enableport(block, applyStatus, 'in' , 'SL', 'in', 'no');
        
        set_param(block, 'MaskVisibilities', Vis);
        cbXInputOptionEntity(block,applyStatus);
        cbEnableEntityOutport(block, applyStatus)
    otherwise,
        des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for InputType', InputType ]);
    end

    PlotType = Vals{idxPlotType};
    switch PlotType,
    case 'Instantaneous entity counting',
    	[Vis{[idxAttributeNameY idxXInputOptionEntity]}] = deal('off');
        set_param(block, 'MaskVisibilities', Vis);
    otherwise,
%    	[Vis{[idxPlotType]}]  = deal('on');
    end
return;

%*********************************************************************
% Function Name:    cbXInputOptionSignal
% Description:      Choose the input that is used for the x axis, time or other
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbXInputOptionSignal(block,applyStatus)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    if strcmp(Vals{idxInputType},'Attribute'), 
        return
    end

    [Vis{[idxAttributeNameX]}]  = deal('off');    
    
    XInputOptionSignal = Vals{idxXInputOptionSignal};
    switch XInputOptionSignal,
    case 'Event time',
        des_enableport(block, applyStatus, 'in' , 'SL', 'x', 'no');
    case 'Signal',
        des_enableport(block, applyStatus, 'in' , 'SL', 'x', 'yes');
        [Vis{[idxXInputOptionSignal]}]  = deal('off');    
    case 'Index',
        des_enableport(block, applyStatus, 'in' , 'SL', 'x', 'no');
    otherwise,
        des_mask_error(block, 'DES_InvalidParameter', ['Illegal value XInputOptionSignal' XInputOptionSignal]);
    end

    set_param(block, 'MaskVisibilities', Vis);
return;

%*********************************************************************
% Function Name:    cbXInputOptionEntity
% Description:      Choose the input that is used for the x axis, time or other
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbXInputOptionEntity(block,applyStatus)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    if strcmp(Vals{idxInputType},'Signal'), 
        return
    end

    des_enableport(block, applyStatus, 'in' , 'SL', 'x', 'no');

    XInputOptionEntity = Vals{idxXInputOptionEntity};
    switch XInputOptionEntity,
    case 'Event time',
    	[Vis{[idxAttributeNameX]}]  = deal('off');
    case 'Attribute',
    	[Vis{[idxAttributeNameX]}]  = deal('on');
    	[Vis{[idxXInputOptionEntity]}]  = deal('off');
    case 'Index',
    	[Vis{[idxAttributeNameX]}]  = deal('off');
    otherwise,
       des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for XInputOptionEntity' XInputOptionEntity]);
    end

    set_param(block, 'MaskVisibilities', Vis);
return;

%*********************************************************************
% Function Name:    cbPlotType
% Description:      Update the plot type to the mask value
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbPlotType(block,applyStatus)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    PlotType = Vals{idxPlotType};
    switch PlotType,
    case 'Instantaneous entity counting',
    	[Vis{[idxPlotType]}]  = deal('off');
    otherwise,
    end

    set_param(block, 'MaskVisibilities', Vis);

return;


%*********************************************************************
% Function Name:    cbEnableEntityOutport
% Description:      Update the number of ports to match the mask value
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbEnableEntityOutport(block, applyStatus)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    EnableEntityOutport = Vals{idxEnableEntityOutport};
    switch EnableEntityOutport,
    case 'on',
        des_enableport(block, applyStatus, 'out' , 'SE', 'OUT', 'yes');
    case 'off',
        des_enableport(block, applyStatus, 'out' , 'SE', 'OUT', 'no');
    otherwise,
        des_mask_error(block, 'DES_InvalidParameter', ['Illegal value for Enable Entity port OUT ' EnableEntityOutport]);
    end

    set_param(block, 'MaskVisibilities', Vis);
    return;


%*********************************************************************
% Function Name:    cbNumInports
% Description:      Update the number of ports to match the mask value
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbNumInports(block, applyStatus)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    % --- Set the field index numbers
    des_setfieldindexnumbers(block);
return;

%*********************************************************************
% Function Name:    cbDataStoreOption
% Description:      Update the number of ports to match the mask value
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function cbDataStoreOption(block, applyStatus)
    % --- Field data
    Vals = get_param(block, 'maskvalues');
    Vis = get_param(block, 'maskvisibilities');

    % --- Set the field index numbers
    des_setfieldindexnumbers(block);

    DataPointsLimit = Vals{idxDataStoreOption};
    switch DataPointsLimit,
    case 'Limited',
    	[Vis{[idxDataPointsLimit]}]  = deal('on');
    otherwise,
    	[Vis{[idxDataPointsLimit]}]  = deal('off');
    end

    set_param(block, 'MaskVisibilities', Vis);

return;

%*********************************************************************
% Function Name:    getWorkspaceVarsAsStruct
% Description:      pack workspace variables into a struct
% Inputs:           current block, Value, Visibility cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function s = getWorkspaceVarsAsStruct(blk)
% Get mask workspace variables:

ss = get_param(blk,'maskwsvariables');

% Only the first "numdlg" variables are from dialog;
% others are created in the mask init fcn itself.
dlg = get_param(blk,'masknames');
numdlg = length(dlg);
ss = ss(1:numdlg);

% Create a structure with:
%   field names  = variable names
%   field values = variable values
s = cell2struct({ss.Value}',{ss.Name}',1);

% --------------------------------------------------------------------
function paramChanged = hasRelevantParamChanged(block, old_data, new_data)
% Determine if a relevant field has changed. 
des_setfieldindexnumbers(block);

paramChanged = 0;
param_names = fieldnames(old_data);
    
% Irrelevant parameters
paramIrrel = [];

for i=1:length(param_names),
    newParam = getfield(new_data,param_names{i});
    oldParam = getfield(old_data,param_names{i});
    
    if ~isempty(find(paramIrrel == i)),
        continue;
    end
  
    if ischar(newParam),
    	if ~strcmp(newParam,oldParam),
    		paramChanged = 1;
    		return;
    	end
    else        
    	if newParam ~= oldParam,
    		paramChanged = 1;
    		return;
    	end
    end
end

% --- end of des_scopemask.m
