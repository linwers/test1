function [] = des_registerSimInstance(mdl_handle)
% This is a helper funciton that register SimEvents simulation instance
% to Simulink engine.

% Copyright 2006 The MathWorks, Inc.

% Make sure SimEvents event listeners are registered prior to attaching
% engine events to them

if (~bdIsLoaded('des_sfun_lib'))
	load_system('des_sfun_lib');
end 
try
    % Attach engine events to SimEvents event listeners
    des_addEngineEventListeners(mdl_handle);
catch
    % Ignore the exception if any. Leave des_setDesSfunPort to try to add
    % engine event listeners a second time.
end