%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                  Department of Biomedical Engineering                   %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 15/10/2020                                                       %
%-------------------------------------------------------------------------%
%
% Analysis of tremor signals from voluntary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

load('2017_unifesp_01_dp.mat')

%% load signal
add=1;
P=[];
P1=[];
%while (add)
    
      

     pd011=table2array(pdluis4); %usou para o artigo pdluis4
    

     %EMG Extensores e Flexores
    Fs_emg=1925.93;
    t_emg=(pd011(:,1));
    N=length(t_emg);% comprimento do vetor de tempo
    ts=1/Fs_emg; % intervalo de tempo entre duas amostras
    Ttotal=ts*(N-1);
    t_emg=[0:ts:Ttotal];
    Xemg=([pd011(:,2) pd011(:,10)]); %Xemg(:,1)= Flexor  || Xemg(:,2)= Extensor

    %ACC Dorso da Mão
    Fs_acc=148.148;
    ts=1/Fs_acc; % intervalo de tempo entre duas amostras
    t_acc=[0:ts:Ttotal];
    N=length(t_acc);
    Xacc=([pd011((1:N),20) pd011((1:N),22) pd011((1:N),24)]); %Xacc=[Acc_X Acc_Y Acc_Z]
    % 
    %Gyro Dorso da Mão
    Fs_gyro=148.148;
    % comprimento do vetor de tempo
    ts=1/Fs_gyro; % intervalo de tempo entre duas amostras

    % Ttotal=ts*(N-1);
    t_gyro=[0:ts:Ttotal];
    N=length(t_gyro);
    Xgyro=([pd011((1:N),26) pd011((1:N),28) pd011((1:N),30)]); %Xacc=[Gyro_X(pro_sup) Gyro_Y(flex) Gyro_Z(rad_ulnar)]

     
     
     
     
    ts_gyro=1/Fs_gyro;
    Tjan=1;
    Njan=round(Tjan/ts_gyro); %qtd ptos na janela
    r=rectwin(Njan);%Define janela RETANGULAR de comprimento Njan
    h=hamming(Njan);%Define janela HAMMING de comprimento Njan
    N=length(t_gyro);
    w1=(floor(N/6));
    
    
    fc=15;
    delta=10;
    Wp=(fc-delta)/(Fs_gyro/2);
    Ws=(fc+delta)/(Fs_gyro/2);
    Rp=0.1;
    Rs=60;
    [Ng,Wn] = buttord(Wp, Ws, Rp, Rs);
    [B,A] = butter(Ng,Wn);
    
    Xgyro_f(:,1)=filtfilt(B,A,Xgyro(:,1));
    Xgyro_f(:,2)=filtfilt(B,A,Xgyro(:,2));
    Xgyro_f(:,3)=filtfilt(B,A,Xgyro(:,3));
    
    Xbase(:,1)=Xgyro_f(:,1)-mean(Xgyro_f(:,1));
    Xbase(:,2)=Xgyro_f(:,2)-mean(Xgyro_f(:,2));
    Xbase(:,3)=Xgyro_f(:,3)-mean(Xgyro_f(:,3));
    

    X=[cumtrapz(t_gyro,Xbase(:,1)) cumtrapz(t_gyro,Xbase(:,2)) cumtrapz(t_gyro,Xbase(:,3))];
    
    
Phi_ref=X(:,2);
Phidot_ref=Xgyro_f(:,2);
Psi_ref=X(:,1);
Psidot_ref=Xgyro_f(:,1);


    
 for ij=1:6 %6 JANELAS DE 10 SEGUNDOS
    
    F=0:.1:20;
    overlap=.5*Njan; % 50% overlap
    [s,w,t] =spectrogram(Xgyro_f(((w1*ij-w1+1):(w1*(ij+1)-w1-1)),2),h,overlap,F,Fs_gyro,'yaxis');
    s=abs((s)); %(ANALISE DE JANELAS DE 10 SEGUNDOS)
    s=s./max(max(s)); %normaliza a amplitude (q nao é importante na analise)
    figure(ij)
    surf( t, w, s );
