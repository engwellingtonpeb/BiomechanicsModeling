function J = CostFun(Gains)


Gains
SimuInfo.Tend=2;
SimuInfo.Ts=0.0002;
SimuInfo.opt=0;
SimuInfo.Gains=Gains;
SimuInfo.Setpoint=[0,70];


[motionData]=ForwardSimuControl(SimuInfo);
    
SimuInfo.ElapsedTime=toc


Phi=rad2deg(motionData.data(:,19));
Psi=rad2deg(motionData.data(:,17));

Phi_ref=SimuInfo.Setpoint(1)*ones(length(Phi),1);
Psi_ref=SimuInfo.Setpoint(2)*ones(length(Psi),1);

J1=(Phi_ref-Phi)'*(Phi_ref-Phi);
J2=(Psi_ref-Psi)'*(Psi_ref-Psi);

J=1e-6*J1+1e-5*J2


end

