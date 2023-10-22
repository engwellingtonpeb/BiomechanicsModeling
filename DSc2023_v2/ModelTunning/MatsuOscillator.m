function [xdot] = MatsuOscillator(~,xosc_0,SimuInfo)
% Implementation Based on
% Matsuoka, K. Analysis of a neural oscillator. Biol Cybern 104, 297–304 (2011).
% https://doi.org/10.1007/s00422-011-0432-z
%
%
%% Parameters
% ModelParam=SimuInfo.ModelParams;
% wn=SimuInfo.w_tremor;
% 
% b=ModelParam(7);
% T=ModelParam(8);
% a=ModelParam(9);
% c=ModelParam(10);
% tau=(T*b)/(a*T^2*wn^2 + a - b);



ModelParam=[0.1 0.1 5 8 1];
tau=ModelParam(1);
T=ModelParam(2);
a=ModelParam(3);
b=ModelParam(4);
c=ModelParam(5);



%-------------------------------------------------------------------------

wn=(1/T)*sqrt(((tau+T)*b-tau*a)/tau*a);
f=wn/(2*pi)

x1=xosc_0(1);
v1=xosc_0(2);
x2=xosc_0(3);
v2=xosc_0(4);

xdot=[(1/(tau))*(-x1+c-a*max(0,x2)-b*v1);...
      (1/(T))*(-v1+max(0,x1));...
      (1/(tau))*(-x2+c-a*max(0,x1)-b*v2);...
      (1/(T))*(-v2+max(0,x2))];             % neuron 1 // neuron 2 


end