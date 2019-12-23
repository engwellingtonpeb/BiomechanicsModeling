%Data checking
clc
clear all
close all

load('divKL_data.mat')
load('08_Dec_2019_DScMotionSimulation.mat')
fs=148.148;


%resampling to patient aquisition hardware
[phi,t] = resample(motionData.data(:,19),motionData.data(:,1),fs);
phidot = resample(motionData.data(:,39),motionData.data(:,1),fs);
psi = resample(motionData.data(:,17),motionData.data(:,1),fs);
psidot = resample(motionData.data(:,37),motionData.data(:,1),fs);
phi=rad2deg(phi);
phidot=rad2deg(phidot);
psi=rad2deg(psi);
psidot=rad2deg(psidot);

%getting equally sized chuncky of signal 
x=[phi(2800:4000)-mean(phi(2800:4000)) P_phi(2000:3200) phidot(2800:4000) P_phidot(2000:3200) psi(2800:4000)-mean(psi(2000:3200)) P_psi(2000:3200) psidot(2800:4000) P_psidot(2000:3200)];


%% plots

%boxplots
x=[phi(2800:4000) P_phi(2000:3200) phidot(2800:4000) P_phidot(2000:3200) psi(2800:4000)-mean(psi(2000:3200)) P_psi(2000:3200)-mean(P_psi(2000:3200)) psidot(2800:4000) P_psidot(2000:3200)];
figure(1)
subplot(2,2,1)
boxplot(x(:,(1:2)),'Labels',{'phi_hat','phi'})

subplot(2,2,2)
boxplot(x(:,(3:4)),'Labels',{'phidot_hat','phidot'})

subplot(2,2,3)
boxplot(x(:,(5:6)),'Labels',{'psi_hat','psi'})

subplot(2,2,4)
boxplot(x(:,(7:8)),'Labels',{'psidot_hat','psidot'})




% %Limit Cicle
figure(2)
subplot(1,2,1)

plot(P_phi(2000:3200),P_phidot(2000:3200),'k') %dado do paciente
hold on
plot(phi(3000:end),phidot(3000:end),'r')

subplot(1,2,2)
plot(P_psi(2000:3200),P_psidot(2000:3200),'k')
hold on
plot(psi(3000:end)-mean(psi(3000:end)),psidot(3000:end),'r')




