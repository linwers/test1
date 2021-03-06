% SEDEMO_RATEESTIMATOR_TIMEBASEDFCN Helper function for rate estimator demo
%    This helper function disconnects the Function-Call Subsystem block
%    from its event-based function-call generator and connects the block to
%    a time-based function-call generator.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2008/06/13 15:14:58 $

load_system simulink;

add_block('simulink/Ports & Subsystems/Function-Call Generator',...
   ['sedemo_rateestimator_initialdesign/Arrival Rate Estimator/Function-Call   ' char(10) ...
   'Generator'],...
   'sample_time','4','Position','[230 70 275 90]');
delete_line('sedemo_rateestimator_initialdesign/Arrival Rate Estimator',...
   ['Perform Computation' char(10) 'Upon Arrival/1'],...
   ['Arrival Rate Estimation' char(10) 'Computation/Trigger']);
add_line('sedemo_rateestimator_initialdesign/Arrival Rate Estimator','Function-Call    Generator/1',...
   ['Arrival Rate Estimation' char(10) 'Computation/Trigger']);

add_block('simulink/Sinks/Terminator',...
   'sedemo_rateestimator_initialdesign/Arrival Rate Estimator/Terminator',...
   'Position','[180 100 200 120]');
add_line('sedemo_rateestimator_initialdesign/Arrival Rate Estimator',...
   ['Perform Computation' char(10) 'Upon Arrival/1'],...
   'Terminator/1');

% Change title of rate plot.
des_scope_support('CloseFig',...
   ['sedemo_rateestimator_initialdesign/Plot Estimated Rate' char(10) ...
   'of Entity Arrivals']);
set_param(['sedemo_rateestimator_initialdesign/Plot Estimated Rate' char(10) ...
   'of Entity Arrivals'],'Title','Arrival Rate Estimated Periodically');

% No need to repeat switching criterion plot in the published HTML.
set_param('sedemo_rateestimator_initialdesign/Plot Switching Criterion',...
   'OpenScopeAtSimStart','off');
   
% Include screen capture of modified subsystem in the published HTML.
open_system('sedemo_rateestimator_initialdesign/Arrival Rate Estimator','force');