function [d1,d2] = tremordrive(SimuInfo,t)
%MATSUOKA'S OSCILLATOR FUNCTION

P=SimuInfo.p;
persistent X
persistent V
persistent Y1


persistent R
persistent j1
if (t==0)
    j1=0;
    Kf=2;
    R=[Kf];
else

    if (rem(j1,20000)==0)
            r=round(random(SimuInfo.pd,1,1));
            P(r)
            Tosc=1/P(r);
            Kf=(Tosc)/.1051;
         
         
         
         R=[Kf];
    end
     j1=j1+1;
 
end

%% DISTRIBUTION ADJUST
%%T=-0.2+(gendist(p/570,570,1))*.2
%%
Kf=R;
tau1=.1;
tau2=.1;
B=2.5;
A=5;
h=2.5;
rosc=1;


dh=0.0001;

s1=0;%osimModel.getMuscles().get('ECRL').getActivation(osimState); %activation
s2=0;%osimModel.getMuscles().get('FCU').getActivation(osimState);%activation

if (t==0)
    x_osc=[normrnd(.5,0.25) normrnd(.5,0.25)]; %valor inicial [0,1]
    v_osc=[normrnd(.5,0.25) normrnd(.5,0.25)];
    X=[x_osc(1,1);x_osc(1,2)];
    V=[v_osc(1,1);v_osc(1,2)];
end


%%euler p/ EDO
x1=X(1,end)+dh*((1/(Kf*tau1))*((-X(1,end))-B*V(1,end)-h*max(X(2,end),0)+A*s1+rosc));
y1=max(x1,0);
v1=V(1,end)+dh*((1/(Kf*tau2))*(-V(1,end)+max(X(1,end),0)));

x2= X(2,end)+dh*((1/(Kf*tau1))*((-X(2,end))-B*V(2,end)-h*max(X(1,end),0)-A*s2+rosc));
y2=max(x2,0);
v2=V(2,end)+dh*((1/(Kf*tau2))*(-V(2,end)+max(X(2,end),0)));


X=[x1;x2];
V=[v1;v2];
Y1=[y1;y2];





 
du_1=Y1(1,end);
du_2=Y1(2,end);
end
