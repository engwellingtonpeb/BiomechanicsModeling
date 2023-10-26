%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 04/10/2023                                                       %
%  Last Update: DSc - Version 2.0                                         %
%-------------------------------------------------------------------------%
% OpenSimPlantControlsFunction_control  
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

global ERR_POS

persistent xk1
persistent u
global U



   
%% Plant control implementation 
% if t<=2
    phi_ref=deg2rad(SimuInfo.Setpoint(1));
    psi_ref=deg2rad(SimuInfo.Setpoint(2));
% elseif t>2 && t<=5
%     phi_ref=deg2rad(10);
%     psi_ref=deg2rad(10);
% 
%  elseif t>5 && t<=8
%     phi_ref=deg2rad(-5);
%     psi_ref=deg2rad(25);
% 
%  elseif t>8 && t<=10
%     phi_ref=deg2rad(2);
%     psi_ref=deg2rad(20);
% end

%references 
r=[0.01 0.01 0.01 0.01 phi_ref psi_ref 0 0]'; % asup aecrl afcu apq phi psi phidot psidot


% states
asup=osimState.getY().get(54);
aecrl=osimState.getY().get(42);
afcu=osimState.getY().get(50);
apq=osimState.getY().get(52);
phi=osimState.getY().get(17); % wrist flexion angle (rad)
psi=osimState.getY().get(15); % pro_sup angle (rad)
phi_dot=osimState.getY().get(37);
psi_dot=osimState.getY().get(35);

%[osimModel.getMuscles().get('ECRL').getActivation(osimState) aecrl]
%CHECKED OK


x=[asup aecrl afcu apq phi psi phi_dot psi_dot]';

e=r-x;

err_pos=[phi_ref-phi ; psi_ref-psi];


eps_phi=rad2deg(err_pos(1));
eps_psi=rad2deg(err_pos(2));

ERR_POS=[ERR_POS; [eps_phi eps_psi]];


%% Control Signal Generation    

if length(xk1)<(length(SimuInfo.Ak))
    xk1=zeros(length(SimuInfo.Ak),1);
end

xplus=(SimuInfo.Ak*xk1)+(SimuInfo.Bk*e); % based on J. Ji and Y. Liu, "H-infinity Controller for Discrete-Time Systems," doi: 10.1109/MVHI.2010.98.
u=SimuInfo.Ck*xk1+SimuInfo.Dk*e;
xk1=xplus;
if any(isnan(u))
    disp('ERRO AQUI')
    u(isnan(u))=0;
    xk1=zeros(length(SimuInfo.Ak),1);
end
    %

%% Reciprocal Inhibition

