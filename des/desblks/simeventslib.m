function simeventslib(varargin)
%SIMEVENTSLIB Display the SimEvents library.

%   Copyright 2003-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2007/11/07 18:24:12 $

des_error('DES_Internal_Error',nargchk(0,1,nargin));

if (nargin == 0)
   v = '2';
else
   v = varargin{1};    
end;

if ischar(v)
	vs = v;
elseif isnumeric(v)
	vs = num2str(double(v));
else
	des_error('DES_Internal_Error', ...
		'The SimEvents version number must be a string or numeric value.');
end;

switch vs
case {'1', '1.0'}
   vs = '1';
case {'2', '1.0'}
   vs = '2';
otherwise
    des_error('DES_Internal_Error',['Unknown version of SimEvents.']);
end;

% Attempt to open library:
model = ['simeventsv' vs];
try
   open_system(model);
catch
   des_error('DES_Internal_Error',['Could not find SimEvents version ',...
           vs ' (' model '.mdl).']);
end

% [EOF]
