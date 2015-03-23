function varargout = des_cbenableenumports(block, subaction, side, ...
                            portType, portLabelRoot, indexParam)
% DES_CBENABLEENUMPORT callback fcn to make enabling enumerated ports 
%
% DES_CBENABLEENUMPORT is a helper callback file for des mask helper files.  
% It allows efficient setting of the number of ports when called from a mask helper 
% file.  It gets the workspace variable needed to determiee the number of enumerated
% ports from the mask parameter indexed by indexParam, It then passes on the required
% values to des_enableenumport
%
% See mask helpers, des_pathcombiner.m, des_outputswitch.m etc. for caller use.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2007/11/07 18:26:05 $

% --- Workspace variables
WsVar = get_param(block, 'maskwsvariables');

% --- Set the field index numbers
des_setfieldindexnumbers(block);

%des_enableenumport(block, subaction, side, portType, portLabelRoot, numPorts);

% The way we determine the number of ports is currently different for
% Simulink ports and entity ports. The 'Number of entity ports' parameters
% are not evaluated in the mask editor and therefore the value has to be
% determined from the string format. The number of ports for Simulink ports
% on the other hand is evaluated in the mask editor and therefore it is Ok
% to use the mask workspace variables.
% This limitation is a result of the fix for g355705 and g383980. With this
% fix we decided to call the error checking functionality at Dialog Apply
% time for the entity ports. If we ever have a block with variable number
% of Simulink ports whose Number of ports are checked at Dialog Apply time,
% we will need to change the code that determines the numPorts variable:

switch portType,
    case 'SL'
        % signal ports
        % Get the workspace variable for the number of ports
        numPorts = WsVar(indexParam).Value;

        des_enableenumport(block, subaction, side, portType, portLabelRoot, numPorts);
    case 'SE'
        % entity ports
        MaskValues = get_param(block,'MaskValues');
        numPorts = str2double(MaskValues{indexParam});
        des_enableentityport(block, subaction, side, portType, portLabelRoot, numPorts);
         
    otherwise
        des_mask_error(block, 'DES_InvalidParameter', 'Invalid choice for portType in des_enableenumport');
end

return;
