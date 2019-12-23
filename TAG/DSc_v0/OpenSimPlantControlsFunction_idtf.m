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
function modelControls = OpenSimPlantControlsFunction02(osimModel, osimState,t,SimuInfo)
    % Load Library
    import org.opensim.modeling.*;
    
    
    % Check Size
    if(osimModel.getNumControls() < 1)
       error('OpenSimPlantControlsFunction:InvalidControls', ...
           'This model has no controls.');
    end
    
   % sys1
    % Determine number of muscles/controls in the model
    muscles = osimModel.getMuscles(); 
    nMuscles = muscles.getSize();
    
    % Get a reference to current model controls
    modelControls = osimModel.updControls(osimState);
    
    % Initialize a vector for the actuator controls
    % Most actuators have a single control.  For example, muscle have a
    % signal control value (excitation);
    
    uECRB = Vector(1, 0.0);% Vector(qtd de elementos, valor)
    uECRL = Vector(1, 0.0);
    uECU = Vector(1, 0.0);
    uFCR = Vector(1, 0.0);
    uFCU = Vector(1, 0.0);
    uPQ=Vector(1,0.0);
    
    t

    opt=SimuInfo.opt; %Parameter Parsing;
    
%% Read plant angles for feedback and avoid NaN 
    
    thetaflex=osimState.getY().get(17); %theta wrist flexion 
    rad2deg(thetaflex)
    A=SimuInfo.Amplitude;

global U
global F
global R

uecrl=[];
uecrb=[];
uecu=[];
ufcr=[];
ufcu=[];
upq=[];

Fecrl=[]; 
Fecrb=[]; 
Fecu =[];
Ffcr =[];
Ffcu =[];
Fpq=[];



%% GENERATE IDENTIFICATION DATASET
if (opt=='1')
     uECRL.set(0,0.075);
