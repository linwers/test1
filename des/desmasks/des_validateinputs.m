function valid = des_validateinputs(block, maskParamCheck)
% DES_VALIDATEINPUTS Validates the input parameters structure against the
% criteria specified by the user. This file helps the initialization (init)
% routine in the des_<blockname>mask.m file so that data type and range
% error checking is done before applying the changes made in the mask
% dialog. This function one of the DES functions for checking mask dialog
% errors.
% NOTE: Do not call this function directly.  It needs to be called from the
% des_<blockname>mask function
% 
% Input Arguments: 
% block          - current block name
% maskParamCheck - Cell array of structures (or array of structures) each
%                  with one or more of the following fields depending on
%                  the case:
% 
%                  Case 1: For numeric data checks specify the following
%                  three fields:
%                  (i)Numeric: This field value should exactly match the
%                  idx parameter created by des_setallfieldvalues. The name
%                  of this field will indicate the subroutine to be
%                  executed. This subroutine will key on the isValid and
%                  inRange fields of the maskParamCheck structure to
%                  validate a numeric parameter for a specific data
%                  type(int or real) and range. When you choose 'Numeric' as
%                  the field name for the structure elements, you have to
%                  specify the corresponding 'isValid' and 'inRange'
%                  options appropriately.
%                  (ii)isValid: The field isValid should be set to one of
%                  the options provided in the function des_isvalidnumber.
%                  Current options are 'IsInt' and 'IsReal'
%                  (iii)inRange: The field isRange should be set to a vector
%                  of two elements specifying the lower and the upper limit
%                  of the range in that order. Note that +Inf or -Inf are
%                  valid arguments
%                  (iii)checkTiming: The field checkTiming should be set to
%                  One of the options: 'DlgApply'or 'CompileTime'. DlgApply
%                  indicates that this parameter will be validated anytime
%                  the function from the Initialization pane of the mask
%                  editor is called. 'CompileTime' setting indicates that
%                  this parameter value will be validated only when the
%                  SimulationStatus is one of the following:
%                  {'initializing';'running';'updating'}; 
%                  See des_outputswitchmask.m for an example.
% 
%                  Case 2: For character string data checks specify the
%                  following field:
%                  (i)CharString: This field value should exactly match
%                  the idx parameter created by des_setallfieldvalues. The
%                  name of this field will indicate the subroutine to be
%                  executed. This subroutine will key only on the
%                  CharString field of the maskParamCheck structure to get
%                  the parameter values in the form of strings. The strings
%                  will be validated using the ISVARNAME function. The
%                  structures in maskParamCheck can have only one field
%                  i.e. CharString
%                  
%                  Case 3: For a cell array of strings specify the
%                  following field:
%                  (i)UniqueCharCellArray: This field value should exactly
%                  match the idx parameter created by
%                  des_setallfieldvalues. The name of this field will
%                  indicate the subroutine to be executed. This subroutine
%                  will key only on the UniqueCharCellArray field of the
%                  maskParamCheck structure to get the parameter values in
%                  the form of a cell array of strings. The strings will
%                  be validated using the UNIQUE function.The structures in
%                  maskParamCheck can have only one field i.e.
%                  UniqueCharCellArray
%                  NOTE: The check for valid character strings is built in
%                  the UniqueCharCellArray subroutine.
%  
% Return Values: 
% valid          - boolean indicating the success(1) or failure(0)
%
% Examples:
% 1. Check for only numeric data:
% Create the array of structures with the necessary fields:
% MaskParamCheck = struct('Numeric', {idxNumInPorts, idxPriority, idxRanSeed}, ...
%                         'isValid',  {'IsInt',       'IsInt',     'IsInt'   }, ...
%                         'inRange',  {[1 4],         [1 Inf],     [0 Inf]   });                
% Pass the MaskParamCheck array of structures to the error checking
% sub-function
% valid = des_validateinputs(block, MaskParamCheck)
%  
% 2. Check for only character strings:
% Create the array of structures with the necessary fields:
% MaskParamCheck = struct('CharString', {idxAttribName1, 
%                                        idxAttribName2, 
%                                        idxAttribName3, 
%                                        idxAttribName4});
% Pass the MaskParamCheck array of structures to the error checking
% sub-function
% valid = des_validateinputs(block, MaskParamCheck);
% 
% 3. Check for a Unique set of character strings:
% NOTE: The check for valid character strings is built in the
% UniqueCharCellArray subroutine.
% Create the array of structures with the necessary fields:
% MaskParamCheck = struct('UniqueCharCellArray', {idxAttribName1, 
%                                                 idxAttribName2, 
%                                                 idxAttribName3, 
%                                                 idxAttribName4});
% Pass the MaskParamCheck array of structures to the error checking
% sub-function
% valid = des_validateinputs(block, MaskParamCheck);
% 3. Check for a Unique set of character strings for one set of parameters
% and check for only numeric data for another set of parameters
% Create the cell array where each element is an array of structures with
% the necessary fields:
% MaskParamCheck{1} = struct('UniqueCharCellArray', {idxAttribName1, 
%                                                    idxAttribName2, 
%                                                    idxAttribName3, 
%                                                    idxAttribName4});
% MaskParamCheck{2} = struct('Numeric', {idxNumInPorts, idxPriority, idxRanSeed}, ...
%                         'isValid',  {'IsInt',       'IsInt',     'IsInt'   }, ...
%                         'inRange',  {[1 4],         [1 Inf],     [0 Inf]});                
% 
% Pass the MaskParamCheck cell array to the error checking sub-function
% valid = des_validateinputs(block, MaskParamCheck);

