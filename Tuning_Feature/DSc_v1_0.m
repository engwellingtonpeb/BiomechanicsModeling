%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington C�ssio Pinheiro, MSc.                               %
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
%   - Generates Matsuoka's oscillator config vectors from data;
%   - Controller implemented as function with possible selection;    
%   - Run autotune optimization;
%   - Run longer simulation;
%   - Compatibilize simulation and collected data (downsampling);
%   - Generate plot (sprectrogram, FFT, limit-cycle, time-domain);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear all; close all hidden
load('26_Nov_2018_08_43_40_A0075_F50_ControllerDiscrete.mat')

%% Gathering collected data from a specific patient.
[PatientRawSignals] = ImportPatientData();

%% Preprocessing patient signal
[PatientConditionedSignals] = PatientSignalConditioning(PatientRawSignals);

%% Extracting patient signal features to tune tremor model and generating a log file
[OscillatorParam, CostParam]=PatientFeatureExtraction(PatientConditionedSignals);



%% Model Tuning
OptimizationAlgorithm.technique='ga';
%OptimizationAlgorithm.technique='patternsearch';

SimuInfo.Tend=2.5;
SimuInfo.Ts=0.001;
SimuInfo.opt=0;
SimuInfo.Setpoint=[0,70];
SimuInfo.p=OscillatorParam.P;
Kz=c2d(K,SimuInfo.Ts);
SimuInfo.Kz=Kz;
SimuInfo.Saturation=1;

[SimuInfo]=BiomechModelTunning(OscillatorParam, CostParam, OptimizationAlgorithm,SimuInfo)


%% Simulation 60s


%% Control Synthesis for FES

%% Simulation with FES

%% Deliverables - Controller for embedding and simulation results


