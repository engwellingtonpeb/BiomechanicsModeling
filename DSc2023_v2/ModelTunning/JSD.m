function [J] = JSD(motionData, SimuInfo)
%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo, DSc.                              %         
%  Date: 21/10/2023                                                       %
%  Last Update:                                                           %
% DSc - Version 2.0                                                       %
%-------------------------------------------------------------------------%
% Jansen-Shannon Divergence Evaluation  for CostFcn                       %
%                                                                         %
%------------------------------------------------------------------------ %


%% Getting Patient Signal and Treating
close all

load('2017_unifesp_01_dp.mat')

%% load signal
add=1;
P=[];
P1=[];
 
      

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
    Tjan=.5;
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

      %Limit Cycle
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



Phi_simu=[Phi_simu; rad2deg(motionData.data((2000:end),19))]; %~2000 é o numero da amostra onde entra o oscilador
Psi_simu=[Psi_simu; rad2deg(motionData.data((2000:end),17))];
Phidot_simu=[Phidot_simu; rad2deg(motionData.data((2000:end),39))];
Psidot_simu=[Psidot_simu; rad2deg(motionData.data((2000:end),37))];
a_ecrl=[a_ecrl; motionData.data((2000:end),44)];  %ativ ECRL
a_fcu=[a_fcu; motionData.data((2000:end),52)];  %ativ FCU


% spectrogram from simulation
    
    

    ts_simu=SimuInfo.Ts;
    Fs_simu=1/ts_simu;
    Tjan=.5;
    Njan=round(Tjan/ts_simu); %qtd ptos na janela
    r=rectwin(Njan);%Define janela RETANGULAR de comprimento Njan
    h=hamming(Njan);%Define janela HAMMING de comprimento Njan
    N=length(Phidot_simu);
    w1=(floor(N));


for ij=1:1 %6 JANELAS DE 10 SEGUNDOS
    
    F=0:.1:20;
    overlap=.5*Njan; % 50% overlap
    [s,w,t] =spectrogram(Phidot_simu(((w1*ij-w1+1):(w1*(ij+1)-w1-1)),1),h,overlap,F,Fs_simu,'yaxis');
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

J=struct();

    %% freq
    P1=[P1 P1 P1 P1 P1 P1];
    w1=2*iqr(P1)*length(P1)^(-1/3);
    edges1=[min(P1),max(P1)];

    w=2*iqr(P)*length(P)^(-1/3);
    edges=[min(P),max(P)];
    

    [Metrics] = ModelMetrics(P,P1,w,edges,w1,edges1); % JSD of tremor freq 
    J.freq=sqrt(Metrics.JSD^2+Metrics.dI^2+Metrics.CentroidError^2);

    %% phi
    Phi_ref=Phi_ref+mean(Phi_simu);

    w=2*iqr(Phi_ref)*length(Phi_ref)^(-1/3);
    edges=[min(Phi_ref),max(Phi_ref)];
    w1=2*iqr(Phi_simu)*length(Phi_simu)^(-1/3);
    edges1=[min(Phi_simu),max(Phi_simu)];

    [Metrics] = ModelMetrics(Phi_ref,Phi_simu,w,edges,w1,edges1); % JSD of tremor Phi
    J.Phi=sqrt(Metrics.JSD^2+Metrics.dI^2+Metrics.CentroidError^2);



    %% psi
    Psi_ref=Psi_ref+mean(Psi_simu);

    w=2*iqr(Psi_ref)*length(Psi_ref)^(-1/3);
    edges=[min(Psi_ref),max(Psi_ref)];
    w1=2*iqr(Psi_simu)*length(Psi_simu)^(-1/3);
    edges1=[min(Psi_simu),max(Psi_simu)];

    [Metrics] = ModelMetrics(Psi_ref,Psi_simu,w,edges,w1,edges1); % JSD of tremor Psi
    J.Psi=sqrt(Metrics.JSD^2+Metrics.dI^2+Metrics.CentroidError^2);

    %% Erro de setpoint
     global ERR_POS

     J.err_phi= norm(ERR_POS(:,1));
     J.err_psi= norm(ERR_POS(:,2));

end