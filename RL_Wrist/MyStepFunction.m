function [NextObs,Reward,IsDone,LoggedSignals,SimuInfo] = MyStepFunction(Action,LoggedSignals,SimuInfo,osimModel,osimState)
import org.opensim.modeling.*
global episode
global n
persistent ErrorVec
persistent ErrorInt
persistent u
Ts=SimuInfo.Ts;
t=n*Ts

global States

if t==0
    States=SimuInfo.InitStates;
end
 
% call plant
SimuInfo.Action=Action;
%[x_dot, controlValues] = OpenSimPlantFunction(t,States,osimModel,osimState,SimuInfo);


%Integrator
% Perform Euler integration.
% LoggedSignals.State = States + SimuInfo.Ts.*x_dot;

% Runge-Kutta

y=States;

[x_dot, controlValues] = OpenSimPlantFunction(t,States,osimModel,osimState,SimuInfo);
s1=x_dot;

[x_dot, controlValues] = OpenSimPlantFunction(t+Ts/2,States+Ts*s1/2,osimModel,osimState,SimuInfo);
s2=x_dot;

[x_dot, controlValues] = OpenSimPlantFunction(t+Ts/2,States+Ts*s2/2,osimModel,osimState,SimuInfo);
s3=x_dot;

[x_dot, controlValues] = OpenSimPlantFunction(t+Ts,States+Ts*s3,osimModel,osimState,SimuInfo);
s4=x_dot;

LoggedSignals.State=y+Ts*(s1+2*s2+2*s3+s4)/6;

States=LoggedSignals.State;

Error=rad2deg(LoggedSignals.State(18))-SimuInfo.PhiRef;

if t==0
    ErrorVec=[Error; Error]
    u=[Action'; Action']
    ErrorInt=0;
else
    ErrorVec=[ErrorVec(end);Error];
    u=[u(end,:); Action']; % u=[u_t-1; u_t]
end

ErrorInt= ErrorInt+(ErrorVec(end)+Error)*SimuInfo.Ts/2;

% Transform state to observation.
NextObs = [rad2deg(LoggedSignals.State(18)); Error; ErrorInt];
  
re=-(1/10)*(Error^2);
reInt=-(1/10)*(ErrorInt^2);
Q=[-1 0; 0 -1];
reU=u(1,:)*Q*u(1,:)';
r=re+reInt+reU;

% Reward
if (abs(Error)>=12 && t<=1.5)||(abs(Error)>=3 && t>1.5)
    Reward = r-((1/t)*1e3);
    IsDone=1;
    episode=episode+1;
else
    Reward = r+1;
    IsDone=0;
end

if (rem(t,.25)==0 && t>0)
    Reward = (t/.25)*1e4;
    IsDone=0;
    if t>=6
        IsDone=1;
    end
end



n=n+1;
end

