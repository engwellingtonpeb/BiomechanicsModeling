function [LinStabilityFlag, K, wc] = ControllerSynthesis(ModelParams)

addpath('D:\06_BiomechCodeRepo\BiomechanicsModeling\DSc2023_v2\simulations')
load('2023_10_15_20_08_22_DMDmodel.mat'); %  Discrete DMDc identified model
sys=d2c(sysDMDc);

x1=ModelParams(1);
x2=ModelParams(2);
x3=ModelParams(3);
x4=ModelParams(4);
x5=ModelParams(5);
x6=ModelParams(6);





% 24/10
% FPB pondera S=1/W1
W1=makeweight(x1,[x2,1],x3); %makeweight(dcgain,[freq,mag],hfgain)

% FPA pondera T=1/W3
W3=makeweight(x4,[x5,.9],x6); %makeweight(dcgain,[freq,mag],hfgain)



% % FPB pondera S=1/W1
% W1=makeweight(10,[30,1],.01); %makeweight(dcgain,[freq,mag],hfgain)
% 
% % FPA pondera T=1/W3
% W3=makeweight(.01,[30,.9],1); %makeweight(dcgain,[freq,mag],hfgain)

W2 =[];

% Condition Jaime's Book
inver=(1/W1)+(1/W3);
wc = getGainCrossover(inver,1);


[K,CL,gamma,info] = mixsyn(sys,W1,W2,W3);




    if isempty(K)
        LinStabilityFlag=0;
    else
        LinStabilityFlag=isstable(CL);
    end


end

% s=tf('s')

% % W1 = makeweight(x1,[omegaMed x2],x3,0,1); 
% % W3 = makeweight(x4,[omegaMed x5],x6,0,1); 
% 
% 
% W1 =((.1*s+100)/(10*s+100))*(.1/(s+0.001));
% W3 =.01*(0.1*s+1)/(0.01*s+1);
% 
% % FPB pondera S=1/W1
% W1=makeweight(10,[30,1],.01); %makeweight(dcgain,[freq,mag],hfgain)
% 
% % FPA pondera T=1/W3
% W3=makeweight(.01,[30,.02],1); %makeweight(dcgain,[freq,mag],hfgain)

% % FPB pondera S=1/W1
% W1=makeweight(10,[30,1],.01); %makeweight(dcgain,[freq,mag],hfgain)
% 
% A=[ 100 0 0 0 0 0 0 0;...
%     0 100 0 0 0 0 0 0;...
%     0  0 1 0 0 0 0 0;...
%     0  0 0 1 0 0 0 0;...
%     0  0 0 0 1 0 0 0;...
%     0  0 0 0 0 1 0 0;...
%     0  0 0 0 0 0 1 0;... 
%     0  0 0 0 0 0 0 1]
% 
% W1=A*W1;
% 
% % FPA pondera T=1/W3
% W3=eye(8)*makeweight(.01,[30,.95],1); %makeweight(dcgain,[freq,mag],hfgain)