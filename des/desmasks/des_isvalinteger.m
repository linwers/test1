function isInt = des_isvalinteger(Vec)
%DES_ISVALINTEGER Check elements of a vector or matrix to be integer-valued.

%   Copyright 1996-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/23 20:28:20 $

isInt =  isreal(Vec(:)) && all( Vec(:) == floor(Vec(:)) );
return;

% [EOF]
