function [childPath childName] = des_getchildblockname(block)
% des_getchildblockname: returns child block and block name for DES blocks
%
% Return Values:    childPath - full path to DES child block
%                   childName - just the DES child block name

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/11/23 20:28:10 $


childPath = find_system(block,'LookUnderMasks','all', ...
                    'FollowLinks','on', ...
                    'RightPortType','desPortOut', ...
                    'LeftPortType','desPortIn');

if length(childPath) > 1,
        error ([des_getproductname ': Multiple Physmod Blocks in DES Block'], ...
            ['Multiple PhysMod blocks are inside ' block '.  Replace this block with one from the library.']);
end
if length(childPath) < 1,
        error ([des_getproductname ': No Physmod Blocks in DES Block'], ...
            ['No PhysMod blocks are inside ' block '.  Replace this block with one from the library.']);
end
childPath = childPath{1};

childName= get_param(childPath,'name'); 

return;