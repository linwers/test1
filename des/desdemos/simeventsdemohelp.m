function [] = simeventsdemohelp(varargin)
% SIMEVENTSDEMOHELP  Invoke SimEvents demo help.
%
%   SIMEVENTSDEMOHELP finds the arguments for the HELPVIEW function
%   and invokes help for the current demo.
%
%   Typical usage:  
%      simeventsdemohelp; % in a Model Info block in a demo

%   It assumes that the documentation source file contains an
%   anchor whose ID is the name of the system, except for slashes.
%
% Copyright 2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/01/29 15:32:57 $

d = docroot;
if isempty(d)
     des_error('DES_ErrorDocOperation', ['Help system is unavailable.  Try using the ',...
          'Web-based documentation set at http://www.mathworks.com']);
else
    topic=gcs;
    topic(findstr(topic,'/'))=[]; % get rid of slashes in case of subsystems

    if (nargin == 0) || (nargin ==1 && isempty(varargin{1}))
        % No valid input argument, generate path name from topic name
        % automatically.
        if isequal(findstr(topic,'doc_'),1)
            % It's a doc example.
            % Look in consolidated map file for this doc set.
            pathname_doc=fullfile(d,'toolbox','simevents','helptargets.map');
            helpview(pathname_doc,topic);
        else
            % It's a demo model.
            % Build HTML filename directly.
            pathname_html=fullfile(matlabroot,'toolbox','des','desdemos','html',[topic '.html']);
            pathname_m_html=fullfile(matlabroot,'toolbox','des','desdemos','html',[topic '_m.html']);
            pathname_desc_html=fullfile(matlabroot,'toolbox','des','desdemos','html',[topic '_desc.html']);
            if exist(pathname_html,'file')
                helpview(pathname_html);
            else
                if exist(pathname_m_html,'file')
                    helpview(pathname_m_html);
                else
                    if exist(pathname_desc_html,'file')
                        helpview(pathname_desc_html);
                    else
                        des_error('DES_ErrorInfoBlockOperation', ['No help for ',topic,' is available.']);
                    end
                end
            end
        end
    elseif nargin == 1
        % Have explicit file name input for demo model, use input argument
        % to generate path name.
        pathname_m_html = fullfile(matlabroot,'toolbox','des','desdemos','html',[varargin{1} '.html']);
        if exist(pathname_m_html,'file')
            helpview(pathname_m_html);
        else
            des_error('DES_ErrorInfoBlockOperation', ['No help for ',topic,' is available.']);
        end
    else
        des_error('DES_ErrorInfoBlockOperation', 'Invalid number of input arguments.');
    end
end
 
return
