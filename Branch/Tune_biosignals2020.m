clc
clear all
close all hidden

%Initial Gain Guess
Gains=[0,0,0,0,0,0,0,0];

% A = [1 0 0 0 0 0 0 0;...
%      1 -1 0 0 0 0 0 0;...
%      0 0 -1 0 0 0 0 0;...
%      0 0 1 -1 0 0 0 0;...
%      0 0 0 0 -1 0 0 0;...
%      0 0 0 0 1 -1 0 0;...
%      0 0 0 0 0 0 1 0;...
%      0 0 0 0 0 0 1 -1];
% 
% A = [0 0 0 0 0 0 0 0;...
%      1 -1 0 0 0 0 0 0;...
%      0 0 0 0 0 0 0 0;...
%      0 0 1 -1 0 0 0 0;...
%      0 0 0 0 0 0 0 0;...
%      0 0 0 0 1 -1 0 0;...
%      0 0 0 0 0 0 0 0;...
%      0 0 0 0 0 0 1 -1];
% A=eye(8)
% b = [1,1,1,1,1,1,1,1]';
 A=[];
 b=[];
Aeq = [];
beq = [];
lb = [];
ub = [];
lb = [-.5,  0, 0,  0,  0,  0,    -.5 ,0 ];
ub = [0,    .5, .5,  .5,  .5,  .5,  0, .5];
ConstraintFunction = @gaConstrain;
%options=[];
rate=0.30;



%figure
options = optimoptions(@ga,'CrossoverFraction',0.6,'Display','iter',...
    'FunctionTolerance',1e-5,'PopulationSize',60,'MaxGenerations',30,...
    'MutationFcn', {@mutationadaptfeasible,rate},'MaxStallGenerations',15,'OutputFcn',...
    @gaOutputFunc, 'UseParallel', true, 'CreationFcn',{@gacreationnonlinearfeasible},...
    'PlotFcn',{@gaplotscores,@gaplotbestf,@gaplotdistance},'ConstraintTolerance',1e-6,...
    'NonlinearConstraintAlgorithm','Penalty')

%fun=@CostFun(Gains,filename);
% ConstraintFunction = @TuneConstraints
nvars=8;



date = datestr(datetime('now')); 
date=regexprep(date, '\s', '_');
date=strrep(date,':','_');
date=strrep(date,'-','_');
date=strcat(date,'_');
global filename
filename=strcat(date,'GA','.txt')


fid=fopen(filename, 'w');
fun=@CostFun;      

[x,fval,exitflag,output,population,scores] = ga(fun,nvars,A,b,Aeq,beq,lb,ub,ConstraintFunction,options)



%diplay results

%%
%load history.mat
figure
for k=1:output.generations
    sortedcost(:,k)=sort(cost(:,k));
 end

imagesc((sortedcost(:,1:output.generations)))
ll=colorbar;
set(ll,'color','w')
set(gcf,'Position',[100 100 600 300])