clc
clear all
close all


Gains=[2,.4,1.5,0.5] 

load('26_Nov_2018_08_43_40_A0075_F50_ControllerDiscrete.mat')
load('distrib_tremor_02.mat')
SimuInfo.Tend=35;
SimuInfo.Ts=0.0001;
SimuInfo.opt=0;
SimuInfo.Gains=Gains;
SimuInfo.Setpoint=[0,60];
bins=0:.2:10;
[p,v]=hist(P,bins);

SimuInfo.p=p;
Kz=c2d(K,SimuInfo.Ts);
SimuInfo.Kz=Kz;

[motionData]=ForwardSimuControl(SimuInfo);
    
SimuInfo.ElapsedTime=toc





% %%
% 
% load('divKL_data.mat')
% 
% Q_phi=rad2deg(motionData.data((40000:end),19));
% Q_psi=rad2deg(motionData.data((40000:end),17))-mean(rad2deg(motionData.data((40000:end),17)))-2.2;
% Q_psidot=rad2deg(motionData.data((40000:end),37));
% Q_phidot=rad2deg(motionData.data((40000:end),39)); % não pegar do começo pra evitar transientes
% 
% figure(2)
% subplot(1,2,1)
% %phi_phidot
% plot(P_phi(2000:3200),P_phidot(2000:3200),'k') %dado do paciente
% hold on
% plot(Q_phi,Q_phidot,'r')
% % 
% % 
% subplot(1,2,2)
% %psi_psidot
% plot(P_psi(2000:3200),P_psidot(2000:3200),'k')
% hold on
% plot(Q_psi,Q_psidot,'r')