%     title('Espectrograma s/ Overlap - Janela Hamming')
    ylabel('Frequência(Hz)')
    xlabel('Tempo(s)')
    zlabel('Amplitude')
    colormap jet

     
     
     %FREQUENCY HISTOGRAM

        [k,l]=size(s);
        
        for i=1:l
            [val,k]=max(s(:,i));
            P=[P F(k)];
        end
  %% Limit Cycle
        Xbase(:,1)=Xgyro(:,1)-mean(Xgyro(:,1));
        Xbase(:,2)=Xgyro(:,2)-mean(Xgyro(:,2));
        Xbase(:,3)=Xgyro(:,3)-mean(Xgyro(:,3));
        
X=[cumtrapz(t_gyro,Xbase(:,1)) cumtrapz(t_gyro,Xbase(:,2)) cumtrapz(t_gyro,Xbase(:,3))];
        
  

 
 
 end    
     

%% Sinais do Modelo

t_simu=[];
Phi_simu=[];
Psi_simu=[];
Phidot_simu=[];
Psidot_simu=[];
a_ecrl=[];
a_fcu=[];

load('2020_11_25_22_20_14_MScPaperKL_paciente01.mat')
% load('2020_11_24_17_54_34_MScPaperKL_paciente01.mat')

Phi_simu=[Phi_simu;rad2deg(motionData.data((10000:end),19))]; %~10000 é o numero da amostra onde entra o oscilador
Psi_simu=[Psi_simu;rad2deg(motionData.data((10000:end),17))];
Phidot_simu=[Phidot_simu;rad2deg(motionData.data((10000:end),39))];
Psidot_simu=[Psidot_simu;rad2deg(motionData.data((10000:end),37))];
a_ecrl=[a_ecrl; motionData.data((10000:end),44)];  %ativ ECRL
a_fcu=[a_fcu; motionData.data((10000:end),52)];  %ativ FCU



%load('2020_11_25_22_20_14_MScPaperKL_paciente01.mat')
 load('2020_11_24_19_01_18_MScPaperKL_paciente01.mat')

Phi_simu=[Phi_simu;rad2deg(motionData.data((10000:end),19))]; %~10000 é o numero da amostra onde entra o oscilador
Psi_simu=[Psi_simu;rad2deg(motionData.data((10000:end),17))];
Phidot_simu=[Phidot_simu;rad2deg(motionData.data((10000:end),39))];
Psidot_simu=[Psidot_simu;rad2deg(motionData.data((10000:end),37))];
a_ecrl=[a_ecrl; motionData.data((10000:end),44)];  %ativ ECRL
a_fcu=[a_fcu; motionData.data((10000:end),52)];  %ativ FCU

%load('2020_11_25_22_20_14_MScPaperKL_paciente01.mat')
 load('2020_11_24_20_06_11_MScPaperKL_paciente01.mat')

Phi_simu=[Phi_simu;rad2deg(motionData.data((10000:end),19))]; %~10000 é o numero da amostra onde entra o oscilador
Psi_simu=[Psi_simu;rad2deg(motionData.data((10000:end),17))];
Phidot_simu=[Phidot_simu;rad2deg(motionData.data((10000:end),39))];
Psidot_simu=[Psidot_simu;rad2deg(motionData.data((10000:end),37))];
a_ecrl=[a_ecrl; motionData.data((10000:end),44)];  %ativ ECRL
a_fcu=[a_fcu; motionData.data((10000:end),52)];  %ativ FCU

load('2020_11_26_08_32_19_MScPaperKL_paciente01.mat')
% load('2020_11_24_22_18_19_MScPaperKL_paciente01.mat')

Phi_simu=[Phi_simu;rad2deg(motionData.data((10000:end),19))]; %~10000 é o numero da amostra onde entra o oscilador
Psi_simu=[Psi_simu;rad2deg(motionData.data((10000:end),17))];
Phidot_simu=[Phidot_simu;rad2deg(motionData.data((10000:end),39))];
Psidot_simu=[Psidot_simu;rad2deg(motionData.data((10000:end),37))];
a_ecrl=[a_ecrl; motionData.data((10000:end),44)];  %ativ ECRL
a_fcu=[a_fcu; motionData.data((10000:end),52)];  %ativ FCU

load('2020_11_26_02_44_20_MScPaperKL_paciente01.mat')
% load('2020_11_24_23_20_34_MScPaperKL_paciente01.mat')

