%Versão Final Wellington 07/02/2019
% ----------------------------------------------------------------------- 
%OpenSimPlantControlsFunction  
%   outVector = OpenSimPlantControlsFunction(osimModel, osimState)
%   This function computes a control vector which for the model's
%   actuators.  The current code is for use with the script
%   DesignMainStarterWithControls.m
%
% Input:
%   osimModel is an org.opensim.Modeling.Model object 
%   osimState is an org.opensim.Modeling.State object
%
% Output:
%   outVector is an org.opensim.Modeling.Vector of the control values
% -----------------------------------------------------------------------
function [modelControls,SimuInfo] = OpenSimPlantControlsFunction03(osimModel, osimState,t,SimuInfo)
    % Load Library
    import org.opensim.modeling.*;
    
    
    % Check Size
    if(osimModel.getNumControls() < 1)
       error('OpenSimPlantControlsFunction:InvalidControls', ...
           'This model has no controls.');
    end

    % Determine number of muscles/controls in the model
    muscles = osimModel.getMuscles(); 
    nMuscles = muscles.getSize();
    
    % Get a reference to current model controls
    modelControls = osimModel.updControls(osimState);
    
    % Initialize a vector for the actuator controls
    % Most actuators have a single control.  For example, muscle have a
    % signal control value (excitation);
    

    uECRL = Vector(1, 0.0);
    uFCU = Vector(1, 0.0);
    uPQ=Vector(1,0.0);
    uSUP=Vector(1,0.0);

    t

    opt=SimuInfo.opt; %Parameter Parsing;
    Gain=SimuInfo.Gains;
%% Read plant angles for feedback and avoid NaN 
    

 


uecrl=[];
ufcu=[];
upq=[];
usup=[];
Tcont=[];





   
%% Plant control implementation 

    

    phi_ref=deg2rad(SimuInfo.Setpoint(1));
    psi_ref=deg2rad(SimuInfo.Setpoint(2));
    



phi=osimState.getY().get(17); % wrist flexion angle (rad)
psi=osimState.getY().get(15); % pro_sup angle (rad)
err_pos=[phi_ref-phi ; psi_ref-psi];

ERR_POS=[err_pos];


%%% GANHOS ADAPTATIVOS PARA ELIMINAR UM MÚSCULO COMO FUNÇÃO DO ERRO

eps_phi=rad2deg(err_pos(1)); %%MSC_TOPOLOGY
eps_psi=rad2deg(err_pos(2));%%MSC_TOPOLOGY

% ALPHA1=((-0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5);%%MSC_TOPOLOGY
% ALPHA2=(0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5;%%MSC_TOPOLOGY
% 
% ALPHA3=(0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+.5;%%MSC_TOPOLOGY
% ALPHA4=(-0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+0.5;%%MSC_TOPOLOGY



% ALPHA1=-0.5*(tanh(eps_phi))+0.5;%%MSC_TOPOLOGY
% ALPHA2=0.5*(tanh(eps_phi))+0.5;%%MSC_TOPOLOGY
% 
% ALPHA3=0.5*(tanh(eps_psi))+.5;%%MSC_TOPOLOGY
% ALPHA4=-0.5*(tanh(eps_psi))+0.5;%%MSC_TOPOLOGY

ALPHA1=Gain(1)*(tanh(eps_phi))+Gain(2);%%MSC_TOPOLOGY
ALPHA2=Gain(3)*(tanh(eps_phi))+Gain(4);%%MSC_TOPOLOGY

ALPHA3=Gain(5)*(tanh(eps_psi))+Gain(6);%%MSC_TOPOLOGY
ALPHA4=Gain(7)*(tanh(eps_psi))+Gain(8);%%MSC_TOPOLOGY

% eps_phi=(u(1)-phi);%DSC_TOPOLOGY
% eps_psi=(u(2)-psi);%DSC_TOPOLOGY
% 
% ALPHA1=((-0.3*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.3); %DSC_TOPOLOGY
% ALPHA2=(0.15*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.15; %DSC_TOPOLOGY
% 
% ALPHA3=(0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+.5; %DSC_TOPOLOGY
% ALPHA4=(-0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+0.5;%DSC_TOPOLOGY
% 


%% INPUT CONTROLE


    u1=ALPHA1; %DSC_TOPOLOGY
    u2=ALPHA2; %DSC_TOPOLOGY
    u3=ALPHA3; %DSC_TOPOLOGY
    u4=ALPHA4; %DSC_TOPOLOGY


uECRL.set(0,u1);
uFCU.set(0,u2);
uPQ.set(0,u3);
uSUP.set(0,u4);
 
%% Update modelControls with the new values
    osimModel.updActuators().get('ECRL').addInControls(uECRL, modelControls);
    osimModel.updActuators().get('FCU').addInControls(uFCU, modelControls);
    osimModel.updActuators().get('PQ').addInControls(uPQ, modelControls);
    osimModel.updActuators().get('SUP').addInControls(uSUP, modelControls);

%%


    
%% ============  REAL TIME PLOT ===============
%     persistent j
% if (t==0)
%     j=0;
% else
% 
% 
%  if (rem(j,100)==0)
% 
% 
%     subplot(2,1,1)
%     plot(t,rad2deg(phi_ref),'go',t,rad2deg(phi),'r.')
%     axis([t-3 t -40 40])
%     drawnow;
%     grid on;
%     hold on;
%     
%     subplot(2,1,2)
%     plot(t,rad2deg(psi_ref),'go',t,rad2deg(psi),'k.')
%     axis([t-3 t 50 100])
%     drawnow;
%     grid on;
%     hold on;
%     
% %     subplot(4,1,3)
% %     plot(t,u1,'b.',t,u2,'r.')
% %     axis([t-3 t -1 1])
% %     drawnow;
% %     grid on;
% %     hold on;
% 
% %     subplot(4,1,3)
% %     plot(t,Y1(1,end),'b.',t,Y1(2,end),'r.')
% %     axis([t-3 t -2 2])
% %     drawnow;
% %     grid on;
% %     hold on;
% 
% %     subplot(4,1,4)
% %     plot(t,du_1,'b.',t,du_2,'r.')
% %     axis([t-3 t -1 1])
% %     drawnow;
% %     grid on;
% %     hold on;
% 
% %     subplot(4,1,4)
% %     plot(t,u(1),'b.',t,u(2),'r.')
% %     axis([t-3 t -1 1])
% %     drawnow;
% %     grid on;
% %     hold on;
% 
% 
%  end
%  j=j+1;


end