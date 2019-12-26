function J = CostFunction4TuningTremor(Gains,OscillatorParam,CostParam,SimuInfo)


Gains

%load('distrib_tremor.mat')
SimuInfo.Gains=Gains;

[motionData]=ForwardSimuControl(SimuInfo);
    
SimuInfo.ElapsedTime=toc


Phi=rad2deg(motionData.data(:,19));
Psi=rad2deg(motionData.data(:,17));

Phi_patient=CostParam.Phi_ref;%SimuInfo.Setpoint(1)*ones(length(Phi),1);
Phidot_patient=CostParam.Phidot_ref;
Psi_patient=CostParam.Psi_ref;%SimuInfo.Setpoint(2)*ones(length(Psi),1);
Psi_patient=CostParam.Psidot_ref;



J1=1e6;%(Phi_ref-Phi)'*(Phi_ref-Phi);
J2=1e5;%(Psi_ref-Psi)'*(Psi_ref-Psi);

J=1e-6*J1+1e-5*J2




end

