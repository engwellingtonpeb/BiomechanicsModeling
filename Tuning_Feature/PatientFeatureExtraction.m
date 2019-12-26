function [OscillatorParam, CostParam]=PatientFeatureExtraction(PatientConditionedSignals);
%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 24/12/2019                                                       %
%  DSc - Version 1.0                                                      %
%-------------------------------------------------------------------------%
% This function generates all needed files to configure wrist model for
% individualized forward dynamics simulations of pathological tremor
%--------------------------------------------------------------------------
LengthJanSpect=10;
Nplots=floor(max(PatientConditionedSignals.AngularPosition(:,1))/LengthJanSpect)

Fs_gyro=PatientConditionedSignals.Fs_gyro;

ts_gyro=1/Fs_gyro;
Tjan=1;
Njan=round(Tjan/ts_gyro); %qtd ptos na janela
r=rectwin(Njan);%Define janela RETANGULAR de comprimento Njan
h=hamming(Njan);%Define janela HAMMING de comprimento Njan
N=length(PatientConditionedSignals.AngularVelocity(:,1));
w1=(floor(N/Nplots));
P=[]


figure
for ij=1:Nplots
    F=0:.1:20;
    overlap=.5*Njan; % 50% overlap
    [s,w,t] =spectrogram(PatientConditionedSignals.AngularVelocity(((w1*ij-w1+1):(w1*(ij+1)-w1-1)),3),h,overlap,F,Fs_gyro,'yaxis');
    s=abs((s)); %(ANALISE DE JANELAS DE 10 SEGUNDOS)
    s=s./max(max(s)); %normaliza a amplitude (q nao é importante na analise)
%     subplot(4,Nplots/4,ij)
%     surf( t, w, s );
%     %title('Espectrograma s/ Overlap - Janela Hamming')
%     ylabel('Frequência(Hz)')
%     xlabel('Tempo(s)')
%     zlabel('Amp norm')
%     colormap jet
    
    
    %Getting histogram of frequencies
    [k,l]=size(s);
        
    for i=1:l
        [val,k]=max(s(:,i));
        P=[P F(k)];
    end

    
end
OscillatorParam.P=P;

CostParam.Phi_ref=PatientConditionedSignals.AngularPosition(:,3);
CostParam.Phidot_ref=PatientConditionedSignals.AngularVelocity(:,3)
CostParam.Psi_ref=PatientConditionedSignals.AngularPosition(:,2)
CostParam.Psidot_ref=PatientConditionedSignals.AngularVelocity(:,2)
end

