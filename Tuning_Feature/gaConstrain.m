function [c,ceq] = gaConstrain(Gains)

c1=abs(Gains(1))-Gains(2); % se todos menores que zero isso garante u>0 sempre
c2=abs(Gains(3))-Gains(4);
c3=abs(Gains(5))-Gains(6);
c4=abs(Gains(7))-Gains(8);
c5=Gains(1)-1;
c6=Gains(2)-1;
c7=Gains(3)-1;
c8=Gains(4)-1;
c9=Gains(5)-1;
c10=Gains(6)-1;
c11=Gains(7)-1;
c12=Gains(8)-1;
c=[c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12];
 % o maior deles ainda tem que ser menor que zero


ceq=[];

end

