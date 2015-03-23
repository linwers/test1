function des_activateCmdWin
% DES_ACTIVATECMDWIN Activate MATLAB command window if Java desktop is
% being used
%
%    DES_ACTIVATECMDWIN will activate and bring into focus, the MATLAB
%    command window provided that the Java desktop is being used.


if usejava('desktop')
    com.mathworks.mde.desk.MLDesktop.getInstance.activate;
end

% [eof]
