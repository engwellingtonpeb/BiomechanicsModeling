% ----------------------------------------------------------------------- 
% The OpenSim API is a toolkit for musculoskeletal modeling and           
% simulation. See http://opensim.stanford.edu and the NOTICE file         
% for more information. OpenSim is developed at Stanford University       
% and supported by the US National Institutes of Health (U54 GM072970,    
% R24 HD065690) and by DARPA through the Warrior Web program.             
%                                                                         
% Copyright (c) 2005-2013 Stanford University and the Authors             
% Author(s): Daniel A. Jacobs                                             
%                                                                         
% Licensed under the Apache License, Version 2.0 (the "License");         
% you may not use this file except in compliance with the License.        
% You may obtain a copy of the License at                                 
% http://www.apache.org/licenses/LICENSE-2.0.                             
%                                                                         
% Unless required by applicable law or agreed to in writing, software     
% distributed under the License is distributed on an "AS IS" BASIS,       
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         
% implied. See the License for the specific language governing            
% permissions and limitations under the License.                          
% ----------------------------------------------------------------------- 
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
function [x_dot, controlValues] = OpenSimPlantFunction(t, x,controlsFuncHandle, osimModel, ...
    osimState,SimuInfo)


    % Error Checking
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

    
    % Check size of controls

    % Update state with current values  
    osimState.setTime(t);
    numVar = osimState.getNY();
    UpdVar=osimState.updY();
    for i = 0:1:numVar-1
        UpdVar.set(i, x(i+1,1));
    end
    

    % Update the state velocity calculations
    osimModel.computeStateVariableDerivatives(osimState);
   
    
    

    
    % Update model with control values
    if(~isempty(controlsFuncHandle))
