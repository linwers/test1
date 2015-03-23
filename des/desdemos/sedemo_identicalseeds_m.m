%% Avoiding Identical Seeds for Random Number Generators
%

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/06/13 15:14:56 $

%% Overview
%
% Random number generator algorithms permit user-specified initial seed
% values for the generation of random numbers. If two random number
% generators use the same seed, then
% they may generate correlated sequences of "random" numbers even if the
% parameters of their distributions are different.
%
% For a stochastic simulation, this can lead to undesirable correlation
% in the system, and perhaps even incorrect results.
%
% This demo uses an M/M/1 queuing system to show that non-unique seeds can
% lead to incorrect results. It also describes how to avoid such effects. 
% Refer to M/M/1 Queuing Demo for more information about M/M/1 queuing
% systems.

%% Queuing Example
% 
% This model shows a
% single-queue single-server system having a single source of traffic from
% the Time-Based Entity Generator.

oldFormat = get(0, 'format');
format long;

modelname = 'sedemo_identicalseeds';
open_system(modelname);

%% Model Characteristics
% 
% The entity generation rate is a Poisson process with a mean of 2, while
% the service time is an exponential process with a mean of
% 1. The Time-Based Entity Generator and the Event-Based Random Number block
% currently have their seed values set to the same number.

%% Expected Theoretical Results
%
% Queuing theory provides that the expected delay for an M/M/1 queuing
% system is as follows:
% 
% $$T = {1 \over {\mu - \lambda}} = {1 \over {{1 \over Service Rate} - {1 \over Generation Rate}}}$$
% 
% $$T = {1 \over {{1 \over 1} - {1 \over 2}}} = 2$$

%% Simulating with Identical Seeds
%
% Upon simulating the model, we see that the delay for the system
% has a mean of 1, which is different from the expected delay of 2.

sim(modelname);

%%
% Notice that a warning indicates that some blocks use identical seeds.
%
% The function |se_getseeds| retrieves the seeds from a model or a
% subsystem for inspection as shown below.

mySeeds = se_getseeds(modelname)

%%
% The return argument is a structure containing the seed parameters, which
% can be accessed for inspection as:

[{mySeeds.seeds.block}' {mySeeds.seeds.value}']

%% Randomizing Seeds
%
% The function |se_randomizeseeds| randomizes the
% seeds for random number generators in a model or subsystem. This function
% ensures that the new seeds are unique.

se_randomizeseeds(modelname)

%%
% To verify that the seeds are now unique, you
% can use the function |se_getseeds| as follows.

mySeeds = se_getseeds(modelname);
[{mySeeds.seeds.block}' {mySeeds.seeds.value}']

%% Simulating with Unique Seeds
%
% We now simulate the model that now contains unique seed values.

sim(modelname);

%%
% The empirical delay now conforms to the expected
% theoretical result.

%%
format(oldFormat);
clear modelname oldFormat mySeeds

%% Related Demos
% 
% * <matlab:showdemo('sedemo_rngseeds_mgmt_m') Seed Management Workflow for
% Random Number Generators>

%% Reference
%
% [1] Kleinrock L., 'Queuing Systems. Volume 1: Theory', J. Wiley & Sons
% 1975, Canada
bdclose('sedemo_identicalseeds');

displayEndOfDemoMessage(mfilename)
