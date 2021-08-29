%OpenSimPlantFunction  
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
function [x_dot, controlValues] = OpenSimPlantFunction(t, x, osimModel, ...
    osimState,SimuInfo)
    % Error Checking
    import org.opensim.modeling.*
    if(~isa(osimModel, 'org.opensim.modeling.Model'))
        error('OpenSimPlantFunction:InvalidArgument', [...
            '\tError in OpenSimPlantFunction\n',...
            '\topensimModel is not type (org.opensim.modeling.Model).']);
    end
    if(~isa(osimState, 'org.opensim.modeling.State'))
        error('OpenSimPlantFunction:InvalidArgument', [...
            '\tError in OpenSimPlantFunction\n',...
            '\topensimState is not type (org.opensim.modeling.State).']);
    end
    if(size(x,2) ~= 1)
        error('OpenSimPlantFunction:InvalidArgument', [...
            '\tError in OpenSimPlantFunction\n',...
            '\tThe argument x is not a column matrix.']);
    end
    if(size(x,1) ~= osimState.getY().size())
        error('OpenSimPlantFunction:InvalidArgument', [...
            '\tError in OpenSimPlantFunction\n',...
            '\tThe argument x is not the same size as the state vector.',...
            'It should have %d rows.'], osimState.getY().size());
    end
%     if(~isa(controlsFunc, 'function_handle'))
%        error('OpenSimPlantFunction:InvalidArgument', [...
%             '\tError in OpenSimPlantFunction\n',...
%             '\tcontrolsFunc is not a valid function handle.']); 
%     end
    
    % Check size of controls

    % Update state with current values  
    osimState.setTime(t);
    numVar = osimState.getNY();
    UpdVar=osimState.updY();
    for i = 0:1:numVar-1
        UpdVar.set(i, x(i+1,1));
    end
    
    %osimModel.getVisualizer().show(osimState);
    % Update the state velocity calculations
    osimModel.computeStateVariableDerivatives(osimState);
   
        
    % Update model with control values
    %if(isempty(controlsFuncHandle))
       controlVector = OpenSimPlantControlsFunction_control(osimModel,osimState,t,SimuInfo);
       osimModel.setControls(osimState, controlVector);
       for i = 1:osimModel.getNumControls()
           controlValues(1) = controlVector.get(i-1);
       end
    %end
%     
    % Update the derivative calculations in the State Variable
  
    osimModel.computeStateVariableDerivatives(osimState);
 
    
    x_dot = zeros(numVar,1);
    % Set output variable to new state
    derivatives=osimState.getYDot();
    for i = 0:1:numVar-1
        x_dot(i+1,1) = derivatives.get(i);
    
    end
    


end