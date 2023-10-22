clear all
close all
clc

            %tau  T   a   b   c
ModelParam=[0.25 0.5 2.5 5 1.5];


tau=ModelParam(1);
T=ModelParam(2);
a=ModelParam(3);
b=ModelParam(4);
c=ModelParam(5);


wn=(1/T)*sqrt(((tau+T)*b-tau*a)/tau*a)




Ts=1e-3
t=0:Ts:10;
du=[]
figure




for n=1:length(t)
    
  t=(n-1)*Ts;

    if t==0
        xosc_0=[normrnd(.5,0.25);... %x1(0)
                normrnd(.5,0.25);... %v1(0)
                normrnd(.5,0.25);...
                normrnd(.5,0.25)]; 
    end


    du = ode1(@MatsuOscillator,[t t+Ts],xosc_0,ModelParam);

    xosc_0=du(end,:);
    y=[max(0,xosc_0(1)) max(0,xosc_0(2))];


 

   if (t==0)
        j=0;
    else
    
        if (rem(j,10)==0)
            
            plot(t,y(1),'b*')
            hold on
            plot(t,y(2),'k*')
            drawnow
        end
    
        j=j+1;
    end

end


