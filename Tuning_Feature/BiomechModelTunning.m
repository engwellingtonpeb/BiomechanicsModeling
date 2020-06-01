function [SimuInfo]=BiomechModelTunning(OscillatorParam, CostParam, OptimizationAlgorithm,SimuInfo)
%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 24/12/2019                                                       %
%  Last Update: DSc - Version 1.0                                         %
%-------------------------------------------------------------------------%
% This function call runs rounds of forward dynamics simulations coupled  %
%with an optimization algorithm to tune model with patient extracted data %
%--------------------------------------------------------------------------

if (strcmp(OptimizationAlgorithm.technique,'ga'))
    
    Gains=[0.025 0.015 0.75 0.7]
    A=[];
    b=[];
    Aeq = [];
    beq = [];
    lb = [];
    ub = [];
    lb = [0 0 0 0];
    ub = [1.5 1.5 1.5 1.5];
    % ConstraintFunction = @gaConstrain;
    ConstraintFunction=[]
    % %options=[];
    rate=0.30;

    options = optimoptions(@ga,'CrossoverFraction',0.6,'Display','iter',...
        'FunctionTolerance',1e-2,'PopulationSize',24,'MaxGenerations',50,...
        'MutationFcn', {@mutationadaptfeasible,rate},'MaxStallGenerations',8,'OutputFcn',...
        @gaOutputFunc, 'UseParallel', true, 'CreationFcn',{@gacreationnonlinearfeasible},...
        'PlotFcn',{@gaplotscores,@gaplotbestf,@gaplotdistance},'ConstraintTolerance',1e-6,...
        'NonlinearConstraintAlgorithm','Penalty');

    nvars=4;
  
    [x,fval,exitflag,output,population,scores] = ga(@(Gains)CostFunction4TuningTremor(Gains,OscillatorParam,CostParam,SimuInfo),...
                                           nvars,A,b,Aeq,beq,lb,ub,ConstraintFunction,options)

    
    SimuInfo.GAresults=[x,fval,exitflag,output,population,scores];
    SimuInfo.Gains=x;

end

if (strcmp(OptimizationAlgorithm.technique,'patternsearch'))
   
    Gains=[0 0 0 0]
    A=[];
    b=[];
    Aeq = [];
    beq = [];
    lb = [];
    ub = [];
    lb = [0 0 0 0];
    ub = [1.5 1.5 1.5 1.5];
    % ConstraintFunction = @gaConstrain;
    ConstraintFunction=[]
    
    
     options = optimoptions('patternsearch','Display','iter','PlotFcn',{@psplotbestf,@psplotfuncount}, 'UseParallel',true);
    [x,fval,exitflag,output] = patternsearch(@(Gains)CostFunction4TuningTremor(Gains,OscillatorParam,CostParam,SimuInfo),...
                                           Gains,A,b,Aeq,beq,lb,ub,ConstraintFunction,options)
 
                                       
                                       
    SimuInfo.PSresults=[x,fval,exitflag,output];
    SimuInfo.Gains=x;
end
%%
% load history.mat
% figure
% for k=1:output.generations
%     sortedcost(:,k)=sort(cost(:,k));
%  end
% 
% imagesc((sortedcost(:,1:output.generations)))
% ll=colorbar;
% set(ll,'color','w')




end

