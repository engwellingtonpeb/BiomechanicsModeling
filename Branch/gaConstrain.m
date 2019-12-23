function [c,ceq] = gaConstrain(Gains)

c1=-abs(Gains(2))+abs(Gains(1)); % se todos menores que zero isso garante u>0 sempre
c2=-abs(Gains(4))+abs(Gains(3));
c3=-abs(Gains(6))+abs(Gains(5));
c4=-abs(Gains(8))+abs(Gains(7));
c=[c1 c2 c3 c4]; %c5 c6 c7 c8 c9 c10 c11 c12];
 % o maior deles ainda tem que ser menor que zero


ceq=[];

end

