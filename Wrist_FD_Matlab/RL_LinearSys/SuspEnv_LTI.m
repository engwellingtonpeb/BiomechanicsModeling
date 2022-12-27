%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                  Department of Biomedical Engineering                   %
%                                                                         %
%  Author: Wellington Cássio Pinheiro                                     %
%-------------------------------------------------------------------------%
%RL Controlled Active 1/4 car suspensio
clear all
close all hidden
clc


%% Opensim
%Configuring OpenSim Model through API and gathering relevant info
SimuInfo=struct

% episode time
SimuInfo.Ts=.001;
SimuInfo.Tend=7;




%% Environment for RL Training
%Observation Info
obsInfo= rlNumericSpec([4 1]);
obsInfo.Name = 'observation';
obsInfo.Description = 'Zu-Zus, Zudot, Zus-Zr, Zusdot';

%Action Info
actInfo=rlNumericSpec([1], 'LowerLimit', [0],'UpperLimit',[10]);
actInfo.Name = 'action';
actInfo.Description = 'U';


StepHandle=@(Action,LoggedSignals)MyStepFunction(Action,LoggedSignals,SimuInfo,osimModel,osimState)
ResetHandle=@()MyResetFunction(State);

env = rlFunctionEnv(obsInfo,actInfo,StepHandle,ResetHandle)


%% Creating DDPG trained agent

obsInfo = getObservationInfo(env);
numObs = obsInfo.Dimension(1);
actInfo =getActionInfo(env);
numAct = actInfo.Dimension(1);

%CRITIC NETWORK
L = 5; % number of neurons
statePath = [
    featureInputLayer(3,'Normalization','none','Name','observation')
    fullyConnectedLayer(L,'Name','fc1')
    reluLayer('Name','relu1')
    fullyConnectedLayer(L,'Name','fc2')
    additionLayer(2,'Name','add')
    reluLayer('Name','relu2')
    fullyConnectedLayer(L,'Name','fc3')
    reluLayer('Name','relu3')
    fullyConnectedLayer(1,'Name','fc4')];

actionPath = [
    featureInputLayer(2,'Normalization','none','Name','action')
    fullyConnectedLayer(L, 'Name', 'fc5')];

criticNetwork = layerGraph(statePath);
criticNetwork = addLayers(criticNetwork, actionPath);
    
criticNetwork = connectLayers(criticNetwork,'fc5','add/in2');

plot(criticNetwork)

criticOptions = rlRepresentationOptions('LearnRate',1e-3,'GradientThreshold',1,'L2RegularizationFactor',1e-4,'UseDevice',"gpu");

critic = rlQValueRepresentation(criticNetwork,obsInfo,actInfo,...
    'Observation',{'observation'},'Action',{'action'},criticOptions);

% ACTOR


actorNetwork = [
    featureInputLayer(3,'Normalization','none','Name','observation')
    fullyConnectedLayer(L,'Name','fc1')
    reluLayer('Name','relu1')
    fullyConnectedLayer(L,'Name','fc2')
    reluLayer('Name','relu2')
    fullyConnectedLayer(L,'Name','fc3')
    reluLayer('Name','relu3')
    fullyConnectedLayer(2,'Name','fc4')
    tanhLayer('Name','tanh1')
    scalingLayer('Name','ActorScaling1','Scale',(max(actInfo.UpperLimit)),'Bias',.5)];



actorOptions = rlRepresentationOptions('LearnRate',1e-3,'GradientThreshold',1,'L2RegularizationFactor',1e-4,'UseDevice',"gpu");
actor = rlDeterministicActorRepresentation(actorNetwork,obsInfo,actInfo,...
    'Observation',{'observation'},'Action',{'ActorScaling1'},actorOptions);


% 3) DDPG algorithm for learning
     
agentOpts = rlDDPGAgentOptions(...
    'SampleTime',SimuInfo.Ts,...
    'TargetSmoothFactor',1e-1,...
    'ExperienceBufferLength',1e6,...
    'DiscountFactor',0.99,...
    'NumStepsToLookAhead',1,...
    'MiniBatchSize',32);
agentOpts.NoiseOptions.Variance   = .1 ;
agentOpts.NoiseOptions.VarianceDecayRate   = 1e-6;

% effectively creating the agent
agent = rlDDPGAgent(actor,critic,agentOpts);


%% Treinamento

% training the agent 

trainOpts = rlTrainingOptions(...
    'MaxEpisodes', 5000, ...
    'MaxStepsPerEpisode', 2e6, ...
    'Verbose', false, ...
    'Plots','training-progress',...
    'StopTrainingCriteria','AverageReward',...
    'StopTrainingValue',66e6,...
    'UseParallel',0,...
    'SaveAgentCriteria',"EpisodeReward",...
    'SaveAgentValue',1e5,...
    'SaveAgentDirectory', pwd + "\Agents");

trainingStats = train(agent,env,trainOpts);




%%
simOptions = rlSimulationOptions('MaxSteps',200000);
experience = sim(env,agent,simOptions);