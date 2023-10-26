function [c,ceq] = gaConstrain(ModelParams)
    c=[]; 
    ceq=[]; 

 %% HInf Synthesis
    x1=ModelParams(1); %W1
    x2=ModelParams(2); %W1
    x3=ModelParams(3); %W1

    x4=ModelParams(4);
    x5=ModelParams(5);
    x6=ModelParams(6);

    x7=ModelParams(7);

    c(1)=-x1+x3+0.01;
    c(2)=-x6+x4+0.01;



    [LinStabilityFlag, K, wc] = ControllerSynthesis(ModelParams);
    
    if isempty(wc)
        x7=-1;
    else
        x7=1;
    end

    c(3)=x7; % if x7 negative Jaime's book (pg198) condition of W1, W3 is met.


    




  %% Matsuoka Oscillator [beta h r tau1 tau2]
    x8=ModelParams(8);   %beta
    x9=ModelParams(9);   %h
    x10=ModelParams(10); %r
    x11=ModelParams(11); %tau1
    x12=ModelParams(12); %tau2

    % Stable oscilation conditions from Matsuoka, Kiyotoshi. "Analysis of a 
    % neural oscillator." Biological cybernetics 104 (2011): 297-304.
    c(4)=x9-1-x8;
    c(5)=(x11/x12)+1-x9; %


  %% Flags Oscillator add to control effort

%     x13=ModelParams(13);
%     x14=ModelParams(14);
%     c(6)=(-x13*-x14)-.01;
% 
%     x15=ModelParams(15);
%     x16=ModelParams(16);
%     c(7)=(-x15*-x16)-.01;
% 
%     
%     x17=ModelParams(17);
%     x18=ModelParams(18);
%     c(8)=(-x17*-x18)-.01;
%     
%     x19=ModelParams(19);
%     x20=ModelParams(20);
%     c(9)=(-x19*-x20)-.01;
% 
% 
%     c(10)=-x13-x14+0.01;
%     c(11)=-x15-x16+0.01;
%     c(12)=-x17-x18+0.01;
%     c(13)=-x19-x20+0.01;



 




end