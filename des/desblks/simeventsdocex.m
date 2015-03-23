function simeventsdocex(mname)
    % SIMEVENTSDOCEX Open SimEvents documentation example model.
    %    SIMEVENTSDOCEX(MNAME) opens the SimEvents documentation example
    %    model MNAME, modifying the MATLAB path if necessary.

    % Copyright 2006-2009 The MathWorks, Inc.
    % $Revision: 1.1.6.5 $  $Date: 2009/09/28 20:17:52 $

    % If doc example models are not on the path, then modify the path.
    if (isempty(which('doc_dd1')))
       % Add path matlabroot\help\toolbox\simevents\...
       addFolderToPath(fullfile(docroot,'toolbox','simevents','examples'));
       addFolderToPath(fullfile(docroot,'toolbox','simevents','examples','ug'));
    end

    % Open the model.
    open(mname);

    % Add the folder to the path.  DOCPATH returns the correct localized
    % path based on the locale.
    function addFolderToPath(folder)
        folder = docpath(folder);
        if (~isempty(folder)) 
            addpath(folder);
        end 
    end
end
