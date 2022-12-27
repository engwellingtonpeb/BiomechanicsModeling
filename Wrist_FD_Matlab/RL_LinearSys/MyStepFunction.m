function [NextObs,Reward,IsDone,LoggedSignals,SimuInfo] = MyStepFunction(Action,LoggedSignals,SimuInfo)

global episode
global n
persistent ErrorVec
persistent ErrorInt
persistent u
Ts=SimuInfo.Ts;
t=n*Ts;

global States



%Integrator
% Perform Euler integration.
% LoggedSignals.State = States + SimuInfo.Ts.*x_dot;

% Runge-Kutta

y=States;
suspension(t,x,u)

[x_dot] = suspension(t,States,U);
s1=x_dot;

[x_dot] = suspension(t+Ts/2,States+Ts*s1/2,U);
s2=x_dot;

[x_dot] = suspension(t+Ts/2,States+Ts*s2/2,U);
s3=x_dot;

[x_dot] = suspension(t+Ts,States+Ts*s3,U);
s4=x_dot;

LoggedSignals.State=y+Ts*(s1+2*s2+2*s3+s4)/6;

States=LoggedSignals.State;


% Reward
Reward=1;



n=n+1;
end

