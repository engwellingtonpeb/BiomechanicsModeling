function [sys,x0,str,ts,simStateCompliance] = osim_sfunc(t,x,u,flag)
%%%%%%%%%%%%%%%%%%Global declarations
    import org.opensim.modeling.*
    Pars.PhiRef=0;
    osimModel=Model('.\models\MoBL_ARMS_tutorial_33\MoBL-ARMS OpenSim tutorial_33\ModelFiles\MoBL_ARMS_module2_4_allmuscles.osim');
    osimState=osimModel.initSystem();
%%%%%%%%%%%%%%%%%%%%%%%%%
    switch flag
        case 0 
            [sys,x0,str,ts,simStateCompliance] = mdlInitializeSizes();
        case 1
            [sys] = mdlDerivatives(t,x,u,Pars);
        case {2,9}
            sys = [];
        case 3
            [sys] = mdlOutputs(t,x,u,Pars); 
        otherwise
            DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));
    end

    function [sys,x0,str,ts,simStateCompliance] = mdlInitializeSizes()
        %This routine configure and acesses opensim. 
         import org.opensim.modeling.*

        
        %Model elements identification
        Nstates       = osimModel.getNumStateVariables();
        Ncontrols     = osimModel.getNumControls();
        Ncoord        = osimModel.getNumCoordinates(); 
        Nbodies       = osimModel.getNumBodies();
        model_muscles = osimModel.getMuscles();
        Nmuscles      = model_muscles.getSize();
        
        
        sizes = simsizes;
        sizes.NumContStates  = Nstates;   % [jointangles activation length]
        sizes.NumDiscStates  = 0;
        sizes.NumOutputs     = Nstates;   % [jointangles activation length]
        sizes.NumInputs      = Ncontrols;   % [excitation to muscles]
        sizes.DirFeedthrough = 4;   %number of muscle excitations used
        sizes.NumSampleTimes = 1;
        
        
        
        % get model states
        states_all = cell(Nstates,1);
        for i = 1:Nstates
           states_all(i,1) = cell(osimModel.getStateVariableNames().getitem(i-1));
        end

        % get model muscles (controls)
        Muscles = osimModel.getMuscles();  
        controls_all = cell(Ncontrols,1);
        for i = 1:Ncontrols
           currentMuscle = Muscles.get(i-1);
           controls_all(i,1) = cell(currentMuscle.getName());
        end

        % get model coordinates
        Coord = osimModel.getCoordinateSet();
        Coord_all = cell(Ncoord,1);
        for i = 1:Ncoord
           currentCoord = Coord.get(i-1);
           Coord_all(i,1) = cell(currentCoord.getName());
        end


        % Setup Joint angles 
        editableCoordSet = osimModel.updCoordinateSet();
        editableCoordSet.get('elv_angle').setValue(osimState, 0);
        editableCoordSet.get('elv_angle').setLocked(osimState, true);

        editableCoordSet.get('shoulder_elv').setValue(osimState, 0);
        editableCoordSet.get('shoulder_elv').setLocked(osimState, true);

        editableCoordSet.get('shoulder_rot').setValue(osimState, 0);
        editableCoordSet.get('shoulder_rot').setLocked(osimState, true);

        editableCoordSet.get('pro_sup').setValue(osimState, deg2rad(90));
        editableCoordSet.get('pro_sup').setLocked(osimState, true);

        editableCoordSet.get('elbow_flexion').setValue(osimState, deg2rad(90));
        editableCoordSet.get('elbow_flexion').setLocked(osimState, true);
        
        editableCoordSet.get('deviation').setValue(osimState, 0);
        editableCoordSet.get('deviation').setLocked(osimState, true);


        editableCoordSet.get('flexion').setValue(osimState, deg2rad(-10));
        editableCoordSet.get('flexion').setLocked(osimState, false);


        osimState.getY.set(40,0); %zera ativacao inicial ECRL
        osimState.getY.set(42,0); %zera ativacao inicial ECRB
        osimState.getY.set(44,0); %zera ativacao inicial ECU
        osimState.getY.set(46,0); %zera ativacao inicial FCR
        osimState.getY.set(48,0); %zera ativacao inicial FCU
        osimState.getY.set(50,0); %zera ativacao inicial PQ
        osimState.getY.set(52,0); %zera ativacao inicial SUP

        osimModel.equilibrateMuscles(osimState); %solve for equilibrium similiar


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

        sys = simsizes(sizes);
        str = [];
        x0  = InitStates;                   % Initial conditions;
        ts  = [0 0];                % sample time: [periodo, offset]
        simStateCompliance = 'DefaultSimState';
    end

    function [sys] = mdlDerivatives(t,x,u,Pars)
         import org.opensim.modeling.*
    %% Par�metros
%             m = Pars.m;
%            cd = Pars.cd;
    %% Estados e controles
            %motionData=x(1:end);
%            s = x(1);
%            v = x(2);
%            f = u(1);
             Pars.u=u;
    %% ODE   
        

            
            [x_dot, controlValues] = OpenSimPlantFunction(t,x,osimModel,osimState,Pars);
            sys = x_dot;     
    end   

    function [sys] = mdlOutputs(t,x,u,Pars)
%         import org.opensim.modeling.*
    %% Par�metros
%             m = Pars.m;
%            cd = Pars.cd;
    %% Outputs 

%            s = x(1);
            
%            v = x(2);
%            f = u(1);                % Direct Feedthrough
%            a = (f - cd*v^2)/m; 
%            pot = f*v;

           sys = x(1:end);               % states update
    end 
end