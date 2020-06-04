%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 24/12/2019                                                       %
%  DSc - Version 1.0
%-------------------------------------------------------------------------%
% DSc ver 0 - Release 27/03/2019 - MSc thesis code. 
%
% DSc ver 1.0 and further are under version control. 
% https://github.com/engwellingtonpeb/BiomechanicsModeling
% Due date: 20/01/2020 ---- Release date:
%
% From this version on all functionalities will be built as functions, 
% improving code control and maintenability
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%                   NEW FUNCTIONALITIES DSc ver 1.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   - Import patient data directly from inertial and EMG stored on XLS; -ok
%   - Signal conditioning; -ok
%   - Generates Matsuoka's oscillator config vectors from data; -ok
%   - Run autotune optimization; -ok
%   - Compatibilize simulation and collected data (downsampling); -ok

%   - Generate plot (sprectrogram, FFT, limit-cycle, time-domain); - fail
%   - Run longer simulation; - fail
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear all; close all hidden
load('26_Nov_2018_08_43_40_A0075_F50_ControllerDiscrete.mat')

%% Gathering collected data from a specific patient.
OriginFlag='UFRJ';
%OriginFlag='UNIFESP';
[PatientRawSignals] = ImportPatientData(OriginFlag);

%% Preprocessing patient signal
[PatientConditionedSignals] = PatientSignalConditioning(PatientRawSignals, OriginFlag);

%% Extracting patient signal features to tune tremor model and generating a log file

OptimizationAlgorithm.technique='ga';
%OptimizationAlgorithm.technique='patternsearch';
[OscillatorParam, CostParam]=PatientFeatureExtraction(PatientConditionedSignals, OptimizationAlgorithm);



%% Model Tuning

SimuInfo.Tend=10;
SimuInfo.Ts=0.0001;
SimuInfo.opt=0;
SimuInfo.Setpoint=[0,70];
SimuInfo.p=OscillatorParam.P;
Kz=c2d(K,SimuInfo.Ts);
SimuInfo.Kz=Kz;
[Ak,Bk,Ck,Dk]=ssdata(SimuInfo.Kz);
SimuInfo.Ak=Ak;
SimuInfo.Bk=Bk;
SimuInfo.Ck=Ck;
SimuInfo.Dk=Dk;
SimuInfo.Saturation=1;
SimuInfo.Ni=CostParam.Ni;

[SimuInfo]=BiomechModelTunning(OscillatorParam, CostParam, OptimizationAlgorithm,SimuInfo)


%% Simulation 60s
% SimuInfo.Gains=[1.91898485278581 1.38965724595163 0.325223470389261 1.68143451196733]
SimuInfo.Tend=20;
[motionData] = ForwardSimuControl(SimuInfo)

indir=pwd;
indir=strcat(indir,'\log_files');
global filename;
filename=strcat(filename,'MotionResults')
extension='.mat';
motionFilename=fullfile(indir,[filename extension]);
save(motionFilename,'motionData','SimuInfo');

%% Control Synthesis for FES

%% Simulation with FES

%% Deliverables - Controller for embedding and simulation results



