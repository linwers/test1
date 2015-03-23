function [] = des_addEngineEventListeners(mdl_handle)
% This is a helper funciton that adds the event listeners in SimEvents for Simulink engine events.

% Copyright 2006 The MathWorks, Inc.

add_engine_event_listener(mdl_handle,'EngineCompPassed',@des_endOfMdlCompilePassed);
add_engine_event_listener(mdl_handle,'EngineCompFailed',@des_endOfMdlCompileFailed);
add_engine_event_listener(mdl_handle,'EngineSimStatusStopped',@des_simStatusStopped);