%   Copyright 1996-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2008/12/04 22:28:25 $
   
% Early return for empty maskParamCheck
if(isempty(maskParamCheck))
    valid = 1;
    return;
end

% Convert maskParamCheck into a cell array if it isn't
if(~iscell(maskParamCheck))
    maskParamCheck = {maskParamCheck};
end
msg = {};

% --- Field data
% --- Set the field index numbers
des_setfieldindexnumbers(block);
% Initialize the validity array
paramsValid = ones(length(maskParamCheck), 1);

% Cell Array of all the options:
OptCellArray = {'Numeric';'CharString';'UniqueCharCellArray'};
for count = 1:length(maskParamCheck)
    opt{count} = char(intersect(OptCellArray, fieldnames(maskParamCheck{count})));
    %*********************************************************************
    % --- Action switch -- 
    %*********************************************************************
    switch opt{count}
        case 'Numeric',
            [paramsValid(count) msg{count}] = cbNumeric(block, maskParamCheck{count});
        case 'CharString',
            [paramsValid(count) msg{count}] = cbCharString(block, maskParamCheck{count});
        case 'UniqueCharCellArray',
            [paramsValid(count) msg{count}] = cbUniqueCharCellArray(block, maskParamCheck{count});
        otherwise
             des_mask_error(block, 'DES_InvalidParameter', 'Invalid option for des_validateinputs');
    end
end

if(~all(paramsValid))
    errorIdx = find(~paramsValid);    
    valid = 0;
    for count3 = 1:length(errorIdx)
        %Throw an error through a modal error dialog
        finalMsg{count3} = msg{errorIdx(count3)};
        finalMsgId{count3} = ['DES_MASK_' opt{errorIdx(count3)}];
    end
    des_throwerror(block, finalMsg, finalMsgId);
else
    valid = 1;
    %do nothing: every parameter is valid and in the specified range.
end
return

%*********************************************************************
% Function Name:    cbNumeric
% Description:      Deal with the different Attribute Source modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function [valid msgNumeric] = cbNumeric(block, NumericParamCheck)

MaskWSVar = get_param(block, 'maskwsvariables');
Prompts = get_param(block,'MaskPrompts');
En = get_param(block,'MaskEnables');
MaskValues = get_param(block, 'MaskValues');

msgNumeric = [];
isValid = ones(length(NumericParamCheck),1);
inRange = ones(length(NumericParamCheck),1);

for count1 = 1:length(NumericParamCheck)
    idxParam = NumericParamCheck(count1).Numeric;
    
    % use the checkTiming field if it exists
    if(isfield(NumericParamCheck,'checkTiming'))
        % the field exists - use the option from the struct
        checkTimingOpt = NumericParamCheck(count1).checkTiming;
    else
        % set default option
        checkTimingOpt = 'CompileTime';
    end

    if(strcmp('on', En{idxParam}))
        % use the checkTiming field if it exists
        if(strcmp(checkTimingOpt,'CompileTime'))
            SimStatusWithErrorChecking = {'initializing';'running';'updating'};
            %return if the simulation status does not need error checking
            if(isempty(intersect(SimStatusWithErrorChecking,get_param(bdroot(block),'simulationstatus'))))
                isValid(count1) = 1; 
                msgValid{count1} = '';
                inRange(count1) = 1; 
                msgRange{count1} = '';
                continue;
            end
            % get the value from the MaskWSVariables parameter
            ParamValue = MaskWSVar(idxParam).Value;
        else
            % get the value from the str2double command
            ParamValue = str2double(MaskValues{idxParam});
        end       

        % Remove the colon at the end of the prompt if necessary
        if(Prompts{idxParam}(end)==':')
            ParamPrompt{count1} = Prompts{idxParam}(1:end-1);
        else
            ParamPrompt{count1} = Prompts{idxParam};
        end
        % Check if the input is a valid scalar number:
        %  1. Not a string
        %  2. Is scalar
        %  3. Not a NaN
        %  4. Not empty
        %  5. Is an integer or real depending on the option chosen
        [isValid(count1) msgValid{count1}] = des_isvalidnumber(ParamValue, NumericParamCheck(count1).isValid);
        % Check if the input lies in the specified range:
        if(isfield(NumericParamCheck,'rangeOpt'))
            rangeOpt = NumericParamCheck(count1).rangeOpt;
        else
            rangeOpt = 'closeboth';
        end
        [inRange(count1) msgRange{count1}] = des_isinrange(ParamValue, ParamPrompt{count1}, NumericParamCheck(count1).inRange, rangeOpt);
    end
