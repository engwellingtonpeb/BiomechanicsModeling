
clear all 
close all
clc


addpath('D:\06_BiomechCodeRepo\BiomechanicsModeling\DSc2023_v2\simulations')
load('2023_10_15_20_08_22_DMDmodel.mat'); %  Discrete DMDc identified model
sys=d2c(sysDMDc);

P=tf(sys);

% % FPB pondera S=1/W1
% % W1=makeweight(10,[30,1],.01); %makeweight(dcgain,[freq,mag],hfgain)
% % 
% % FPA pondera T=1/W3
% % W3=makeweight(.01,[30,.02],1); %makeweight(dcgain,[freq,mag],hfgain)



% FPB pondera S=1/W1
W1=makeweight(10,[30,1],.01); %makeweight(dcgain,[freq,mag],hfgain)

% A=[ 100 0 0 0 0 0 0 0;...
%     0 1 0 0 0 0 0 0;...
%     0  0 1 0 0 0 0 0;...
%     0  0 0 1 0 0 0 0;...
%     0  0 0 0 1 0 0 0;...
%     0  0 0 0 0 1 0 0;...
%     0  0 0 0 0 0 1 0;... 
%     0  0 0 0 0 0 0 1]
% 
% W1=A*W1;

% FPA pondera T=1/W3
W3=makeweight(.01,[30,.9],10); %makeweight(dcgain,[freq,mag],hfgain)

% s=tf('s')
% W1old =((.1*s+100)/(10*s+100))*(.1/(s+0.001));
% W3old =.01*(0.1*s+1)/(0.01*s+1);

W2=[];

% bodemag(W3)
% hold on
% bodemag(W3old)


figure
bodemag(1/W1)
hold on
% bodemag(1/W2)
bodemag(1/W3)
inver=(1/W1)+(1/W3)
bodemag(inver)


% figure(2)
% bodemag(W1)
% hold on
% % bodemag(1/W2)
% bodemag(W3)

grid

legend('1/Ws', '1/Wk', 'inver')


wc = getGainCrossover(inver,1)


[K,CL,gamma,info] = mixsyn(P,W1,W2,W3);



looptransfer=loopsens(P,K);
L=looptransfer.Lo;
T=looptransfer.To;
I=eye(size(L));

figure(3)
omega=logspace(-1,3,1000);
sigma( T,'k-.', gamma/W3, 'go')


% bodemag(1/W1)
% hold on
% bode(1/W3)
% hold on
% 
% 
% 
% 
% 
% 
% sysMF=feedback(P*K, eye(8));
% 
% sysMF=minreal(sysMF)