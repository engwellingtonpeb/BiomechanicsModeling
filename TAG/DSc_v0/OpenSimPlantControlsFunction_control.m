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
function modelControls = OpenSimPlantControlsFunction03(osimModel, osimState,t,SimuInfo)
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
    p=SimuInfo.p;
%% Read plant angles for feedback and avoid NaN 
    

global U
global Ureal


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

global phi_storage
global psi_storage

   
%% Plant control implementation 

% if t<=1
phi_ref=deg2rad(0);
psi_ref=deg2rad(70);
% end


% if t>1 && t<=2
% phi_ref=deg2rad(10);
% psi_ref=deg2rad(70);
% end
% 
% if t>2 && t<=3
% phi_ref=deg2rad(-10);
% psi_ref=deg2rad(70);
% end
% 
% 
% if t>3 && t<=4
% phi_ref=deg2rad(0);
% psi_ref=deg2rad(60);
% end
% 
% 
% if t>4 && t<=6
% phi_ref=deg2rad(0);
% psi_ref=deg2rad(70);
% end
% 
% if t>6 && t<=8
% phi_ref=deg2rad(0);
% psi_ref=deg2rad(80);
% end
% 
% if t>8 && t<=10
% phi_ref=deg2rad(0);
% psi_ref=deg2rad(70);
% end
% phi_ref=deg2rad(0);
% psi_ref=deg2rad(70);

phi=osimState.getY().get(17); % wrist flexion angle (rad)
% rad2deg(phi);
phi_storage=[phi_storage;rad2deg(phi)];


psi=osimState.getY().get(15); % pro_sup angle (rad)
psi_storage=[psi_storage;rad2deg(psi)];

err_pos=[phi_ref-phi ; psi_ref-psi];

ERR_POS=[err_pos];


%% Control Signal Generation    
% UNICO CONTROLADOR

[Ak,Bk,Ck,Dk]=ssdata(SimuInfo.Kz);

    if length(xk1)<(length(Ak))
        xk1=zeros(length(Ak),1);
    end

xplus=(Ak*xk1)+(Bk*ERR_POS);
u=Ck*xk1+Dk*ERR_POS;
xk1=xplus;

%%
u=[(u(1)) u(2) u(3) u(4)];
Ureal=[Ureal;u]; %guarda a saída do controlador s/ nenhuma alteração


% %% GANHOS ADAPTATIVOS PARA ELIMINAR UM MÚSCULO COMO FUNÇÃO DO ERRO
% 
eps_phi=rad2deg(err_pos(1));
eps_psi=rad2deg(err_pos(2));

