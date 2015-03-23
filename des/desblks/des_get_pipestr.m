function str = des_get_pipestr(pipestr, pos, extendFlag)
% GET_PIPESTR(PIPESTR, POS) returns the POS'th string from pipe-delimited
%   string PIPESTR.  If POS exceeds the number of strings in the PIPESTR,
%   an error is returned.
%
% GET_PIPESTR(PIPESTR, POS, 1) returns an empty string if POS exceeds the
%   number of strings in PIPESTR.

% Copyright 1995-2005 The MathWorks, Inc.
% $ $  $ $

des_error('DES_InvalidArg', nargchk(2,3,nargin));
if nargin<3, extendFlag=0; end

if ~ischar(pipestr),
   des_error('DES_InvalidArg','Input must be a string.');
end
if pos<1,
   des_error('DES_InvalidArg','Invalid index specified.');
end

c = cellpipe(pipestr);

if pos > length(c),
   if ~extendFlag,
      des_error('DES_InvalidArg','Index exceeds number of entries in pipe-delimited string.');
   end
   str='';
else
   str=c{pos};
end

