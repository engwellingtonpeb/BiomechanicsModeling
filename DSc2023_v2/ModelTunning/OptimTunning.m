%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo, DSc.                              %         
%  Date: 15/10/2023                                                       %
%  Last Update:                                                           %
% DSc - Version 2.0                                                       %
%-------------------------------------------------------------------------%
%   GA optimization to                                                    %
%                     Hinf sinthesis                                      %
%                                                                         %
%------------------------------------------------------------------------ %

clc
clear
close all hidden

import org.opensim.modeling.*

%Initial Gain Guess
ModelParams=[0.5 0.5 0.5 0.5 0.5 0.5   2.5 2.5 1 .1    0 0 0 0 0 0 0 0  .1];
nvars=length(ModelParams);

% ModelParams = [x1-x6] -  Hinf controller synthesis
% ModelParams = [x7-x10] - [B  h   rosc    tau1] params matsuoka's oscillator
% ModelParams = [x11-x18] - flags ON/OFF oscillator channel aading to
% control signal
% ModelParams = [x19] - [tau2]


A=[];

b=[];

Aeq = [];
beq = [];

lb = [0.01 0.01 0.01 0.01 0.01 0.01   0.01 0.01 0.01 0.05   0 0 0 0 0 0 0 0  0.05];
ub = [  1    1     1    1    1   1     5     5   2   .5      1 1 1 1 1 1 1 1   0.5];

intcon=[11 12 13 14 15 16 17 18];

ConstraintFunction = @gaConstrain;
rate=0.30;

options = optimoptions(@ga,'CrossoverFraction',0.6,'Display','iter',...
    'FunctionTolerance',1e-5,'PopulationSize',50,'MaxGenerations',300,...
    'MutationFcn', {@mutationadaptfeasible,rate},'MaxStallGenerations',15,'OutputFcn',...
    @gaOutputFunc, 'UseParallel', true, 'CreationFcn',{@gacreationnonlinearfeasible},...
    'PlotFcn',{@gaplotscores,@gaplotbestf,@gaplotdistance},'ConstraintTolerance',1e-6,...
    'NonlinearConstraintAlgorithm','Penalty')



date = datestr(datetime('now')); 
date=regexprep(date, '\s', '_');
date=strrep(date,':','_');
date=strrep(date,'-','_');
date=strcat(date,'_');
global filename
filename=strcat(date,'GA','.txt')


fid=fopen(filename, 'w');



fun=@CostFcn;      

[x,fval,exitflag,output,population,scores] = ga(fun,nvars,A,b,Aeq,beq,lb,ub,ConstraintFunction,intcon,options)



%Salvar resultados da simulaçao, controlador, parametros usados e fcusto.