ALPHA1=((-0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5);
ALPHA2=(0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5;

ALPHA3=(0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+.5;
ALPHA4=(-0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+0.5;

% 
% %%% perturbações 
% %%%%%%%%%%%% MATSUOKA'S OSCILLATOR %%%%%%%%%
% global X
% global V
% global Y1
% 
% 
% persistent R
% persistent j1
% if (t==0)
%     j1=0;
%     Kf=2;
%     R=[Kf];
% else
% 
%     if (rem(j1,5000)==0)
%         T=-0.35+(gendist(p/570,570,1))*.21;
%         aa=1;
%         bb=570;
%         rr=(bb-aa).*rand(570,1)+aa;
%         rr=round(rr);
%         rindex=rr(10);
%         Kf=T(rindex)/2;
%          R=[Kf];
%     end
%      j1=j1+1;
%  
% end
% 
% %% DISTRIBUTION ADJUST
% %%T=-0.2+(gendist(p/570,570,1))*.2
% %%
% Kf=R;
% tau1=.1;
% tau2=.1;
% B=2.5;
% A=5;
% h=2.5;
% rosc=1;
% 
% 
% dh=0.0001;
% 
% s1=0;%osimModel.getMuscles().get('ECRL').getActivation(osimState); %activation
% s2=0;%osimModel.getMuscles().get('FCU').getActivation(osimState);%activation
% 
% if (t==0)
%     x_osc=[normrnd(.5,0.25) normrnd(.5,0.25)]; %valor inicial [0,1]
%     v_osc=[normrnd(.5,0.25) normrnd(.5,0.25)];
%     X=[x_osc(1,1);x_osc(1,2)];
%     V=[v_osc(1,1);v_osc(1,2)];
% end
% 
% 
% %%euler p/ EDO
% x1=X(1,end)+dh*((1/(Kf*tau1))*((-X(1,end))-B*V(1,end)-h*max(X(2,end),0)+A*s1+rosc));
% y1=max(x1,0);
% v1=V(1,end)+dh*((1/(Kf*tau2))*(-V(1,end)+max(X(1,end),0)));
% 
% x2= X(2,end)+dh*((1/(Kf*tau1))*((-X(2,end))-B*V(2,end)-h*max(X(1,end),0)-A*s2+rosc));
% y2=max(x2,0);
% v2=V(2,end)+dh*((1/(Kf*tau2))*(-V(2,end)+max(X(2,end),0)));
% 
% 
% X=[x1;x2];
% V=[v1;v2];
% Y1=[y1;y2];
% 
% 
% 
% 
% 
%  
% du_1=Y1(1,end);
% du_2=Y1(2,end);
% du_3=0.15*(1+square(2*pi*R*t));
% du_4=0.15*(1+square(2*pi*R*t));
% 
% 
%% INPUT CONTROLE
%     u1=ALPHA1*(u(1)); %ECRL
%     u2=ALPHA2*(0.1*u(2)); %FCU
%     u3=ALPHA3*(u(3)); %PQ
%     u4=ALPHA4*(0.5*u(4)); %SUP
% % 
% if t<1
% 
%     u1=ALPHA1*(2*u(1)); %ECRL
%     u2=ALPHA2*(0.4*u(2)); %FCU
%     u3=ALPHA3*(1.5*u(3)); %PQ
%     u4=ALPHA4*(0.5*u(4)); %SUP
% 
% else 
%     
%     u1=ALPHA1*(u(1)+0.25*du_1); %ECRL
%     u2=ALPHA2*(0.1*u(2)+0.25*du_2); %FCU
%     u3=ALPHA3*(u(3)+0.45*du_2); %PQ
%     u4=ALPHA4*(0.5*u(4)+0.45*du_1); %SUP
    
    u1=ALPHA1; %ECRL
    u2=ALPHA2; %FCU
    u3=ALPHA3; %PQ 
    u4=ALPHA4; %SUP
    
% end


u=[u1 u2 u3 u4];

% Actuators saturation (muscle excitation limits 0<=u<=1)
for i=1:length(u)
    if u(i)>=1
        u(i)=1;
    end
    
    if u(i)<0
        u(i)=0;
    end
end


    U=[U;u]; %guarda a excitação enviada ao músculo

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% ESSE IF FUNCIONA PRA CONTROLAR SETPOINT %%%%%%%%%%%%%%%%
% u1=[];
% u2=[];
% 
% if err_pos(1)>=0
%     uFCU.set(0,0.5);
%     u2=0.5;
%     u1=0;
% end
% 
% if err_pos(1)<0
%    uECRL.set(0,1)
%    u1=1;
%    u2=0;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    persistent j
if (t==0)
    j=0;
else


 if (rem(j,100)==0)


    subplot(4,1,1)
    plot(t,rad2deg(phi_ref),'go',t,rad2deg(phi),'r.')
    axis([t-3 t -40 40])
    drawnow;
    grid on;
    hold on;
    
    subplot(4,1,2)
    plot(t,rad2deg(psi_ref),'go',t,rad2deg(psi),'k.')
    axis([t-3 t 50 100])
    drawnow;
    grid on;
    hold on;
    
    subplot(4,1,3)
    plot(t,u(1),'b.',t,u(2),'r.')
    axis([t-3 t -1 1])
    drawnow;
    grid on;
    hold on;

%     subplot(4,1,3)
%     plot(t,Y1(1,end),'b.',t,Y1(2,end),'r.')
%     axis([t-3 t -2 2])
%     drawnow;
%     grid on;
%     hold on;

    subplot(4,1,4)
    plot(t,u(3),'b.',t,u(4),'r.')
    axis([t-3 t -1 1])
    drawnow;
    grid on;
    hold on;

%     subplot(4,1,4)
%     plot(t,u(1),'b.',t,u(2),'r.')
%     axis([t-3 t -1 1])
%     drawnow;
%     grid on;
%     hold on;


 end
 j=j+1;
end