Phi_simu=[Phi_simu;rad2deg(motionData.data((10000:end),19))]; %~10000 é o numero da amostra onde entra o oscilador
Psi_simu=[Psi_simu;rad2deg(motionData.data((10000:end),17))];
Phidot_simu=[Phidot_simu;rad2deg(motionData.data((10000:end),39))];
Psidot_simu=[Psidot_simu;rad2deg(motionData.data((10000:end),37))];
a_ecrl=[a_ecrl; motionData.data((10000:end),44)];  %ativ ECRL
a_fcu=[a_fcu; motionData.data((10000:end),52)];  %ativ FCU

load('2020_11_26_01_46_11_MScPaperKL_paciente01.mat')
% load('2020_11_25_00_23_35_MScPaperKL_paciente01.mat')

Phi_simu=[Phi_simu;rad2deg(motionData.data((10000:end),19))]; %~10000 é o numero da amostra onde entra o oscilador
Psi_simu=[Psi_simu;rad2deg(motionData.data((10000:end),17))];
Phidot_simu=[Phidot_simu;rad2deg(motionData.data((10000:end),39))];
Psidot_simu=[Psidot_simu;rad2deg(motionData.data((10000:end),37))];
a_ecrl=[a_ecrl; motionData.data((10000:end),44)];  %ativ ECRL
a_fcu=[a_fcu; motionData.data((10000:end),52)];  %ativ FCU

load('2020_11_26_00_39_32_MScPaperKL_paciente01.mat')
% load('2020_11_25_01_23_36_MScPaperKL_paciente01.mat')

Phi_simu=[Phi_simu;rad2deg(motionData.data((10000:end),19))]; %~10000 é o numero da amostra onde entra o oscilador
Psi_simu=[Psi_simu;rad2deg(motionData.data((10000:end),17))];
Phidot_simu=[Phidot_simu;rad2deg(motionData.data((10000:end),39))];
Psidot_simu=[Psidot_simu;rad2deg(motionData.data((10000:end),37))];
a_ecrl=[a_ecrl; motionData.data((10000:end),44)];  %ativ ECRL
a_fcu=[a_fcu; motionData.data((10000:end),52)];  %ativ FCU

Ts=.0001;
t_simu=0:Ts:(length(Phi_simu)-1)*Ts;

[Phi_simu,t_new] = resample(Phi_simu,t_simu,Fs_gyro);
[Psi_simu,t_new] = resample(Psi_simu,t_simu,Fs_gyro);

Psi_simu=Psi_simu-mean(Psi_simu);

[Phidot_simu,t_new] = resample(Phidot_simu,t_simu,Fs_gyro);
[Psidot_simu,t_new] = resample(Psidot_simu,t_simu,Fs_gyro);

[a_ecrl,t_emg_simu] = resample(a_ecrl,t_simu,Fs_emg);
[a_fcu,t_emg_simu] = resample(a_fcu,t_simu,Fs_emg);

Phi_simu=Phi_simu(381:end);
Psi_simu=Psi_simu(381:end);
Phidot_simu=Phidot_simu(381:end);
Psidot_simu=Psidot_simu(381:end);

%spectrogram from simulation


for ij=1:6 %6 JANELAS DE 10 SEGUNDOS
    
    F=0:.1:20;
    overlap=.5*Njan; % 50% overlap
    [s,w,t] =spectrogram(Phidot_simu(((w1*ij-w1+1):(w1*(ij+1)-w1-1)),1),h,overlap,F,Fs_gyro,'yaxis');
    s=abs((s)); %(ANALISE DE JANELAS DE 10 SEGUNDOS)
    s=s./max(max(s)); %normaliza a amplitude (q nao é importante na analise)
    figure(6+ij)
    surf( t, w, s );
%     title('Espectrograma s/ Overlap - Janela Hamming')
    ylabel('Frequência(Hz)')
    xlabel('Tempo(s)')
    zlabel('Amplitude')
    colormap jet

     
     
     %FREQUENCY HISTOGRAM

        [k,l]=size(s);
        
        for i=1:l
            [val,k]=max(s(:,i));
            P1=[P1 F(k)];
        end

end       
figure
histogram(P)
hold on
histogram(P1,'FaceColor',[1 0 0],'FaceAlpha',0.5,'LineStyle','-.','LineWidth',1.5)

