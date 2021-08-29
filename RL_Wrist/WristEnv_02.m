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
SimuInfo.Ts=.0001;
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

editableCoordSet.get('pro_sup').setValue(osimState, deg2rad(90));
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
obsInfo= rlNumericSpec([2 1]);
obsInfo.Name = 'Wrist States';
obsInfo.Description = 'Phi, error';

%Action Info
actInfo=rlNumericSpec([2 1], 'LowerLimit', 0,'UpperLimit',1);
actInfo.Name = 'Neural Excitation';
actInfo.Description = 'uECRL, uFCR';


StepHandle=@(Action,LoggedSignals)MyStepFunction(Action,LoggedSignals,SimuInfo,osimModel,osimState)
ResetHandle=@()MyResetFunction(osimModel,osimState);

env = rlFunctionEnv(obsInfo,actInfo,StepHandle,ResetHandle)


%% Creating DDPG trained agent

obsInfo = getObservationInfo(env);
numObservations = obsInfo.Dimension(1);
actInfo =getActionInfo(env);
numActions = actInfo.Dimension(1);
%env.Ts=SimuInfo.Ts;


statePath = imageInputLayer([numObservations 1 1],'Normalization','none','Name','state');
actionPath = imageInputLayer([numActions 1 1],'Normalization','none','Name','action');
commonPath = [concatenationLayer(1,2,'Name','concat')
             quadraticLayer('Name','quadratic')
             fullyConnectedLayer(1,'Name','StateValue','BiasLearnRateFactor',0,'Bias',0)];

%actor-critic structure         
% 1) Critic creation
   
criticNetwork = layerGraph(statePath);
criticNetwork = addLayers(criticNetwork,actionPath);
criticNetwork = addLayers(criticNetwork,commonPath);

criticNetwork = connectLayers(criticNetwork,'state','concat/in1');
criticNetwork = connectLayers(criticNetwork,'action','concat/in2');

%%%%%

criticOpts = rlRepresentationOptions('LearnRate',5e-2,'GradientThreshold',1,'UseDevice',"gpu");
critic = rlQValueRepresentation(criticNetwork,obsInfo,actInfo,'Observation',{'state'},'Action',{'action'},criticOpts);

% figure
% plot(criticNetwork)



% 2) Actor creation
actorNetwork = [
    imageInputLayer([numObservations 1 1],'Normalization','none','Name','state')
    fullyConnectedLayer(numActions,'Name','action','BiasLearnRateFactor',0,'Bias',[0;0])];

actorOpts = rlRepresentationOptions('LearnRate',1e-03,'GradientThreshold',1,'UseDevice',"gpu");

actor = rlDeterministicActorRepresentation(actorNetwork,obsInfo,actInfo,'Observation',{'state'},'Action',{'action'},actorOpts);


% 3) DDPG algorithm for learning
     
     agentOpts = rlDDPGAgentOptions(...
    'SampleTime',SimuInfo.Ts,...
    'TargetSmoothFactor',1e-3,...
    'ExperienceBufferLength',1e6,...
    'DiscountFactor',0.95,...
    'MiniBatchSize',128);
agentOpts.NoiseOptions.Variance   = (0.3^2);
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
    'UseParallel',0);

trainingStats = train(agent,env,trainOpts);



