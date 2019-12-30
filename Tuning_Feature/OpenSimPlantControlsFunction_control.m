%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington C�ssio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 24/12/2019                                                       %
%  Last Update: DSc - Version 1.0                                                      %
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
function modelControls = OpenSimPlantControlsFunction_control(osimModel, osimState,t,SimuInfo)
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

    %t

    opt=SimuInfo.opt; %Parameter Parsing;
    p=SimuInfo.p;
%% Read plant angles for feedback and avoid NaN 
    

% if t==Time(end)
%     return;
% end
% 
% Time=[Time t];
 


uecrl=[];
ufcu=[];
upq=[];
usup=[];
Tcont=[];

persistent ERR_POS
persistent xk1
persistent u

persistent phi_storage
persistent psi_storage

   
%% Plant control implementation 


phi_ref=deg2rad(SimuInfo.Setpoint(1));
psi_ref=deg2rad(SimuInfo.Setpoint(2));


phi=osimState.getY().get(17); % wrist flexion angle (rad)
% rad2deg(phi);
phi_storage=[phi_storage;rad2deg(phi)];


psi=osimState.getY().get(15); % pro_sup angle (rad)
psi_storage=[psi_storage;rad2deg(psi)];

err_pos=[phi_ref-phi ; psi_ref-psi];

ERR_POS=[err_pos];


%% Control Signal Generation    
% UNICO CONTROLADOR

%[u,ALPHA] = OpenSimControlLaw(t,SimuInfo,err_pos) %Implement V2.0

[Ak,Bk,Ck,Dk]=ssdata(SimuInfo.Kz);

    if length(xk1)<(length(Ak))
        xk1=zeros(length(Ak),1);
    end

xplus=(Ak*xk1)+(Bk*ERR_POS);
u=Ck*xk1+Dk*ERR_POS;
xk1=xplus;

%%
u=[u(1) u(2) u(3) u(4)];


[du_1,du_2] = oscillator(SimuInfo,t);
% %% GANHOS ADAPTATIVOS PARA ELIMINAR UM M�SCULO COMO FUN��O DO ERRO

eps_phi=rad2deg(err_pos(1));
eps_psi=rad2deg(err_pos(2));

ALPHA1=((-0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5);
ALPHA2=(0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5;

ALPHA3=(0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+.5;
ALPHA4=(-0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+0.5;


%% INPUT CONTROLE

 if t<1
% 
%     u1=ALPHA1*(SimuInfo.Gains(1)*u(1)); %ECRL
%     u2=ALPHA2*(SimuInfo.Gains(2)*u(2)); %FCU
%     u3=ALPHA3*(SimuInfo.Gains(3)*u(3)); %PQ
%     u4=ALPHA4*(SimuInfo.Gains(4)*u(4)); %SUP

    u1=ALPHA1*(2*u(1)); %ECRL
    u2=ALPHA2*(0.4*u(2)); %FCU
    u3=ALPHA3*(1.5*u(3)); %PQ
    u4=ALPHA4*(0.5*u(4)); %SUP
% 
 else 
%     
%     u1=ALPHA1*(SimuInfo.Gains(1)*u(1)+.025*du_1); %ECRL
%     u2=ALPHA2*(SimuInfo.Gains(2)*u(2)+.015*du_2); %FCU
%     u3=ALPHA3*(SimuInfo.Gains(3)*u(3)+0.75*du_1); %PQ
%     u4=ALPHA4*(SimuInfo.Gains(4)*u(4)+0.7*du_2); %SUP
%     
    u1=ALPHA1*(2*u(1)+SimuInfo.Gains(1)*du_1); %ECRL
    u2=ALPHA2*(0.4*u(2)+SimuInfo.Gains(2)*du_2); %FCU
    u3=ALPHA3*(1.5*u(3)+SimuInfo.Gains(3)*du_1); %PQ
    u4=ALPHA4*(0.5*u(4)+SimuInfo.Gains(4)*du_2); %SUP
    
   
end


u=[u1 u2 u3 u4];

%% Actuators saturation (muscle excitation limits 0<=u<=1)
for i=1:length(u)
    if u(i)>=1
        u(i)=1;
    end
    
    if u(i)<0
        u(i)=0;
    end
end

uECRL.set(0,u(1));
uFCU.set(0,u(2));
uPQ.set(0,u(3));
uSUP.set(0,u(4));
 
%% Update modelControls with the new values
    osimModel.updActuators().get('ECRL').addInControls(uECRL, modelControls);
    osimModel.updActuators().get('FCU').addInControls(uFCU, modelControls);
    osimModel.updActuators().get('PQ').addInControls(uPQ, modelControls);
    osimModel.updActuators().get('SUP').addInControls(uSUP, modelControls);

  
    
%% ============  REAL TIME PLOT ===============
%     persistent j
% if (t==0)
%     j=0;
% else
% 
% 
%  if (rem(j,2000)==0)
% 
% 
%     subplot(4,1,1)
%     plot(t,rad2deg(phi_ref),'go',t,rad2deg(phi),'r.')
%     axis([t-3 t -40 40])
%     drawnow;
%     grid on;
%     hold on;
%     
%     subplot(4,1,2)
%     plot(t,rad2deg(psi_ref),'go',t,rad2deg(psi),'k.')
%     axis([t-3 t 50 100])
%     drawnow;
%     grid on;
%     hold on;
%     
%     subplot(4,1,3)
%     plot(t,u(1),'b.',t,u(2),'r.')
%     axis([t-3 t -1 1])
%     drawnow;
%     grid on;
%     hold on;
% 
% %     subplot(4,1,3)
% %     plot(t,Y1(1,end),'b.',t,Y1(2,end),'r.')
% %     axis([t-3 t -2 2])
% %     drawnow;
% %     grid on;
% %     hold on;
% 
%     subplot(4,1,4)
%     plot(t,u(3),'b.',t,u(4),'r.')
%     axis([t-3 t -1 1])
%     drawnow;
%     grid on;
%     hold on;
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