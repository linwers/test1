function outpipestr = des_remove_pipestr(inpipestr, pos)
% SET_PIPESTR Sets the POS'th string in pipe delimited input string
%    INPIPESTR to be the string STR.  If the POS'th entry exceeds the
%    number of delimited strings in INPIPESTR, empty strings are
%    appended up to the POS'th position.

% Copyright 1995-2005 The MathWorks, Inc.
% $$  $ $

c=des_cellpipe(inpipestr);
if (pos<1),
   des_error('DES_InvalidArg','Invalid index specified.');
end

if(numel(c)==1)
    outpipestr = '';
    return;
end

if(pos>1)
    c = {c{1:pos-1}, c{pos+1:end}};
else
    c = {c{pos+1:end}};
end
outpipestr = des_cellpipe(c);
