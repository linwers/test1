function des_setEvaluatedAttributes(block,blkType)
% This function is used by the Get and Set Attribute blocks to keep two
% parameter values in-sync
% This is called from the mask editor callback for the value parameter from
% the Get/Set Attribute blocks.
% AttributeValue and the EvaluatedAttributeValue for Set Attribute
% AttributeDefaultValue and the EvaluatedAttributeDefaultValue for Get Attribute

% Copyright 1995-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/01/20 15:30:06 $

blkhandle = get_param(block,'handle');
 
switch blkType
    case 'GetAttribute'
        attrDefValuesPipe = GetEnabledAttrDefValue(block);
%        blkhandle.EvaluatedDefaultAttributeValue = ['{' strrep(attrDefValuesPipe,'|',';') '}'];
        set_param(blkhandle,'EvaluatedDefaultAttributeValue',['{' strrep(attrDefValuesPipe,'|',';') '}']);
    case 'SetAttribute'
        attrValuesPipe = GetEnabledAttrValue(block);
%        blkhandle.EvaluatedAttributeValue = ['{' strrep(attrValuesPipe,'|',';') '}'];
        set_param(blkhandle,'EvaluatedAttributeValue',['{' strrep(attrValuesPipe,'|',';') '}']);
    otherwise
        des_error('DES_InvalidBlockType','Invalid block type that does not need evaluated attribute values');
end

function attrDefValuesPipe = GetEnabledAttrDefValue(block)
% This function replaces the values for disabled 'default value' fields by
% empty matrices: '[]'. This way these will not be a part of the mask error
% checking.

blkhandle = get_param(block,'handle');
% Guard for empty table
if(strcmp(get_param(blkhandle,'AttributeMissing'),'') || ...
		strcmp(get_param(blkhandle,'AttributeDefaultValue'),''))
    attrDefValuesPipe = '[]';
    return;
end
attrMissing = des_cellpipe(get_param(blkhandle,'AttributeMissing'));
attrVal = des_cellpipe(get_param(blkhandle,'AttributeDefaultValue'));

attrVal(~cellfun(@isempty,strfind(attrMissing,'Error'))) = {'[]'};

attrDefValuesPipe = des_cellpipe(attrVal);


function attrValuesPipe = GetEnabledAttrValue(block)
% This function replaces the values for disabled 'attribute value' fields by
% empty matrices: '[]'. This way these will not be a part of the mask error
% checking.

blkhandle = get_param(block,'handle');
% Guard for empty table - e.g. if the AttrFrom/AttrValue is empty, it implies that
% the table is empty and we don't have any attributes.
if(strcmp(get_param(blkhandle,'AttributeFrom'),'') || ...
		strcmp(get_param(blkhandle,'AttributeValue'),''))
    attrValuesPipe = '[]';
    return;
end
attrFrom = des_cellpipe(get_param(blkhandle,'AttributeFrom'));
attrVal = des_cellpipe(get_param(blkhandle,'AttributeValue'));

attrVal(~cellfun(@isempty,strfind(attrFrom,'Signal port'))) = {'[]'};
attrValuesPipe = des_cellpipe(attrVal);


