function des_first_use_dlg(Block)
% DES_FIRST_USE_DLG creates the first use dialogs upon copying the relevant
% blocks
% 
% Parameters
% Block: Currently first use dialogs are created when copying the
% following three types of blocks:
% - Entity Generators
% - Event Generators
% - Get and Set Attribute blocks

%   Copyright 1998-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2007/08/20 16:26:16 $

BlockType = get_param(Block,'MaskType');
% Create relevant data depending on the BlockType or return
switch BlockType
     case {'Event-Based Entity Generator', 'Time-Based Entity Generator'}
        PrefName = 'EntitiesVsEvents';
        PrefTitle = 'SimEvents Tip: Entities vs. Events';
        DlgDescription = {'Entities are items of interest in a discrete event simulation.'
                          ''
                          'Events are discrete occurrences such as' 
                          'entity generation or entity departures.'};
        Topic = 'entities_vs_events'; 
    case {'Signal-Based Function-Call Event Generator', 'Entity-Based Function-Call Event Generator'}
        PrefName = 'EventsVsEntities';
        PrefTitle = 'SimEvents Tip: Events vs. Entities';
        DlgDescription = {'Events are discrete occurrences such as' 
                          'function calls or entity departures.'
                          ''
                          'Entities are items of interest in a discrete event simulation.'};
        Topic = 'events_vs_entities';                       
    case {'Get Attribute', 'Set Attribute'}
        ParentBlk = get_param(Block,'Parent');
        ModelName = get_param(bdroot(Block),'Name');
        if(isequal(BlockType,'Set Attribute') && ~strcmp(ModelName,ParentBlk) && des_isaAttributeFunction(ParentBlk))
            % This block is inside Attribute Function Block
            % Disable the first use dialog creation for the Set Attribute
            % block since we want to create the first use dialog only once.
            return;
        end
        PrefName = 'Attributes';
        PrefTitle = 'SimEvents Tip: Attributes';
        DlgDescription = {'Attributes are data associated with an entity.' 
                          'Each attribute has a name and a value.'};
        Topic = 'attributes';                                             
    otherwise
        %do nothing
        return;
end

% Create the fist use dialog:
des_create_first_dlg(PrefName, PrefTitle,DlgDescription, Topic);


% Helper function:
function des_create_first_dlg(PrefName, PrefTitle,DlgDescription, Topic)
% Create the dialog:
%value = uigetpref(group,pref,title,question,pref_choices)
        
[selectedButton,dlgShown]=uigetpref('simevents_firstuse',PrefName, PrefTitle, DlgDescription,...
                                    {'OK','Help';'OK', 'Help'},...       % Values and button strings
                                    'DefaultButton');             % Help button
if(strcmp(selectedButton,'help'))
    PathName=fullfile(docroot,'toolbox','simevents','helptargets.map');
    helpview(PathName,Topic) % topic is 'events_vs_entities', etc.    
end
                                
