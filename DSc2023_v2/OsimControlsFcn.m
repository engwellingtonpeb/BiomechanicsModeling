%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 04/10/2023                                                       %
%  Last Update: DSc - Version 2.0                                         %
%-------------------------------------------------------------------------%
%OpenSimPlantControlsFunction_control  
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
function modelControls = OsimControlsFcn(osimModel, osimState,t,SimuInfo)

    
    % Check Size
    if(SimuInfo.Ncontrols < 1)
       error('OpenSimPlantControlsFunction:InvalidControls', ...
           'This model has no controls.');
    end

    % Get a reference to current model controls
    modelControls = osimModel.updControls(osimState);

%% Read plant angles for feedback and avoid NaN 

persistent ERR_POS
persistent xk1
persistent u
global U



   
%% Plant control implementation 
phi_ref=deg2rad(SimuInfo.Setpoint(1));
psi_ref=deg2rad(SimuInfo.Setpoint(2));

if t>10
    phi_ref=deg2rad(3.4);
    psi_ref=deg2rad(23);
end


phi=osimState.getY().get(17); % wrist flexion angle (rad)
psi=osimState.getY().get(15); % pro_sup angle (rad)


err_pos=[phi_ref-phi ; psi_ref-psi];

ERR_POS=[err_pos];


%% MPC Control Signal Generation    

% if length(xk1)<(length(SimuInfo.Ak))
%     xk1=zeros(length(SimuInfo.Ak),1);
% end
% 
% xplus=(SimuInfo.Ak*xk1)+(SimuInfo.Bk*ERR_POS); % based on J. Ji and Y. Liu, "H-infinity Controller for Discrete-Time Systems," doi: 10.1109/MVHI.2010.98.
% u=SimuInfo.Ck*xk1+SimuInfo.Dk*ERR_POS;
% xk1=xplus;

% xk=SimuInfo.Xk;
% xk=[xk(41); xk(43); xk(45); xk(47); xk(49); xk(51); xk(53); err_pos(2); err_pos(1)];
% 
% 
% u=-SimuInfo.K*xk;
%%
%u=[u(1) u(2) u(3) u(4)];


%[du_1,du_2] = oscillator(SimuInfo,t);
% %% GANHOS ADAPTATIVOS PARA ELIMINAR UM MÚSCULO COMO FUNÇÃO DO ERRO

eps_phi=rad2deg(err_pos(1));
eps_psi=rad2deg(err_pos(2));

ALPHA1=((-0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5);
ALPHA2=(0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5;

ALPHA3=(0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+.5;
ALPHA4=(-0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+0.5;


%% INPUT CONTROLE

% if strcmp(SimuInfo.SimulationGoal, 'idtf')
%     idtfsignals2
% end

%  if t<1



    u(1)=0.1*ALPHA1;%*(2*u(1)); %ECRL
    u(2)=0.1*ALPHA2;%*(0.4*u(2)); %FCU
    u(3)=0.1*ALPHA3;%*(1.5*u(3)); %PQ
    u(4)=0.1*ALPHA4;%*(0.5*u(4)); %SUP

%Perturbações
if t>2 && t<2.5
    u(1)=u(1)+0.1;
end

if t>4 && t<4.5
    u(2)=u(2)+0.1;
end

if t>6 && t<6.5
    u(3)=u(3)+0.1;
end

if t>8 && t<8.5
    u(4)=u(4)+0.1;
end


%% Actuators saturation (muscle excitation limits 0<=u<=1)


for i=1:length(u)
    if u(i)>=1
        u(i)=1;
    end
    
    if u(i)<0
        u(i)=0;
    end
end


%% Update modelControls with the new values
    osimModel.updControls(osimState).set(1,u(1)); %ECRL
    osimModel.updControls(osimState).set(5,u(2)); %FCU
    osimModel.updControls(osimState).set(6,u(3)); %PQ
    osimModel.updControls(osimState).set(0,u(4)); %SUP

    osimModel.updControls(osimState).set(2,0); %ECRB
    osimModel.updControls(osimState).set(3,0); %ECU
    osimModel.updControls(osimState).set(4,0); %FCR

    U=[U; u];
 
%% ============  REAL TIME PLOT ===============
persistent j
if (t==0)
    j=0;
else


 if (rem(j,100)==0)

    t
    subplot(4,1,1)
    plot(t,rad2deg(phi_ref),'go',t,rad2deg(phi),'r.')
    axis([t-3 t -40 40])
    drawnow;
    grid on;
    hold on;
    
    subplot(4,1,2)
    plot(t,rad2deg(psi_ref),'go',t,rad2deg(psi),'k.')
    axis([t-3 t -20 60])
    drawnow;
    grid on;
    hold on;
    
    subplot(4,1,3)
    plot(t,u(1),'b.',t,u(2),'r.')
    axis([t-3 t -1 1])
    drawnow;
    grid on;
    hold on;

    subplot(4,1,4)
    plot(t,u(3),'b.',t,u(4),'r.')
    axis([t-3 t -1 1])
    drawnow;
    grid on;
    hold on;

 end
 j=j+1;
end




