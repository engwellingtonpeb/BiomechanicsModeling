function [du_1,du_2] = oscillator(SimuInfo,t)
%MATSUOKA'S OSCILLATOR FUNCTION

p=SimuInfo.p;
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

    if (rem(j1,5000)==0)
        T=-0.35+(gendist(p/570,570,1))*.21;
        aa=1;
        bb=570;
        rr=(bb-aa).*rand(570,1)+aa;
        rr=round(rr);
        rindex=rr(10);
        Kf=T(rindex)/2;
         R=[Kf];
    end
     j1=j1+1;
 
end

Kf=R;
tau1=.1;
tau2=.1;
B=2.5;
A=5;
h=2.5;
rosc=1;


dh=SimuInfo.Ts;

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