%     A=SimuInfo.Amplitude;
%     f=SimuInfo.Freq;
%     %N=SimuInfo.Noise;
% 
%     
% 
%         u1=A*(1+square(2*pi*f*t))
% 
% 
%         if t<.7
%             uECRL.set(0,u1);%%
%             uECRB.set(0,0);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,0);%%
%             uPQ.set(0,0);
%              
%             uecrl=[uecrl, u1];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, 0];
%             upq=[upq,0];
%         end
%         
%         
%         if t>=.7 && t<1
%             uECRL.set(0,0);
%             uECRB.set(0,0);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%  
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, 0];
%              upq=[upq,0];
%        end
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%  
%         if t>=1 && t<1.7
%             uECRL.set(0,0);
%             uECRB.set(0,u1);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%  
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, u1];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu,0];
%              upq=[upq,0];
%         end
%        
% 
%        
%         if t>=1.7 && t<2
%             uECRL.set(0,0);
%             uECRB.set(0,0);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%  
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, 0];
%              upq=[upq,0];
%        end
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
%         
%         if t>=2 && t<2.7
%             uECRL.set(0,0);
%             uECRB.set(0,0);
%             uECU.set(0,u1);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%        
%              uecrl=[uecrl, 0];
%              uecrb=[uecrb, 0];
%              uecu=[uecu, u1];
%             
%              ufcr=[ufcr, 0];
%              ufcu=[ufcu, 0];
%               upq=[upq,0];
%         end
%         
%         if t>=2.7 && t<3
%             uECRL.set(0,0);
%             uECRB.set(0,0);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%  
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, 0];
%              upq=[upq,0];
%        end
%         
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%         if t>=3 && t<3.7
%             uECRL.set(0,0);
%             uECRB.set(0,0)
%             uECU.set(0,0);
%             uFCR.set(0,u1);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%             
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, u1];
%             ufcu=[ufcu, 0];
%              upq=[upq,0];
%         end
% 
%         if t>=3.7 && t<4
%             uECRL.set(0,0);
%             uECRB.set(0,0);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%  
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, 0];
%              upq=[upq,0];
%        end
%         
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
%         if t>=4 && t<4.7
%             uECRL.set(0,0);
%             uECRB.set(0,0);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,u1);
%             uPQ.set(0,0);
%          
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, u1];
%              upq=[upq,0];
%         end
%         
%         if t>=4.7 && t<5
%             uECRL.set(0,0);
%             uECRB.set(0,0);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%  
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, 0];
%              upq=[upq,0];
%        end
%         
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        if t>=5 && t<5.7
%             uECRL.set(0,0);
%             uECRB.set(0,0);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,u1);
%          
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, 0];
%              upq=[upq,u1];
%         end
%         
%         if t>=5.7 && t<6
%             uECRL.set(0,0);
%             uECRB.set(0,0);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%  
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, 0];
%              upq=[upq,0];
%        end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%         if t>=6 && t<6.7
%             uECRL.set(0,u1);
%             uECRB.set(0,u1)
%             uECU.set(0,u1);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%             
%             uecrl=[uecrl, u1];
%             uecrb=[uecrb, u1];
%             uecu=[uecu, u1];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, 0];
%               upq=[upq,0];
%         end
%         
%         if t>=6.7 && t<7
%             uECRL.set(0,0);
%             uECRB.set(0,0);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%  
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, 0];
%              upq=[upq,0];
%        end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%         if t>=7 && t<7.7
%             uECRB.set(0,0); 
%             uECRL.set(0,0);
%             uECU.set(0,0);
%             
%             uFCR.set(0,u1);
%             uFCU.set(0,u1);
%             uPQ.set(0,0);
% 
%             
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu,0];
% 
%             
%             ufcr=[ufcr, u1];
%             ufcu=[ufcu, u1];
%               upq=[upq,0];
%         end
%         
%         if t>=7.7 && t<8
%             uECRL.set(0,0);
%             uECRB.set(0,0);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%  
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, 0];
%              upq=[upq,0];
%        end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%         if t>=8 && t<8.7
%             uFCR.set(0,u1);
%             uFCU.set(0,u1);
%             uECRB.set(0,u1); 
%             uECRL.set(0,u1);
%             uECU.set(0,u1);
%             uPQ.set(0,0);
%             
%             uecrl=[uecrl, u1];
%             uecrb=[uecrb, u1];
%             uecu=[uecu, u1];
%             
%             ufcr=[ufcr, u1];
%             ufcu=[ufcu, u1];
%               upq=[upq,0];
%         end
%         
%         if t>=8.7 && t<9
%             uECRL.set(0,0);
%             uECRB.set(0,0);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%  
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, 0];
%              upq=[upq,0];
%         end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        
%          if t>=9 && t<9.7
%             uFCR.set(0,u1);
%             uFCU.set(0,u1);
%             uECRB.set(0,u1); 
%             uECRL.set(0,u1);
%             uECU.set(0,u1);
%             uPQ.set(0,u1);
%             
%             uecrl=[uecrl, u1];
%             uecrb=[uecrb, u1];
%             uecu=[uecu, u1];
%             
%             ufcr=[ufcr, u1];
%             ufcu=[ufcu, u1];
%               upq=[upq,u1];
%         end
%         
%         if t>=9.7 && t<=10
%             uECRL.set(0,0);
%             uECRB.set(0,0);
%             uECU.set(0,0);
%             uFCR.set(0,0);
%             uFCU.set(0,0);
%             uPQ.set(0,0);
%  
%             uecrl=[uecrl, 0];
%             uecrb=[uecrb, 0];
%             uecu=[uecu, 0];
%             
%             ufcr=[ufcr, 0];
%             ufcu=[ufcu, 0];
%              upq=[upq,0];
%         end 
%         
end
%%    
if(opt=='21' | opt=='22' |opt=='23') % VALIDATION TEST#01
    A=SimuInfo.Amplitude;
    f=SimuInfo.Freq;
    N=SimuInfo.Noise;
    u1=awgn((A*(1+square(2*pi*f*t))),N)

                if t<1
            uECRL.set(0,u1);
            uECRB.set(0,0);
            uECU.set(0,0);
            uFCR.set(0,0);
            uFCU.set(0,0);
             
            uecrl=[uecrl, u1];
            uecrb=[uecrb, 0];
            uecu=[uecu, 0];
            
            ufcr=[ufcr, 0];
            ufcu=[ufcu, 0];
        end
        
        
        if t>=1 && t<2
            uECRL.set(0,0);
            uECRB.set(0,u1);
            uECU.set(0,0);
            uFCR.set(0,0);
            uFCU.set(0,0);
 
            uecrl=[uecrl, 0];
            uecrb=[uecrb, u1];
            uecu=[uecu, 0];
            
            ufcr=[ufcr, 0];
            ufcu=[ufcu, 0];
       end
          
        
        if t>=2 && t<3
            uECRL.set(0,0);
            uECRB.set(0,0);
            uECU.set(0,u1);
            uFCR.set(0,0);
            uFCU.set(0,0);
       
             uecrl=[uecrl, 0];
             uecrb=[uecrb, 0];
             uecu=[uecu, u1];
            
             ufcr=[ufcr, 0];
             ufcu=[ufcu, 0];
        end
        
        
        if t>=3 && t<4
            uECRL.set(0,0);
            uECRB.set(0,0)
            uECU.set(0,0);
            uFCR.set(0,u1);
            uFCU.set(0,0);
            
            uecrl=[uecrl, 0];
            uecrb=[uecrb, 0];
            uecu=[uecu, 0];
            
            ufcr=[ufcr, u1];
            ufcu=[ufcu, 0];
        end

        if t>=4 && t<5
            uECRL.set(0,0);
            uECRB.set(0,0);
            uECU.set(0,0);
            uFCR.set(0,0);
            uFCU.set(0,u1);
         
            uecrl=[uecrl, 0];
            uecrb=[uecrb, 0];
            uecu=[uecu, 0];
            
            ufcr=[ufcr, 0];
            ufcu=[ufcu, u1];
        end
        
        if t>=5 && t<6
            uECRB.set(0,u1); 
            uECRL.set(0,u1);
            uECU.set(0,u1);
            uFCR.set(0,0);
            uFCU.set(0,0);
            
            uecrl=[uecrl, u1];
            uecrb=[uecrb, u1];
            uecu=[uecu, u1];
            
            ufcr=[ufcr,0];
            ufcu=[ufcu,0];
            

        end
        
        if t>=6 && t<7
            uECRL.set(0,0);
            uECRB.set(0,0)
            uECU.set(0,0);
            uFCR.set(0,u1);
            uFCU.set(0,u1);
            
            uecrl=[uecrl, 0];
            uecrb=[uecrb, 0];
            uecu=[uecu, 0];
            
            ufcr=[ufcr, u1];
            ufcu=[ufcu, u1];
        end
        
        if t>=7 && t<10
            uFCR.set(0,u1);
            uFCU.set(0,u1);
            uECRB.set(0,u1); 
            uECRL.set(0,u1);
            uECU.set(0,u1);
            
            uecrl=[uecrl, u1];
            uecrb=[uecrb, u1];
            uecu=[uecu, u1];
            
            ufcr=[ufcr, u1];
            ufcu=[ufcu, u1];
        end

    
