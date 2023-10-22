function [c,ceq] = gaConstrain(ModelParams)
    c=[]; 
    ceq=[]; 

 %% HInf Synthesis
    x1=ModelParams(1);
    x2=ModelParams(2);
    x3=ModelParams(3);
    x4=ModelParams(4);
    x5=ModelParams(5);
    x6=ModelParams(6);

    c(1)=-x1+x3;
    c(2)=-x1+x2+0.01;
    c(3)=-x2+x3+0.01;

    c(4)=-x6+x4;
    c(5)=x5-x6+0.01;
    c(6)=-x5+x4+0.01;

  %% Matsuoka Oscillator [tau  T   a   b   c]
    x7=ModelParams(7); %beta
    x8=ModelParams(8); %h
    x9=ModelParams(9); %r
    x10=ModelParams(10);%tau1
    x19=ModelParams(19);%tau2

    c(7)=x7-x8;
    c(8)=x8-1-(x10/x19);

  %% Flags Oscillator add to control effort

    x11=ModelParams(11);
    x12=ModelParams(12);
    x13=ModelParams(13);
    x14=ModelParams(14);
    x15=ModelParams(15);
    x16=ModelParams(16);
    x17=ModelParams(17);
    x18=ModelParams(18);


    c(9)=x11+x12-1;
    c(10)=x13+x14-1;
    c(11)=x15+x16-1;
    c(12)=x17+x18-1;





end