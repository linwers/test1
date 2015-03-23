function setallfieldvalues(block)
%SETALLFIELDVALUES Set field numbers and mask values in the callers workspace.
%
%   The field numbers will have the same name (and case) as the mask variable 
%   names, BUT they will have their first initial capitalized and preceded 
%   by 'idx'. For example a Dialog variable 'fooBar' creates an index                    
%   called 'idxFooBar'                                                         
%                                                              
%   The mask parameter values are set in a similar fashion except that a 
%   mask variable called 'fooBar' will be called 'maskFoobar' in the 
%   callers workspace.                                     

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2004/03/30 13:04:08 $

    evalStr1 = '';
    evalStr2 = '';
    wsStr = get_param(block,'MaskWSVariables');
    
	MN = deal({wsStr.Name});
    
    for n=1:length(MN)
        varName  = [upper(MN{n}(1)) MN{n}(2:end)];
        evalStr1 = [evalStr1 sprintf('idx%s = %d;', varName, n)];
        evalStr2 = [evalStr2 sprintf('assignin(''caller'', ''mask%s'', wsStr(%d).Value);', varName, n)];
    end;
    
    evalin('caller',evalStr1);
    eval(evalStr2);

return;
