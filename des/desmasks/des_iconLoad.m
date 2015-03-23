function img = des_iconLoad(name)
%PMICONLOAD. Redirects calls to imread with access to private.
%   This function just runs imread for us.  We don't call
%   imread directly because we want the icons to be hidden
%   in the private directory and to make them accessible 
%   they must be called from a file in the directory above
%   private.

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/23 20:28:13 $

name = which(name);
img  = imread(name);
