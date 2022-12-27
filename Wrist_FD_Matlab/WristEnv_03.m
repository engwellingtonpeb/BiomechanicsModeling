%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                  Department of Biomedical Engineering                   %
%                                                                         %
%  Author: Wellington Cássio Pinheiro                                     %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date:07/03/21                                                          %
%  CPC815 - Physics Based Machine Learning
%-------------------------------------------------------------------------%
%RL Trained Biomechanical Wrist Model
clear all
close all hidden
clc


%% Opensim
%Configuring OpenSim Model through API and gathering relevant info
SimuInfo=struct

% episode time
SimuInfo.Ts=.001;
SimuInfo.Tend=7;
global n;
n=0;
global episode
episode=0;
% setpoint angle of flexion
SimuInfo.PhiRef=0; %degrees



import org.opensim.modeling.*
osimModel=Model('.\models\MoBL_ARMS_tutorial_33\MoBL-ARMS OpenSim tutorial_33\ModelFiles\MoBL_ARMS_module2_4_allmuscles.osim');



osimState=osimModel.initSystem();

%Model elements identification

Nstates       = osimModel.getNumStateVariables();
Ncontrols     = osimModel.getNumControls();
Ncoord        = osimModel.getNumCoordinates(); 
Nbodies       = osimModel.getNumBodies();
model_muscles = osimModel.getMuscles();
Nmuscles      = model_muscles.getSize();

% get model states
states_all = cell(Nstates,1);
for i = 1:Nstates
   states_all(i,1) = cell(osimModel.getStateVariableNames().getitem(i-1));
end

% get model muscles (controls)
Muscles = osimModel.getMuscles();  
controls_all = cell(Ncontrols,1);
for i = 1:Ncontrols
   currentMuscle = Muscles.get(i-1);
   controls_all(i,1) = cell(currentMuscle.getName());
end

% get model coordinates
Coord = osimModel.getCoordinateSet();
Coord_all = cell(Ncoord,1);
for i = 1:Ncoord
   currentCoord = Coord.get(i-1);
   Coord_all(i,1) = cell(currentCoord.getName());
end

% Setup Joint angles 
editableCoordSet = osimModel.updCoordinateSet();
editableCoordSet.get('elv_angle').setValue(osimState, 0);
editableCoordSet.get('elv_angle').setLocked(osimState, true);

editableCoordSet.get('shoulder_elv').setValue(osimState, 0);
editableCoordSet.get('shoulder_elv').setLocked(osimState, true);

editableCoordSet.get('shoulder_rot').setValue(osimState, 0);
editableCoordSet.get('shoulder_rot').setLocked(osimState, true);

editableCoordSet.get('pro_sup').setValue(osimState, deg2rad(80));
editableCoordSet.get('pro_sup').setLocked(osimState, true);
 
editableCoordSet.get('deviation').setValue(osimState, 0);
editableCoordSet.get('deviation').setLocked(osimState, true);
 
editableCoordSet.get('flexion').setValue(osimState, deg2rad(-10));
editableCoordSet.get('flexion').setLocked(osimState, false);


osimState.getY.set(40,0); %zera ativacao inicial ECRL
osimState.getY.set(42,0); %zera ativacao inicial ECRB
osimState.getY.set(44,0); %zera ativacao inicial ECU
osimState.getY.set(46,0); %zera ativacao inicial FCR
osimState.getY.set(48,0); %zera ativacao inicial FCU
osimState.getY.set(50,0); %zera ativacao inicial PQ
osimState.getY.set(52,0); %zera ativacao inicial SUP

osimModel.equilibrateMuscles(osimState); %solve for equilibrium similiar


% Check to see if model state is initialized by checking size
if(osimModel.getWorkingState().getNY() == 0)
   osimState = osimModel.initSystem();
else
   osimState = osimModel.updWorkingState(); 
end

% Create the Initial State matrix from the Opensim state
numVar = osimState.getY().size();
InitStates = zeros(numVar,1);
for i = 0:1:numVar-1
    InitStates(i+1,1) = osimState.getY().get(i); 
end

SimuInfo.InitStates=InitStates;


%% Environment for RL Training
%Observation Info
obsInfo= rlNumericSpec([3 1]);
obsInfo.Name = 'observation';
obsInfo.Description = 'Phi, error, error_int';

%Action Info
actInfo=rlNumericSpec([2 1], 'LowerLimit', [0;0],'UpperLimit',[.5;.5]);
actInfo.Name = 'action';
actInfo.Description = 'uECRL, uFCR';


StepHandle=@(Action,LoggedSignals)MyStepFunction(Action,LoggedSignals,SimuInfo,osimModel,osimState)
ResetHandle=@()MyResetFunction(osimModel,osimState);

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



% load('Agent109.mat')
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