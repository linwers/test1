function des_first_use_warning(Block)
% DES_FIRST_USE_WARNING creates the first use warning for Simevents blocks
% 
% Parameters
% Block: name or handle of the block for which there is a first use warning
% Currently first use warnings are created for the following blocks 
% when considering pending entity definition change, pe, only if the 
% parameter is enabled:
% - Single Server
% - N-Server
% - Infinite Server
% - Event-Based Entity Generator
% - Time-Based Entity Generator
% - Output Switch
%
% Currently first use warnings are created for the following blocks 
% when considering number of pending entities definition change, #pe, 
% only if the parameter is enabled:
% - N-Server
% - Infinite Server

%   Copyright 1998-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 04:48:26 $

% NOTE: we may need to pass action into this function in the future if we
% want to generate warnings based on advanced knowledge of the callback
% action we are performing. 

 % Assumption1: 'StatPendingEntity' and 'StatNumberPending' are the param 
 %			    names for all the blocks in these cases respecively
 % Assumption2: 'StatPendingEntity' is the only thing needed to 
 %				compare for Output switch with buffer because the 
 %		        the block sets the param to off when buffering is 
 %              disabled. !!

BlockType = get_param(Block,'MaskType');
BlockName = get_param(Block,'name');
BlockPath = [get_param(Block,'parent') '/' BlockName];
BlockPath = strrep(BlockPath,char(10),' ');
BlockPath = strrep(BlockPath,char(13),' ');
BlockPathLink = strrep(BlockPath,'//','/');

% Create relevant data for PendingEntityDefinitionChange
% do nothing if pending entity is not enabled.  
if ~isempty(intersect(BlockType,{'Event-Based Entity Generator', ...
		'Time-Based Entity Generator', 'Output Switch', ...
		'Single Server','N-Server','Infinite Server'})) ...
	 && ~strcmp(get_param(Block,'StatPendingEntity'),'Off')
 
	% populate the MsgInfo struct
	MsgInfo.DocCommand = ['matlab:helpview(fullfile(docroot,''toolbox'',' ...
		 '''simevents'',''helptargets.map''),''pe_change_r2010a'');'];
	MsgInfo.WarnName = 'PendingEntityDefinitionChange';
	MsgInfo.Format = ['The behavior of the pe signal in the ' ...
		'<a href="matlab:hilite_system(''%s'',''find'')">%s</a> ' ...
		'block has changed'];
	MsgInfo.Message = sprintf(MsgInfo.Format, BlockPath, BlockPathLink);
	MsgInfo.BeforeLink = 'For details, see the';
	MsgInfo.HighlightedLink = 'R2010a section';
	MsgInfo.AfterLink = 'of the SimEvents Release Notes';
	MsgInfo.PrefCategory = 'simevents_firstuse';
	MsgInfo.PrefName = MsgInfo.WarnName;
	 
	des_throw_first_use_warning(MsgInfo);
end

% Create relevant data for NumberPendingEntitiesDefinitionChange
% do nothing if number of pending entities is not enabled.  
if ~isempty(intersect(BlockType,{'N-Server','Infinite Server'})) ...
	&& ~strcmp(get_param(Block,'StatNumberPending'),'Off')

	% populate the MsgInfo struct
	MsgInfo.DocCommand = ['matlab:helpview(fullfile(docroot,''toolbox'',' ... 
		'''simevents'',''helptargets.map''),''num_pe_change_r2010a'');'];
	MsgInfo.WarnName = 'NumberPendingEntitiesDefinitionChange';
	MsgInfo.Format = ['The behavior of the #pe signal in the ' ...
		'<a href="matlab:hilite_system(''%s'',''find'')">%s</a> ' ...
		'block has changed'];
	MsgInfo.Message = sprintf(MsgInfo.Format, BlockPath, BlockPathLink);
	MsgInfo.BeforeLink = 'For details, see the';
	MsgInfo.HighlightedLink = 'R2010a section';
	MsgInfo.AfterLink = 'of the SimEvents Release Notes';
	MsgInfo.PrefCategory = 'simevents_firstuse';
	MsgInfo.PrefName = MsgInfo.WarnName;

	des_throw_first_use_warning(MsgInfo);
end


function des_throw_first_use_warning(MsgInfo)
% DES_THROW_FIRST_USE_WARNING throws a first use warning based on
% information in MsgInfo
%
% Parameters:
% MsgInfo is a struct with the following parameters to allow messages
% according to WaringFormat (see below in code) to be created.
% MsgInfo fields:
% 	  Message          Main message of warning - i.e. first sentence
% 	  BeforeLink       Text before highlighted link in second sentence
% 	  HighlightedLink  Highlighted link in second sentence
% 	  AfterLink        Text after highlighted link in second sentence
% 	  DocCommand       Documentation Command - i.e. link to doc section
% 	  WarningID        ID for MATLAB warning system

% check value of the preference for MsgInfo.PrefCategory, MsgInfo.PrefField
preference = getpref(MsgInfo.PrefCategory,MsgInfo.PrefName,'on');
if strcmp(preference, 'off')
	return;
end
	
% set the warning format
WarningFormat = ...
	['%s.  %s <a href="%s">%s</a> %s.  ' ...
	'<a href="%s">Click here</a> '...
	'if you do not want to see this message again.' ];

% build disabling command
DisablingCommand = ...
	sprintf('matlab:setpref(''%s'',''%s'',''off'')', ...
			 MsgInfo.PrefCategory, MsgInfo.PrefName);

% substitute strings in warning format
WarningDescription = sprintf(WarningFormat, ...
						  MsgInfo.Message, ...
						  MsgInfo.BeforeLink, ...
						  MsgInfo.DocCommand, ...
						  MsgInfo.HighlightedLink, ...
						  MsgInfo.AfterLink, ...
						  DisablingCommand);

% throw warning					  
des_warning(MsgInfo.WarnName,WarningDescription);


