function [LinStabilityFlag, K] = ControllerSynthesis(ModelParams)

addpath('D:\06_BiomechCodeRepo\BiomechanicsModeling\DSc2023_v2\simulations')
load('2023_10_15_20_08_22_DMDmodel.mat'); %  Discrete DMDc identified model
sys=d2c(sysDMDc);


% Params GA
f_tremor=4; %Hz (>=4)
omega_tremor=2*pi*f_tremor;

f_mov=2.5; %Hz (<=2.5)
omega_mov=2*pi*f_mov;


omegaMed=(omega_tremor+omega_mov)/2;

x1=ModelParams(1);
x2=ModelParams(2);
x3=ModelParams(3);
x4=ModelParams(4);
x5=ModelParams(5);
x6=ModelParams(6);




W1 = makeweight(x1,[omegaMed x2],x3); % FPB pondera S=1/W1
W3 = makeweight(x4,[omegaMed x5],x6); % FPA pondera T=1/W3

W2 =[];% makeweight(x5,[x6 x7],x8); % FPA pondera KS


[K,CL,gamma,info] = mixsyn(sys,W1,W2,W3);



    if isempty(K)
        LinStabilityFlag=0;
    else
        LinStabilityFlag=isstable(CL);
    end


end