%        controlVector = controlsFuncHandle(osimModel,osimState,t,SimuInfo);


                       % Load Library
                %import org.opensim.modeling.*;
                
                
                % Check Size
                if(SimuInfo.Ncontrols < 1)
                   error('OpenSimPlantControlsFunction:InvalidControls', ...
                       'This model has no controls.');
                end
            
                % Determine number of muscles/controls in the model
                %muscles = osimModel.getMuscles(); 
               
                
                % Get a reference to current model controls
                controlVector = osimModel.updControls(osimState);
                %modelControls=[];
                % Initialize a vector for the actuator controls
                % Most actuators have a single control.  For example, muscle have a
                % signal control value (excitation);
                
            
            %     uECRL = Vector(1, 0.0);
            %     uFCU = Vector(1, 0.0);
            %     uPQ=Vector(1,0.0);
            %     uSUP=Vector(1,0.0);
            
            
            if ~rem (t,0.5)
                t
            end

                opt=SimuInfo.opt; %Parameter Parsing;
                uecrl=[];
                ufcu=[];
                upq=[];
                usup=[];
                Tcont=[];
            
                persistent ERR_POS
                persistent xk1
                persistent u
         
                
                
                
            %% %%%%%%%%%%%% MATSUOKA'S OSCILLATOR %%%%%%%%%
                global X
                global V
                global Y1
                
                
                persistent R
                persistent j1
                persistent phi_ref
                persistent psi_ref
                if (t==0)

                    %Condições iniciais do oscilador
                    j1=0;
                    Kf=2;
                    R=[Kf];

                    %Condições iniciais dos angulos de setpoint (ref)
                    phi_ref=deg2rad(10);
                    psi_ref=deg2rad(70);
                else
            
                    if (rem(j1,5000)==0)
                       %Variação da Frequência do tremor 
                       P=SimuInfo.P;
                       r=round(random(SimuInfo.pd,1,1));
                       Tosc=1/P(r);
                       Kf=(Tosc)/.1051;
                 
                       R=[Kf];
                       

                       phi_ref=deg2rad(10);
                       psi_ref=deg2rad(70);
                                 
                    end
                     j1=j1+1;
            
                end
            
                %% DISTRIBUTION ADJUST
                Kf=R;
                tau1=.1;
                tau2=.1;
                B=2.5;
                A=5;
                h=2.5;
                rosc=1;
            
            
                %dh=0.0001;
                dh=SimuInfo.Ts;
                s1=0;%osimModel.getMuscles().get('ECRL').getActivation(osimState); %activation
                s2=0;%osimModel.getMuscles().get('FCU').getActivation(osimState);%activation
            
                if (t==0)
                    x_osc=[normrnd(.5,0.25) normrnd(.5,0.25)]; %valor inicial [0,1]
                    v_osc=[normrnd(.5,0.25) normrnd(.5,0.25)];
                    X=[x_osc(1,1);x_osc(1,2)];
                    V=[v_osc(1,1);v_osc(1,2)];
                end
            
            
                %%euler p/ EDO
                x1=X(1,end)+dh*((1/(Kf*tau1))*((-X(1,end))-B*V(1,end)-h*max(X(2,end),0)+A*s1+rosc));
                y1=max(x1,0);
                v1=V(1,end)+dh*((1/(Kf*tau2))*(-V(1,end)+max(X(1,end),0)));
            
                x2= X(2,end)+dh*((1/(Kf*tau1))*((-X(2,end))-B*V(2,end)-h*max(X(1,end),0)-A*s2+rosc));
                y2=max(x2,0);
                v2=V(2,end)+dh*((1/(Kf*tau2))*(-V(2,end)+max(X(2,end),0)));
            
            
                X=[x1;x2];
                V=[v1;v2];
                Y1=[y1;y2];
            
            
                du_1=Y1(1,end);
                du_2=Y1(2,end);
            
             
            %% Plant control implementation 
            
            
            
            phi=osimState.getY().get(17); % wrist flexion angle (rad)
            % rad2deg(phi);
            %phi_storage=[phi_storage;rad2deg(phi)];
            
            
            psi=osimState.getY().get(15); % pro_sup angle (rad)
            %psi_storage=[psi_storage;rad2deg(psi)];
            
            err_pos=[phi_ref-phi ; psi_ref-psi];
            
            ERR_POS=[err_pos];
            
            
            %% Control Signal Generation    
            % UNICO CONTROLADOR
            
            Ak=SimuInfo.Ak;
            Bk=SimuInfo.Bk;
            Ck=SimuInfo.Ck;
            Dk=SimuInfo.Dk;
            
                if length(xk1)<(length(Ak))
                    xk1=zeros(length(Ak),1);
                end
            
            xplus=(Ak*xk1)+(Bk*ERR_POS);
            u=Ck*xk1+Dk*ERR_POS;
            xk1=xplus;
            
            %%
            u=[(u(1)) u(2) u(3) u(4)];
            %Ureal=[Ureal;u]; %guarda a saída do controlador s/ nenhuma alteração
            
            
            % %% GANHOS ADAPTATIVOS PARA ELIMINAR UM MÚSCULO COMO FUNÇÃO DO ERRO
            % 
            eps_phi=rad2deg(err_pos(1));
            eps_psi=rad2deg(err_pos(2));
            
            ALPHA1=((-0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5);
            ALPHA2=(0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5;
            
            ALPHA3=(0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+.5;
            ALPHA4=(-0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+0.5;
            
            
            
            
            %% INPUT CONTROLE
            
            % 
            if t<10
                u1=ALPHA1*(u(1)); %ECRL
                u2=ALPHA2*(0.1*u(2)); %FCU
                u3=ALPHA3*(u(3)); %PQ
                u4=ALPHA4*(0.5*u(4)); %SUP
            %     u1=ALPHA1*(1.5*u(1)); %ECRL
            %     u2=ALPHA2*(0.3*u(2)); %FCU
            %     u3=ALPHA3*(3*u(3)); %PQ
            %     u4=ALPHA4*(1*u(4)); %SUP
            
            
            else 
                
                u1=ALPHA1*(1*u(1)+.2*du_1); %ECRL
                u2=ALPHA2*(.1*u(2)+.2*du_2); %FCU
                u3=ALPHA3*(1*u(3)+.2*du_2); %PQ
                u4=ALPHA4*(.1*u(4)+.2*du_1); %SUP
                
                   
             end
            
            
            u=[u1 u2 u3 u4];
            
            
            
            % Actuators saturation (muscle excitation limits 0<=u<=1)
            for i=1:length(u)
                if u(i)>=1
                    u(i)=1;
                end
                
                if u(i)<0
                    u(i)=0;
                end
            end
            
            
               
            
            % 
            % uECRL.set(0,u(1));
            % uFCU.set(0,u(2));
            % uPQ.set(0,u(3));
            % uSUP.set(0,u(4));
             
            %% Update modelControls with the new values
            %     osimModel.updActuators().get('ECRL').addInControls(uECRL, modelControls);
            %     osimModel.updActuators().get('FCU').addInControls(uFCU, modelControls);
            %     osimModel.updActuators().get('PQ').addInControls(uPQ, modelControls);
            %     osimModel.updActuators().get('SUP').addInControls(uSUP, modelControls);
            
                osimModel.updControls(osimState).set(1,u1); %ECRL
                osimModel.updControls(osimState).set(5,u2); %FCU
                osimModel.updControls(osimState).set(6,u3); %PQ
                osimModel.updControls(osimState).set(0,u4); %SUP
            
                
persistent j
if (t==0)
    j=0;
else
    if (rem(j,1000)==0 && SimuInfo.osimplot==true)
    
        plotOsim(t, phi_ref, psi_ref, phi, psi, u)
    
   end
    j=j+1;
end


%     
    % Update the derivative calculations in the State Variable


       osimModel.setControls(osimState, controlVector);
       %for i = 1:osimModel.getNumControls()
       %    controlValues(1) = controlVector.get(i-1);
       %end

  
    osimModel.computeStateVariableDerivatives(osimState);
    x_dot=osimState.getYDot().getAsMat();

    


end