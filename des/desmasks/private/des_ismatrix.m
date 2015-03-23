function ecode = des_ismatrix(Vec)
% DES_ISMATRIX - returns 1 for matrix inputs.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/23 20:29:16 $

   if(ndims(Vec) == 2)
      if(all([size(Vec,1)>1 size(Vec,2)>1]))
         ecode = logical(1); % Matrix
      else
         ecode = logical(0);
      end;
   else
      ecode = logical(1);
   end;
return;