end

% Enter the error handling routine if an input parameter is not a valid
% number or not in the specified range
valid = all(isValid)& all(inRange);
if(~valid)
    errorValidIdx = find(~isValid);    
    errorRangeIdx = find(~inRange);
    errorIdx = union(errorValidIdx, errorRangeIdx);
    for count2 = 1:length(errorIdx)
        % Create an error message that conveys the necessary conditions on
        % the data type and the range
        msgNumeric = [msgNumeric ParamPrompt{errorIdx(count2)} ' ' ...
               msgValid{errorIdx(count2)} ' ' ...
               msgRange{errorIdx(count2)}];
        msgNumeric = [msgNumeric char(10)];
    end
end

%*********************************************************************
% Function Name:    cbCharString
% Description:      Deal with the different Attribute Source modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function [valid msgCharString] = cbCharString(block, StringParamCheck)
MaskWSVar = get_param(block, 'maskwsvariables');
Prompts = get_param(block,'MaskPrompts');
En = get_param(block,'MaskEnables'); 
MaskVals = get_param(block,'MaskValues'); 
msgCharString = [];
isValidVarName = 1;
for count1 = 1:length(StringParamCheck)
    charfieldname = char(fieldnames(StringParamCheck(count1)));
    idxParam = eval(['StringParamCheck(count1).' charfieldname]);
    if(strcmp('off', En{idxParam}))
        isValidVarName(count1) = 1;
        msgValidVarName{count1} = '';
    else
        ParamValue = MaskWSVar(idxParam).Value;
        % Remove the colon at the end of the prompt if necessary
        if(Prompts{idxParam}(end)==':')
            ParamPrompt{count1} = Prompts{idxParam}(1:end-1);
        else
            ParamPrompt{count1} = Prompts{idxParam};
        end
        
        % Remove whitespaces from the front and rear of the string 
        % Write the trimed string into the block
        ParamValue = strtrim(ParamValue); 
        if ~strcmp(MaskVals{idxParam},ParamValue)
            MaskVals{idxParam} = ParamValue;
            set_param(block, 'MaskValues', MaskVals);
        end
        % Do not update MaskWSVariables since it is read only.
        
        % Check if the input is a valid variable name in MATLAB which
        % implies the following checks:
        %  1. Is a character string
        %  2. Does not have any spaces within the string
        %  3. Does not have single quotes as a part of the string
        %  4. Does not have non-alphanumeric characters e.g. @#$% etc
        %  5. Is not empty
        [isValidVarName(count1) msgValidVarName{count1}] = des_isvalidvarname(ParamValue);
    end
end

% Enter the error handling routine if an input parameter is not a valid
% number or not in the specified range
valid = all(isValidVarName);  
if(~valid)
    errorIdx = find(~isValidVarName);    
    for count2 = 1:length(errorIdx)
        % Create an error message that conveys the necessary conditions on
        % the data type
        msgCharString = [msgCharString ParamPrompt{errorIdx(count2)} ' ' ...
                         msgValidVarName{errorIdx(count2)} char(10)];
    end
end

%*********************************************************************
% Function Name:    cbUniqueCharCellArray
% Description:      Deal with the different Attribute Source modes.
% Inputs:           current block, Value, Visibility and Enable cell arrays
% Modified Values:  Modified Value, Visibility and Enable cell arrays
%********************************************************************
function [valid msgUniqueCharCellArray] = cbUniqueCharCellArray(block, UniqueCellParamCheck)
MaskWSVar = get_param(block, 'maskwsvariables');
En = get_param(block,'MaskEnables');
Prompts = get_param(block,'MaskPrompts');

msgUniqueCharCellArray = [];
idxParam =  [UniqueCellParamCheck.UniqueCharCellArray];

% Check for unique names only if the control is enabled:
EnabledState = En(idxParam);
EnabledIdx = find(strcmp('on',EnabledState));

InputCellArray = {MaskWSVar(idxParam(EnabledIdx)).Value};
% --- Check if the cell array contains unique strings:
if(length(unique(InputCellArray))==length(InputCellArray))
    valid = 1;
else
    valid = 0;
end

[validname msgCharString1] = cbCharString(block, UniqueCellParamCheck);

% Enter the error handling routine if an input parameter is not a valid
% number or not in the specified range
if(~valid)     
    % Remove the colon at the end of the prompt if necessary
    if(Prompts{idxParam(1)}(end)==':')
        ParamPrompt = Prompts{idxParam(1)}(1:end-1);
    else
        ParamPrompt{count1} = Prompts{idxParam};
    end   
    msgUniqueCharCellArray = [ParamPrompt 's' ' must be unique'];   
    if(~validname)
        msgUniqueCharCellArray = [msgUniqueCharCellArray char(10) msgCharString1];
    end
else
    if(~validname)
        valid = 0;
        msgUniqueCharCellArray = msgCharString1;
    end
    %do nothing
end

%% ---------------------------------------------------------------    