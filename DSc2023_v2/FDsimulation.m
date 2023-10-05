function [motionData] = FDsimulation(SimuInfo)
%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                  Department of Biomedical Engineering                   %
%                                                                         %
%  Author: Wellington Cássio Pinheiro - MESTRADO                          %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 16/10/2018   Versão atual 07/02/2019                             %
%-------------------------------------------------------------------------%
%% Initialization
import org.opensim.modeling.*
osimModel=Model('.\ModelFiles\MoBL_ARMS_module2_4_allmuscles.osim');

%osimModel.setUseVisualizer(true);

osimState=osimModel.initSystem();

%% Model elements identification

Nstates       = osimModel.getNumStateVariables();
Ncontrols     = osimModel.getNumControls();
Ncoord        = osimModel.getNumCoordinates(); 
Nbodies       = osimModel.getNumBodies();
model_muscles = osimModel.getMuscles();
Nmuscles      = model_muscles.getSize();

SimuInfo.Nstates=Nstates;
SimuInfo.Ncontrols=Ncontrols;
SimuInfo.Ncoord=Ncoord;
SimuInfo.Nbodies=Nbodies;
SimuInfo.model_muscles=model_muscles;
SimuInfo.Nmuscles=Nmuscles;

% get model states
states_all = cell(Nstates,1);
for i = 1:Nstates
   states_all(i,1) = cell(osimModel.getStateVariableNames().getitem(i-1));
end

SimuInfo.states_all=states_all;

% get model muscles (controls)
Muscles = osimModel.getMuscles();  
controls_all = cell(Ncontrols,1);
for i = 1:Ncontrols
   currentMuscle = Muscles.get(i-1);
   controls_all(i,1) = cell(currentMuscle.getName());
end

SimuInfo.controls_all=controls_all;


% get model coordinates
Coord = osimModel.getCoordinateSet();
Coord_all = cell(Ncoord,1);
for i = 1:Ncoord
   currentCoord = Coord.get(i-1);
   Coord_all(i,1) = cell(currentCoord.getName());
end

SimuInfo.Coord_all=Coord_all;

%% Setup Joint angles 
% phini=[5,10,15,-5,-10,-15];
% psini=[85, 80, 70, 65, 60, 55];



editableCoordSet = osimModel.updCoordinateSet();
editableCoordSet.get('elv_angle').setValue(osimState, 0);
editableCoordSet.get('elv_angle').setLocked(osimState, true);

editableCoordSet.get('shoulder_elv').setValue(osimState, 0);
editableCoordSet.get('shoulder_elv').setLocked(osimState, true);

editableCoordSet.get('shoulder_rot').setValue(osimState, 0);
editableCoordSet.get('shoulder_rot').setLocked(osimState, true);

% editableCoordSet.get('elbow_flexion').setValue(osimState, deg2rad(30));
% editableCoordSet.get('elbow_flexion').setLocked(osimState, true);

%editableCoordSet.get('pro_sup').setValue(osimState, deg2rad(psini(SimuInfo.index)));
editableCoordSet.get('pro_sup').setValue(osimState, deg2rad(80));
editableCoordSet.get('pro_sup').setLocked(osimState, false);
 
editableCoordSet.get('deviation').setValue(osimState, 0);
editableCoordSet.get('deviation').setLocked(osimState, true);
 
%editableCoordSet.get('flexion').setValue(osimState, deg2rad(phini(SimuInfo.index)));
editableCoordSet.get('flexion').setValue(osimState, deg2rad(-10));
editableCoordSet.get('flexion').setLocked(osimState, false);


osimState.getY.set(40,0); %zera ativacao inicial ECRL
osimState.getY.set(42,0); %zera ativacao inicial ECRB
osimState.getY.set(44,0); %zera ativacao inicial ECU
osimState.getY.set(46,0); %zera ativacao inicial FCR
osimState.getY.set(48,0); %zera ativacao inicial FCU
osimState.getY.set(50,0); %zera ativacao inicial PQ
osimState.getY.set(52,0); %zera ativacao inicial SUP



%% Prep Simulation
%stateDerivVector = osimModel.computeStateVariableDerivatives(osimState);
osimModel.equilibrateMuscles(osimState); %solve for equilibrium similiar

%Controls function
controlsFuncHandle = @OsimControlsFcn;
Ts=SimuInfo.Ts;
Tend=SimuInfo.Tend;

%Integrate plant using Matlab Integrator
timeSpan = [0:Ts:Tend];
integratorName = 'ode15s'; %fixed step Dormand-Prince method of order 5
integratorOptions = odeset('RelTol', 1e-2)
SimuInfo.osimplot=true;

%% Run Simulation
% set(gcf, 'color', 'white');

tic
       motionData = IntegrateOsimPlant(osimModel, controlsFuncHandle, timeSpan, ...
        integratorName,SimuInfo,integratorOptions)
       
elapsedTime=toc

SimuInfo.elapsedTime=elapsedTime;



end