end


% if(opt=='24') % VALIDATION TEST#04
% end

%-------------------------------------------------------------------------%
% Como o integrador tem passo variável e retroage no tempo, isso compromete
% o controle. Uma vez que o controlador pega amostras de instantes de tempos 
% não sequenciais (t+Ts)
%-------------------------------------------------------------------------%

 %% Update modelControls with the new values
    osimModel.updActuators().get('ECRL').addInControls(uECRL, modelControls);
    osimModel.updActuators().get('ECRB').addInControls(uECRB, modelControls);
    osimModel.updActuators().get('ECU').addInControls(uECU, modelControls);
    osimModel.updActuators().get('FCR').addInControls(uFCR, modelControls);
    osimModel.updActuators().get('FCU').addInControls(uFCU, modelControls);
    osimModel.updActuators().get('PQ').addInControls(uPQ, modelControls);

    %Compute Forces
    Fecrl=[Fecrl,osimModel.getActuators().get('ECRL').getForce(osimState)];
    Fecrb=[Fecrb,osimModel.getActuators().get('ECRB').getForce(osimState)]; 
    Fecu=[Fecu,osimModel.getActuators().get('ECU').getForce(osimState)];
    Ffcr=[Ffcr,osimModel.getActuators().get('FCR').getForce(osimState)];
    Ffcu=[Ffcu,osimModel.getActuators().get('FCU').getForce(osimState)];
    Fpq=[Fpq,osimModel.getActuators().get('PQ').getForce(osimState)];
    
    %Compute Moment Arms
    editableCoordSet = osimModel.updCoordinateSet();
    r1f=osimModel.getMuscles().get('ECRL').computeMomentArm(osimState,editableCoordSet.get('flexion'));
    r2f=osimModel.getMuscles().get('ECRB').computeMomentArm(osimState,editableCoordSet.get('flexion'));
    r3f=osimModel.getMuscles().get('ECU').computeMomentArm(osimState,editableCoordSet.get('flexion'));
    r4f=osimModel.getMuscles().get('FCR').computeMomentArm(osimState,editableCoordSet.get('flexion'));
    r5f=osimModel.getMuscles().get('FCU').computeMomentArm(osimState,editableCoordSet.get('flexion'));
    
    r1p=osimModel.getMuscles().get('ECRL').computeMomentArm(osimState,editableCoordSet.get('pro_sup'));
    r2p=osimModel.getMuscles().get('ECRB').computeMomentArm(osimState,editableCoordSet.get('pro_sup'));
    r3p=osimModel.getMuscles().get('ECU').computeMomentArm(osimState,editableCoordSet.get('pro_sup'));
    r4p=osimModel.getMuscles().get('FCR').computeMomentArm(osimState,editableCoordSet.get('pro_sup'));
    r5p=osimModel.getMuscles().get('FCU').computeMomentArm(osimState,editableCoordSet.get('pro_sup'));
    
    r=[r1f,r2f,r3f,r4f,r5f,r1p,r2p,r3p,r4p,r5p];
    R=[R;r];
    
    f=[Fecrl,Fecrb,Fecu,Ffcr,Ffcu,Fpq];
    F=[F;f];
    
    u=[uecrl,uecrb,uecu,ufcr,ufcu,upq];
    U=[U;u];

end