function html = simeventsbhelp(fileStr)
% SIMEVENTSBHELP  Get URL for SimEvents online help.
%
%   SIMEVENTSBHELP returns the URL of the HTML help file corresponding to
%   the current SimEvents block.  To do this, the function
%   queries the current block for its MaskType.
%
%   SIMEVENTSBHELP(FNAME) returns the URL for online help when the
%   string FNAME is a filename without the .html extension. 
%
%   Typical usage:
%      set_param(gcb,'MaskHelp','helpview(simeventsbhelp);');

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.11 $ $Date: 2009/09/28 20:17:51 $

des_error('DES_Internal_Error',nargchk(0,1,nargin));

d = docroot;

if nargin < 1
  % Derive help file name from mask type:
  html_file = getblock_help_file(gcb);
else
  % Derive help file name from fileStr argument:
  html_file = help_name(fileStr);
end

% Path to html file
html = fullfile(d,'toolbox','simevents','ref',html_file);
html=strrep(html,'\','/'); % To be safe, replace any backslashes
   
if isempty(d),
   des_error('DES_Internal_Error',['Help system is unavailable.  Try using the ',...
           'Web-based documentation set at http://www.mathworks.com']);
end
return

% --------------------------------------------------------
function help_file = getblock_help_file(blk)

% List of libraries in latest version
libsvcur = listoflibraries('simeventsv2'); % Current libraries
linkStatus = lower(get_param(blk,'LinkStatus'));
isConnPort = false; % PhysMod Connection Port - Entity port is an exception

switch linkStatus
   case 'resolved'
      % E.g., a block in a model with library link intact 
      rblock = get_param(blk,'ReferenceBlock');
      sys = get_param(rblock,'Parent');
   case 'inactive'
      % E.g., a block in a model with library link disabled 
      rblock = get_param(blk,'AncestorBlock');
      sys = get_param(rblock,'Parent');
   case {'none','implicit'}
      userdata = get_param(blk,'UserData');
      if isfield(userdata,'BlockType') || isequal(get_param(blk,'BlockType'), 'PMIOPort')
         % Blocks in SimEvents Ports and Subsystems library are not linked
         % to the library but most of them have BlockType set.
         if isfield(userdata,'BlockType') 
             blktype = userdata.BlockType;
         else % The Conn block does not have BlockType.
              % We have to assign blktype to it this way
             blktype = 'Conn'; 
         end
         
         if isequal(blktype,'DESinport') || ...
            isequal(blktype,'DESoutport') || ...
            isequal(blktype,'DESsubsystem') || ...
            isequal(blktype,'DESconfig') || ...
            isequal(blktype,'Conn')
        
            sys = 'simeventsportsubsys1';
            if isequal(blktype,'Conn')
                isConnPort = true;
            end
            
         end
      else        
         % E.g., a block in its library
         sys = get_param(blk,'Parent');
      end
   otherwise
      % E.g., could be a broken link
      des_error('DES_Internal_Error','Unknown link status reported.');
end

% Check whether library or its parent is part of the product's latest version.
if ~any(strcmp(sys,libsvcur)) && ~any(strcmp(get_param(sys,'Parent'),libsvcur))
   if (isequal(sys,'simeventsattributes1') || ...
         isequal(get_param(sys,'Parent'),'simeventsattributes1'))
      % For old attribute blocks, use mask type but append 'obsolete' to
      % match title of help page.
      fileStr = [get_param(blk,'MaskType') 'obsolete'];
   else
      % Not a block for which online help is available
      %fileStr = 'simeventsbhelp_old';
     des_error('DES_Internal_Error','Help is unavailable because the block is from an unknown library.');
   end
   
else
   % Online help available
   
   % Note: Only masked blocks call this fcn, so if
   % we get here, we know we can get the MaskType string.
   if(~isConnPort)
       fileStr = get_param(blk,'MaskType');
   else
       fileStr = 'Conn';
   end
end

help_file = help_name(fileStr);

return


% ---------------------------------------------------------
function y = help_name(x)
% Returns proper help-file name
%
% Invoke same naming convention as used with the
% automatic help conversions for the online doc.
%
% - only allow a-z, 0-9, and underscore

if isempty(x), x='default'; end
y = lower(x);
y(~isvalidchar(y)) = '';  % Remove invalid characters
y = [y '.html'];

return


% ---------------------------------------------------------
function y = isvalidchar(x)
y = isletter(x) | isdigit(x) | isunder(x);
return


% ---------------------------------------------------------
function y = isdigit(x)
y = (x>='0' & x<='9');
return


% ---------------------------------------------------------
function y = isunder(x)
y = (x=='_');
return


% ---------------------------------------------------------
function libsvcur = listoflibraries(mdlfilename)
load_system(mdlfilename);
blks=find_system(mdlfilename,'SearchDepth',1,'Type','block');
libsvcur = get_param(blks,'OpenFcn');

% [EOF]