ALPHA1=((-0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5);
ALPHA2=(0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5;

ALPHA3=(0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+.5;
ALPHA4=(-0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+0.5;


%% Tremor CPG


persistent X
persistent V
persistent Y1


persistent Kf
persistent j1

    B=SimuInfo.ModelParams(7); %beta
    h=SimuInfo.ModelParams(8); %h
    rosc=SimuInfo.ModelParams(9); %r
    tau1=SimuInfo.ModelParams(10);%tau1
    tau2=SimuInfo.ModelParams(19);%tau2


    tau1=.1;
    tau2=.1;
    B=2.5;
     A=5;
    h=2.5;
    rosc=1;

if (t==0)
    j1=0;
    Kf=2;

else

if (rem(j1,1000)==0)
        P=randsample(SimuInfo.P,1);
%         Tosc=1/P;
%         Kf=(Tosc)/.1051;
        Kf=(1/(2*pi*P))*sqrt(1/(tau1*tau2)); % Zhang, Dingguo, et al. "Neural 
        % oscillator based control for pathological tremor suppression via 
        % functional electrical stimulation." Control Engineering Practice 19.1 (2011): 74-88.
     
end
    j1=j1+1;
 
end
    





    %dh=0.0001;
    dh=SimuInfo.Ts;
    s1=0;%osimModel.getMuscles().get('ECRL').getActivation(osimState); %activation
    s2=0;%osimModel.getMuscles().get('FCU').getActivation(osimState);%activation

    if (t==0)
        x_osc=[normrnd(.5,0.25) normrnd(.5,0.25)]; %valor inicial [0,1]
        v_osc=[normrnd(.5,0.25) normrnd(.5,0.25)];
        X=[x_osc(1,1);x_osc(1,2)];
        V=[v_osc(1,1);v_osc(1,2)];
    end


    %%Implemented as (Zhang, Dingguo, et al. "Neural oscillator based control for 
    % pathological tremor suppression via functional electrical stimulation." 
    % Control Engineering Practice 19.1 (2011): 74-88.)

    x1=X(1,end)+dh*((1/(Kf*tau1))*((-X(1,end))-B*V(1,end)-h*max(X(2,end),0)+A*s1+rosc));
    y1=max(x1,0);
    v1=V(1,end)+dh*((1/(Kf*tau2))*(-V(1,end)+max(X(1,end),0)));

    x2= X(2,end)+dh*((1/(Kf*tau1))*((-X(2,end))-B*V(2,end)-h*max(X(1,end),0)-A*s2+rosc));
    y2=max(x2,0);
    v2=V(2,end)+dh*((1/(Kf*tau2))*(-V(2,end)+max(X(2,end),0)));


    X=[x1;x2];
    V=[v1;v2];
    Y1=[y1;y2];


    d(1)=Y1(1,end);
    d(2)=Y1(2,end);










%     du = ode1(@MatsuOscillator,[t t+SimuInfo.Ts],xosc_0,SimuInfo);
%     xosc_0=du(end,:);
%     d=[max(0,xosc_0(1)) max(0,xosc_0(2))];


%% Tremor Affected Muscle Excitation 

% ALPHA1=1;
% ALPHA2=1;
% ALPHA3=1;
% ALPHA4=1;

if t<.1 %initializing model
    u(1)=0.1;
    u(2)=0.00;
    u(3)=0.1;
    u(4)=0.01;

elseif t<2 && t>=0.1
    u(1)=2e6*ALPHA1*u(1); %ECRL
    u(2)=1e6*ALPHA2*u(2); %FCU
    u(3)=1e6*ALPHA3*u(3); %PQ
    u(4)=1e6*ALPHA4*u(4); %SUP
else

%     u(1)=(1e6*ALPHA1*u(1))+SimuInfo.ModelParams(11)*d(1)+SimuInfo.ModelParams(12)*d(2); %ECRL
%     u(2)=(1e6*ALPHA1*u(1))+SimuInfo.ModelParams(13)*d(1)+SimuInfo.ModelParams(14)*d(2); %FCU
%     u(3)=(1e6*ALPHA1*u(1))+SimuInfo.ModelParams(15)*d(1)+SimuInfo.ModelParams(16)*d(2); %PQ
%     u(4)=(1e6*ALPHA1*u(1))+SimuInfo.ModelParams(17)*d(1)+SimuInfo.ModelParams(18)*d(2); %SUP

    u(1)=(1e6*ALPHA1*u(1))+0.5*d(1)+0*d(2); %ECRL
    u(2)=(1e6*ALPHA2*u(2))+0*d(1)+.5*d(2); %FCU
    u(3)=(1e6*ALPHA3*u(3))+.5*d(1)+0*d(2); %PQ
    u(4)=(1e6*ALPHA4*u(4))+0*d(1)+.5*d(2); %SUP

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

    osimModel.updControls(osimState).set(2,0.01); %ECRB
    osimModel.updControls(osimState).set(3,0.01); %ECU
    osimModel.updControls(osimState).set(4,0.01); %FCR

    U=[U; u'];
 
%% ============  REAL TIME PLOT ===============
persistent j
if (t==0)
    j=0;
else


 if (rem(j,100)==0) && (SimuInfo.PltFlag==1)

    t
    subplot(4,1,1)
    plot(t,rad2deg(phi_ref),'go',t,rad2deg(phi),'r.')
    axis([t-3 t -50 50])
    drawnow;
    grid on;
    hold on;
    
    subplot(4,1,2)
    plot(t,rad2deg(psi_ref),'go',t,rad2deg(psi),'k.')
    axis([t-3 t -40 60])
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




