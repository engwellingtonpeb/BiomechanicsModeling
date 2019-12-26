function [PatientConditionedSignals] = PatientSignalConditioning(PatientRawSignals)
%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 24/12/2019                                                       %
%  Last Update: DSc - Version 1.0                                         %
%-------------------------------------------------------------------------%
% This function filters patient collected signal and preps it to feature  %
% extraction                                                              %
%--------------------------------------------------------------------------
PatientConditionedSignals=struct;
PatientConditionedSignals.Fs_gyro=PatientRawSignals.Fs_gyro;
PatientConditionedSignals.Fs_semg=PatientRawSignals.Fs_semg;
PatientConditionedSignals.Fs_acc=PatientRawSignals.Fs_acc;



%% Prep Filter Kinematic signals 
    Fs_gyro=PatientRawSignals.Fs_gyro;
    fc=20;
    delta=10;
    Wp=(fc-delta)/(Fs_gyro/2);
    Ws=(fc+delta)/(Fs_gyro/2);
    Rp=0.1;
    Rs=60;
    [Ng,Wn] = buttord(Wp, Ws, Rp, Rs);
    [B,A] = butter(Ng,Wn);
    
    
%% Prep Filter sEMG
    Fs_semg=PatientRawSignals.Fs_semg;
    fc=30;
    delta=10;
    Wp=(fc-delta)/(Fs_semg/2);
    Ws=(fc+delta)/(Fs_semg/2);
    Rp=0.1;
    Rs=60;
    [Ng,Wn] = buttord(Wp, Ws, Rp, Rs);
    [C,D] = butter(Ng,Wn);

%% Kinematic Signals

    Xgyro_f(:,1)=filtfilt(B,A,PatientRawSignals.gyro(:,2));
    Xgyro_f(:,2)=filtfilt(B,A,PatientRawSignals.gyro(:,3));
    Xgyro_f(:,3)=filtfilt(B,A,PatientRawSignals.gyro(:,4));

    Xacc_f(:,1)=filtfilt(B,A,PatientRawSignals.acc(:,2));
    Xacc_f(:,2)=filtfilt(B,A,PatientRawSignals.acc(:,3));
    Xacc_f(:,3)=filtfilt(B,A,PatientRawSignals.acc(:,4));
    
    
    Xbase(:,1)=Xgyro_f(:,1)-mean(Xgyro_f(:,1));
    Xbase(:,2)=Xgyro_f(:,2)-mean(Xgyro_f(:,2));
    Xbase(:,3)=Xgyro_f(:,3)-mean(Xgyro_f(:,3));

%         Xbase(:,1)=Xgyro(:,1)-mean(Xgyro(:,1));
%         Xbase(:,2)=Xgyro(:,2)-mean(Xgyro(:,2));
%         Xbase(:,3)=Xgyro(:,3)-mean(Xgyro(:,3));
    t_gyro=  PatientRawSignals.gyro(:,1);
    X=[cumtrapz(t_gyro,Xbase(:,1)) cumtrapz(t_gyro,Xbase(:,2)) cumtrapz(t_gyro,Xbase(:,3))];
%         
PatientConditionedSignals.AngularPosition=[PatientRawSignals.gyro(:,1),X];
PatientConditionedSignals.AngularVelocity=[PatientRawSignals.gyro(:,1),Xgyro_f];
PatientConditionedSignals.AngularAcc=[PatientRawSignals.acc(:,1),Xacc_f];

%% Activation 
   
%normalize sEMG
  Xemg(:,1)=PatientRawSignals.sEMG(:,2)./max(PatientRawSignals.sEMG(:,2));
  Xemg(:,2)=PatientRawSignals.sEMG(:,3)./max(PatientRawSignals.sEMG(:,3));

%low pass filtering

    activation(:,1)=filtfilt(C,D,Xemg(:,1));
    activation(:,2)=filtfilt(C,D,Xemg(:,2));

    PatientConditionedSignals.Activation=[PatientRawSignals.sEMG(:,1),activation(:,1),activation(:,2)];
end