%%
% dist_freq=KLDiv(P,P1)
% dist_Phi=KLDiv(Phi_ref'+100,Phi_simu'+100)
% dist_Psi=KLDiv(Psi_ref'+100,Psi_simu'+100)
% dist_Phidot=KLDiv(Phidot_ref'+1000,Phidot_simu'+1000)
% dist_Psidot=KLDiv(Psidot_ref'+1000,Psidot_simu'+1000)



%% Ciclos

figure
plot(Phi_ref,Phidot_ref,'b','LineWidth',2)
grid 
hold on
plot(Phi_simu,Phidot_simu,'r-.','LineWidth',.5)

figure
plot(Psi_ref,Psidot_ref,'b','LineWidth',2)
grid 
hold on
plot(Psi_simu,Psidot_simu,'r-.','LineWidth',.5)

figure
histogram(Phi_ref)
hold on
histogram(Phi_simu,'FaceColor',[1 0 0],'FaceAlpha',0.5,'LineStyle','-.','LineWidth',1.5)

figure
histogram(Psi_ref)
hold on
histogram(Psi_simu,'FaceColor',[1 0 0],'FaceAlpha',0.5,'LineStyle','-.','LineWidth',1.5)

figure
histogram(Phidot_ref)
hold on
histogram(Phidot_simu,'FaceColor',[1 0 0],'FaceAlpha',0.5,'LineStyle','-.','LineWidth',1.5)

figure
histogram(Psidot_ref)
hold on
histogram(Psidot_simu,'FaceColor',[1 0 0],'FaceAlpha',0.5,'LineStyle','-.','LineWidth',1.5)

load('freq_paciente01_hist.mat') %best histogram paciente 01


[Table] = MetricsTable(P,P2,Phi_ref,Phi_simu,Psi_ref,Psi_simu,Phidot_ref,Phidot_simu,Psidot_ref,Psidot_simu)
%% Ativação/EMG

% tsin1=timeseries(motionData.data(:,44),motionData.data(:,1)); %ativ ECRL
% tsin2=timeseries(motionData.data(:,52),motionData.data(:,1)); %ativ FCU
% 
% tsout1=resample(tsin1,t_emg(1:19261));
% tsout2=resample(tsin2,t_emg(1:19261));
% 
% a_ecrl=tsout1.data;
% a_fcu=tsout2.data;


%Low Pass Filtering
%  Xemg(:,1)=Xemg(:,1)./max(Xemg(:,1));%Xemg(:,1)= Flexor  || Xemg(:,2)= Extensor
%  Xemg(:,2)=Xemg(:,2)./max(Xemg(:,2));

%Retificar
% Xemg(:,1)=abs(Xemg(:,1));
% Xemg(:,2)=abs(Xemg(:,2));

%filtrar
fc=15;
delta=10;
Wp=(fc-delta)/(Fs_emg/2);
Ws=(fc+delta)/(Fs_emg/2);
Rp=0.1;
Rs=60;
[Ng,Wn] = buttord(Wp, Ws, Rp, Rs);
[B,A] = butter(Ng,Wn);

Xemg_f(:,1)=filter(B,A,Xemg(:,1));
Xemg_f(:,2)=filter(B,A,Xemg(:,2));

%normalizanr
Xemg_fn(:,1)=abs(Xemg_f(:,1)./max(Xemg_f(:,1)));%Xemg(:,1)= Flexor  || Xemg(:,2)= Extensor
Xemg_fn(:,2)=abs(Xemg_f(:,2)./max(Xemg_f(:,2)));

%%
a_fcu=(a_fcu(4936:end));


figure
histogram(Xemg_fn(:,1),'Normalization','probability')
hold on
histogram((a_fcu./max(a_fcu)),'Normalization','probability')

A1=Xemg_fn(:,1);
B1=a_fcu;
%B1(end)=B1(end-1);


a_ecrl=abs(a_ecrl(4936:end));
figure
histogram(Xemg_fn(:,2),'Normalization','probability') % 10 segundos
hold on
histogram(a_ecrl./max(a_ecrl),'Normalization','probability')
A2=Xemg_fn(:,2);
B2=a_ecrl;
%B2(end)=B2(end-1);
% dist_emg2=KLDiv(A2',B2')


%% flexors
w=2*iqr(B1)*length(B1)^(-1/3);
edges=[min(B1),max(B1)];
[Metrics] = ModelMetrics(A1,B1,edges,w);

