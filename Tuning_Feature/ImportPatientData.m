function [PatientRawSignals] = ImportPatientData(OriginFlag)
%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 24/12/2019                                                       %
%  DSc - Version 1.0                                                      %
%-------------------------------------------------------------------------%
%This function imports patient data, separate data and prep it for
%preprocessing; 
%-------------------------------------------------------------------------- 

if(strcmp(OriginFlag,'UNIFESP'))
    PatientRawSignals=struct;
    PatientRawSignals.Fs_semg=1925.93; %Sampling Frequencies
    PatientRawSignals.Fs_acc=148.148;
    PatientRawSignals.Fs_gyro=148.148;
    signals=[]

    %Append all collected data to the matrix called "signal". 
    % while (add)

        fullTags=cell(2,1);                                                     
        fullTags{1}='Choose the file';                                          
    %     fullTags{2}='Name the output file'  ;                                    
        indir=pwd;
        [filename,pathname]=uigetfile('*.csv',fullTags{1},indir, 'MultiSelect','on'); 

        if iscell(filename)

            for i=1:length(filename)
                fileaddress=strcat(pathname,filename(i));
                aux=readtable(fileaddress{:});
                signals=[signals;aux]; 
            end

        else 
                fileaddress=strcat(pathname,filename);
                aux=readtable(fileaddress);
                signals=[signals;aux]; 
        end


    signals=table2array(signals);
    %Matrix signal treatment to build PatientRawSignals.sEMG, PatientRawSignals.acc, PatientRawSignals.gyro 

    t_semg=linspace(0,max(signals(:,1)),length(signals(:,1)))';
    PatientRawSignals.sEMG=([t_semg signals(:,2) signals(:,10)]); %time || Xemg(:,1)= Flexor  || Xemg(:,2)= Extensor


    %Because sampling time is different for emg and inertial signals, blocks of
    %NaN forms into the singal, following code get correct chunk of it
    clearNaNblocks_1=signals(:,20);
    clearNaNblocks_2=signals(:,22);
    clearNaNblocks_3=signals(:,24);

    clearNaNblocks_1=clearNaNblocks_1(~isnan(clearNaNblocks_1));
    clearNaNblocks_2=clearNaNblocks_2(~isnan(clearNaNblocks_2));
    clearNaNblocks_3=clearNaNblocks_3(~isnan(clearNaNblocks_3));

    t_acc=linspace(0,max(signals(:,1)),length(clearNaNblocks_1))';
    PatientRawSignals.acc=([ t_acc clearNaNblocks_1 clearNaNblocks_2 clearNaNblocks_3]); %Xacc=[t_acc Acc_X(prosup) Acc_Y(flex) Acc_Z(radulnar)]


    clearNaNblocks_1=signals(:,26);
    clearNaNblocks_2=signals(:,28);
    clearNaNblocks_3=signals(:,30);

    clearNaNblocks_1=clearNaNblocks_1(~isnan(clearNaNblocks_1));
    clearNaNblocks_2=clearNaNblocks_2(~isnan(clearNaNblocks_2));
    clearNaNblocks_3=clearNaNblocks_3(~isnan(clearNaNblocks_3));

    t_gyro=linspace(0,max(signals(:,1)),length(clearNaNblocks_1))';
    PatientRawSignals.gyro=([t_gyro clearNaNblocks_1 clearNaNblocks_2 clearNaNblocks_3]) %Xacc=[t_gyro Gyro_X Gyro_Y Gyro_Z]
end
if(strcmp(OriginFlag,'UFRJ'))
   
    %File Import
    fullTags=cell(2,1);                                                     
    fullTags{1}='Choose the file';                                          
    indir=pwd;
    [filename,pathname]=uigetfile('*.mat',fullTags{1},indir, 'MultiSelect','on'); 
    addpath(pathname)
    load(filename)

    %Signal parametrization
    fs=20;%[Hz]
    
    PatientRawSignals.Fs_semg=1925.93; %Sampling Frequencies
    PatientRawSignals.Fs_acc=fs;
    PatientRawSignals.Fs_gyro=fs;
    
    time=0:1/fs:(length(IMUData)-1)*(1/fs);
    time=time';
    
    t_semg=time;
    PatientRawSignals.sEMG=[]; 
    
    t_acc=time;
    PatientRawSignals.acc=([ t_acc IMUData(:,4) IMUData(:,5) IMUData(:,6)]); %Xacc=[t_acc Acc_X(prosup) Acc_Y(flex) Acc_Z(radulnar)]

    t_gyro=time;
    PatientRawSignals.gyro=([t_gyro IMUData(:,1) IMUData(:,2) IMUData(:,3)])


end