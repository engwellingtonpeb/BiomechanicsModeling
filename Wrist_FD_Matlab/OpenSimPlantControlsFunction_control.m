%Versão Final Wellington 07/02/2019
% ----------------------------------------------------------------------- 
%OpenSimPlantControlsFunction  
%   outVector = OpenSimPlantControlsFunction(osimModel, osimState)
%   This function computes a control vector which for the model's
%   actuators.  The current code is for use with the script
%   DesignMainStarterWithControls.m
%
% Input:
%   osimModel is an org.opensim.Modeling.Model object 
%   osimState is an org.opensim.Modeling.State object
%
% Output:
%   outVector is an org.opensim.Modeling.Vector of the control values
% -----------------------------------------------------------------------
function modelControls = OpenSimPlantControlsFunction_control(osimModel, osimState,t,SimuInfo)
    % Load Library
    import org.opensim.modeling.*;
    
    
    % Check Size
    if(osimModel.getNumControls() < 1)
       error('OpenSimPlantControlsFunction:InvalidControls', ...
           'This model has no controls.');
    end

    % Determine number of muscles/controls in the model
    muscles = osimModel.getMuscles(); 
    nMuscles = muscles.getSize();
    
    % Get a reference to current model controls
    modelControls = osimModel.updControls(osimState);
    
    % Initialize a vector for the actuator controls
    % Most actuators have a single control.  For example, muscle have a
    % signal control value (excitation);
    

    uECRL = Vector(1, 0.0);
    uFCU = Vector(1, 0.0);

    phi_ref=SimuInfo.PhiRef;
    phi=rad2deg(osimState.getY().get(17));
    %t
    %u=[0,0,0,0];
    
%% here goes all agent computing
    
    






    
%%
uECRL.set(0,SimuInfo.Action(1));
uFCU.set(0,SimuInfo.Action(2));

 
%% Update modelControls with the new values
    osimModel.updActuators().get('ECRL').addInControls(uECRL, modelControls);
    osimModel.updActuators().get('FCU').addInControls(uFCU, modelControls);


    
%     persistent j
% if (t==0)
%     j=0;
% else
% 
%   if (rem(j,10)==0)
% 
% 
%     subplot(2,1,1)
%     plot(t,phi_ref,'go',t,phi,'r.')
%     axis([t-3 t -20 30])
%     drawnow;
%     grid on;
%     hold on;
%     
%    
%     subplot(2,1,2)
%     plot(t,SimuInfo.Action(1),'b.',t,SimuInfo.Action(2),'r.')
%     axis([t-3 t -1 1])
%     drawnow;
%     grid on;
%     hold on;
% 
% 
% 
%   end
%  j=j+1;    
  
end