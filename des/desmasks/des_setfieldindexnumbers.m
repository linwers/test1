function des_setfieldindexnumbers(block)
% DES_SETFIELDINDEXNUMBERS Set index numbers in the callers workspace.
%
%   The field numbers will have the same name (and case) as the mask variable 
%   names, BUT they will have their first initial capitalized and preceded 
%   by 'idx'. For example a Dialog variable 'fooBar' creates an index                    
%   called 'idxFooBar'                                                         

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2005/02/15 15:01:06 $

    evalStr1 = '';
   
    MN = get_param(block,'MaskNames');

    for n=1:length(MN)
        varName  = [upper(MN{n}(1)) MN{n}(2:end)];
        evalStr1 = [evalStr1 sprintf('idx%s = %d;', varName, n)];
    end;
    
    evalin('caller',evalStr1);

return;
