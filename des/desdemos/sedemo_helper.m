function sedemo_helper(blocks, action )
% DES_SUPPORT Provides support for DES blocks dialogs.  It allows for the
% development of responses to block callback functions. 
% Parameters
% BLOCKS  - is a handle to the block that called the callback.
% ACTION - is a string that determines what action to perform.  
%
% Includes a convenient API for programmatically opening and closing scopes.
% This is helpful in managing 'published' demos. This API is documented
% here and within the code below.
%
% For opening the scope ...
%		SEDEMO_HELPER(SYSID, 'OpenFig)
%
% For closing the scope...
%		SEDEMO_HELPER(SYSID, 'CloseFig')
%
% For autoscaling the scope ...
%		SEDEMO_HELPER(SYSID, 'AutoscaleFig')
%
% SYSID can be a scalar or 1-D vector of block handles or 
% a block name (string) or 1-D cell array of block names.
% Each element of SYSID can be a block, subsystem or model name.  
% SEDEMO_HELPER iterates through each elements of SYSID and, for each 
% element, it finds the des scope blocks under the element and performs 
% the action specified by ACTION to that block. 

%   Copyright 1998-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/06/13 15:14:55 $

% Determine block handle
if (nargin < 2) 
     des_error('DES_Illegal_Num_Param',[mfilename ' requires 2 or more arguments.'])
end

error_message = [mfilename ': ''blocks'' parameter needs to be a block' ...
			' name or a 1-D cell array of block names or a block handle ' ...
			' or a 1-D vector of block handles.'];

% process based on type of blocks
if iscell(blocks)
	% Cell array of block names
	if ~ischar(blocks{1})
		des_error('DES_Illegal_Param',error_message);
	end
	if size(blocks,1) == 1
		blocks = blocks';
	end
    for idx = 1:size(blocks,1) 
    	h_demo_helper(blocks{idx}, action);	    
    end
elseif ~ischar(blocks)
	% block handles 
	if size(blocks,1) == 1
		blocks = blocks';
	end
    for idx = 1:size(blocks,1) 
		check_is_block(blocks(idx), error_message);
		h_demo_helper(blocks(idx), action);
    end
else
	% single string
	check_is_block(blocks,error_message);
	h_demo_helper(blocks, action);	    
end



%*********************************************************************
% Function Name:    h_demo_helper
% Description:      performs action specified to help with demo operations
% Inputs:           block - block to do the action for
%                   varargin - list of search parameters (a la find_system)
%                    
% Return Values:    found_blocks, cell array of blocks found
%********************************************************************
function found_blocks = h_demo_helper(block, action)

% get info from the block
hBlk = get_param(block, 'Handle');
blkName = getfullname(hBlk);

% Find blocks using children characteristics
found_blocks = h_find_by_child_param(blkName,  'regexp','on', ...
								'subclassname','DES_SCOPE');
% process based on type of found_blocks
if iscell(found_blocks)
	% cell array of strings
    for idx = 1:size(found_blocks,1) 
    	h_perform_action(action, found_blocks{idx});	    
    end
elseif ~ischar(found_blocks)
	% array or scalar of handles
    for idx = 1:size(found_blocks,1) 
    	h_perform_action(action, found_blocks(idx));	    
    end
else
	% single string
    h_perform_action(action, found_blocks);	    
end

% end of --- sedemo_helper


%*********************************************************************
% Function Name:    h_find_by_child_param
% Description:      performs action specified to help with demo operations
% Inputs:           block - block to do the action for
%                   varargin - list of search parameters (a la find_system)
%                    
% Return Values:    found_blocks, cell array of blocks found
%********************************************************************
function found_blocks = h_find_by_child_param(block, varargin)

% Find blocks using children characteristics
found_children = find_system(block, 'LookUnderMasks','all',  ...
									'FollowLinks', 'on', ...
									varargin{:});
found_phndl = get_param(get_param(found_children,'parent'),'handle');		
found_blocks = getfullname(cell2mat(found_phndl));

%*********************************************************************
% Function Name:    h_perform_action
% Description:      performs action specified to help with demo operations
% Inputs:           action - action to be performed
%                       'OpenFig'
%                       'CloseFig'
%                   block - block to do the action for
%                    
% Return Values:    none
%********************************************************************
function h_perform_action(action, block)

% command line options. useful for managing scopes in demos.
switch (action),

	% Programmatic way to open/close scopes  
	case {'OpenFig', 'CloseFig'}      
		call_desblock_callback('des_scope2', ...
			'ScopeUpdate', block, action);

	% Programmatic way to autoscale scopes 
	case 'AutoscaleFig'      
		call_desblock_callback('des_scope2', ...
			'ScopeUpdate', block, 'DesAutoscale');

	otherwise
		des_error('DES_Illegal_Parameter', ...
			['Illegal value for action, ''' action ...
				''', in sedemo_helper call from ''' block '''.']);

end
%*********************************************************************
% Function Name:     call_desblock_callback
% Description:       calls scope callbacks if necessary
% Inputs:            current block .
% Return Values:     none
%********************************************************************
function call_desblock_callback(filename,fcnName,varargin)
     
feval(filename,[],[],[],fcnName,varargin{:});    

%*********************************************************************
% Function Name:    check_is_block
% Description:      checks if block is a block
% Inputs:           block - block to check
%                   error message
%                    
% Return Values:    none
%********************************************************************
function check_is_block(block, error_message)
try
	get_param(block,'name');
catch
	des_error('DES_Illegal_Param',error_message);
end

% EOF --- sedemo_helper
