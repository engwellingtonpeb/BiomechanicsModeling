%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 04/10/2023                                                       %
%  Last Update: DSc - Version 2.0                                         %
%-------------------------------------------------------------------------%                       
% OutputData = IntegrateOpenSimPlant(osimModel, controlsFuncHandle,...
%    timeSpan, integratorName, integratorOptions)
%
%   IntegrateOpenSimPlant is a function for integrating a
%   OpenSim model using one of Matlab's integrator routines.
%
% Input:
%   osimModel: An OpenSim Model object
%   controlsFuncHandle: an optional function handle which can be used to 
%       calculate the controls applied to actuators at each time step.
%   timeSpan: A row matrix of time ranges for the integrator. This can be
%       timeRange = [timeInitial timeFinal] or [t1, t2, t3 ... timeFinal].
%   integratorName: A char array of the specific integrator to use
%   integratorOptions: a set of integrator options generated with odeset
%   (for defaults, pass an empty array).
%
% Output:
%   The output of this script is a Matlab structure named OutputData. The
%   format of this structure can be passed to PlotOpenSimFunction.m for
%   plotting.
%
%   The stucture fields are:
%       name: A char array identifier of the data
%       nRows: the number of rows of data in the data field
%       nColumns: the number of columns of data in the data field
%       labels: an array of char arrays of data names from the header file
%       data: a nRows by nColumnss matrix of data values
%
% Usage:
% outputDataStructure = IntegrateOpenSimPlant(osimModel, osimState, ...
% timeSpan, integratorName, integratorOptions);
% -----------------------------------------------------------------------
function OutputData = IntegrateOsimPlant(osimModel, integratorName, SimuInfo, integratorOptions)
    
    % Import Java libraries
    %import org.opensim.modeling.*;
    

    
%     if(~isa(osimModel, 'org.opensim.modeling.Model'))
%         error('IntegrateOpenSimPlant:InvalidArgument', [ ...
%             '\tError in IntegrateOpenSimPlant\n', ...
%             '\tArgument osimModel is not an org.opensim.modeling.Model.']);
%     end
%     if(~isempty(controlsFuncHandle))
%         if(~isa(controlsFuncHandle, 'function_handle'))
%             controlsFuncHandle = [];
%             disp('controlsFuncHandle was not a valid function_handle');
%             disp('No controls will be used.');
%         end
%     end

    % Check to see if model state is initialized by checking size
    if(osimModel.getWorkingState().getNY() == 0)
       osimState = osimModel.initSystem();
    else
       osimState = osimModel.updWorkingState(); 
    end

    % Create the Initial State matrix from the Opensim state
    numVar = osimState.getY().size();
    InitStates = zeros(numVar,1);
    for i = 0:1:numVar-1
        InitStates(i+1,1) = osimState.getY().get(i); 
    end

    % Create a anonymous handle to the OpenSim plant function.
    plantHandle = @(t,x) OsimPlantFcn(t, x, osimModel, osimState, SimuInfo);

    % Integrate the system equations
    integratorFunc = str2func(integratorName);
    



    if strcmp(integratorName,'ode113')
        [T,Y] = integratorFunc(plantHandle, [0, SimuInfo.Tend], InitStates, integratorOptions);%,
    else
        [Y] = integratorFunc(plantHandle, SimuInfo.timeSpan, InitStates);
        T=SimuInfo.timeSpan';
    end
    

    
   % Create Output Data structure
    OutputData = struct();
    OutputData.name = [char(osimModel.getName()), '_states'];
    OutputData.nRows = size(T, 1);
    OutputData.nColumns = size(T, 2) + size(Y, 2);
    OutputData.inDegrees = false;
    OutputData.labels = cell(1,OutputData.nColumns); 
    OutputData.labels{1}= 'time';
    for j = 2:1:OutputData.nColumns
        OutputData.labels{j} = char(osimModel.getStateVariableNames().getitem(j-2));
    end
    
    OutputData.data = [T, Y];
    

end
