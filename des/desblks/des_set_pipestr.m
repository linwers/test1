function outpipestr = des_set_pipestr(inpipestr, pos, str)
% SET_PIPESTR Sets the POS'th string in pipe delimited input string
%    INPIPESTR to be the string STR.  If the POS'th entry exceeds the
%    number of delimited strings in INPIPESTR, empty strings are
%    appended up to the POS'th position.

% Copyright 1995-2005 The MathWorks, Inc.
% $$  $ $

c=des_cellpipe(inpipestr);
if ~ischar(str),
   des_error('DES_InvalidArg','STR must be a string.');
end
if (pos<1),
   des_error('DES_InvalidArg','Invalid index specified.');
end
c{pos}=str;
outpipestr = des_cellpipe(c);
