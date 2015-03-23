function makeInfo=rtwmakecfg()
%RTWMAKECFG adds include and source directories to rtw make files.
%  makeInfo=RTWMAKECFG returns a structured array containing
%  following field:
%     makeInfo.includePath - cell array containing additional include
%                            directories. Those directories will be
%                            expanded into include instructions of rtw
%                            generated make files.
%
%     makeInfo.sourcePath  - cell array containing additional source
%                            directories. Those directories will be
%                            expanded into rules of rtw generated make
%                            files.

%       Copyright 1996-2006 The MathWorks, Inc.
%       $Revision: 1.1.6.4 $ $Date: 2009/04/21 03:09:12 $

disp('### Include SimEvents directories : desmex/rtwmakecfg.m');

% TODO: Move the code gen specific api to a ship-able folder above src in
% sldes.

makeInfo.includePath = { ...
                        fullfile(matlabroot,'toolbox','des','desshr','include'),...
                        fullfile(matlabroot,'toolbox','des','sldes','extern'), ...
                        fullfile(matlabroot,'toolbox','des','include')...
                        };
                    
 % Windows host platforms use '.dll' for the dynamic library file extension.
    % All other host platforms use '.so' for the library file extension.
    archStr = computer('arch');
    if (strncmpi(archStr,'win',3))
        makeInfo.linkLibsObjs = {...
                             fullfile(matlabroot, 'lib', archStr,'sldes.lib')}; 
    elseif(strncmpi(archStr,'mac',3))
			makeInfo.linkLibsObjs = {...
							fullfile(matlabroot, 'bin', archStr, 'libmwsldes.dylib')};
		
	else							
        sldes_module = 'libmwsldes.so';
        des_module = 'libmwdes_engine.so';
        makeInfo.linkLibsObjs = {fullfile(matlabroot, 'bin', archStr, sldes_module)...
                                };
    end                            
    
makeInfo.precompile = 1;

    makeInfo.sourcePath = {fullfile(matlabroot,'toolbox','des','sldes','extern')};
    
%     makeInfo.library(1).Name     = 'sldes';
%     makeInfo.library(1).Location = fullfile( matlabroot,'lib', computer('arch') );
%     makeInfo.library(1).Modules  = sldes_module;

% Function: getfilesbytype
% =====================================================
function cellFiles = getfilesbytype(directory, pattern)
% Abstract:
%      Returns a cell array with filenames that maches the 'pattern' (eg. *.c)
%      within the given 'directory' tree.
%      Returns a cell array of directories if the 'pattern' equals 'd'.

cellFiles = {};
if pattern == 'd'
    bDir = 1;
    localPattern = '*';
else
    bDir = 0;
    localPattern = pattern;
end
currDir = pwd;

cd(directory);

if ~bDir
    files = dir(localPattern);
    for i=1:length(files)
        if ~(files(i).isdir)
            cellFiles{end+1} = files(i).name;
        end
    end
end

%% recurse on directories
strDir = dir;
for i=1:length(strDir)
    if strDir(i).isdir & strDir(i).name(1) ~= '.' & strDir(i).name(1) ~= 'CVS'
        if bDir
            cellFiles{end+1} = fullfile(pwd, strDir(i).name);
        end
        tempCell = getfilesbytype(strDir(i).name, pattern);
        cellFiles = {cellFiles{:}, tempCell{:}};
    end
end

cd(currDir);

% [EOF]
