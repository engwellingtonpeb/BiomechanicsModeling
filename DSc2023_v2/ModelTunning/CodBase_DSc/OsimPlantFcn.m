%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 04/10/2023                                                       %
%  Last Update: DSc - Version 2.0                                         %
%-------------------------------------------------------------------------%
% OsimPlantFcn
%   x_dot = OpenSimPlantFunction(t, x, controlsFuncHandle, osimModel, 
%   osimState) converts an OpenSimModel and an OpenSimState into a 
%   function which can be passed as a input to a Matlab integrator, such as
%   ode45, or an optimization routine, such as fmin.
%
% Input:
%   t is the time at the current step
%   x is a Matlab column matrix of state values at the current step
%   controlsFuncHandle is a handle to a function which computes thecontrol
%   vector
%   osimModel is an org.opensim.Modeling.Model object 
%   osimState is an org.opensim.Modeling.State object
%
% Output:
%   x_dot is a Matlab column matrix of the derivative of the state values
% ----------------------------------------------------------------------- 
function [x_dot] = OsimPlantFcn(t, x, osimModel, osimState,SimuInfo)


    % Update state with current values  
    osimState.setTime(t);
    numVar = SimuInfo.Nstates;
    UpdVar=osimState.updY();
    for i = 0:1:numVar-1
        UpdVar.set(i, x(i+1,1));
    end
    

    %Update the derivative calculations in the State Variable
    osimModel.computeStateVariableDerivatives(osimState);


    % Update model with control values
    SimuInfo.Xk=x;
    u = OsimControlsFcn(osimModel,osimState,t,SimuInfo); %control effort
    osimModel.setControls(osimState, u);

   
    %Update the derivative calculations in the State Variable
    osimModel.computeStateVariableDerivatives(osimState);
    x_dot=osimState.getYDot().getAsMat();


end


