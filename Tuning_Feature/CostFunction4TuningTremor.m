function J = CostFunction4TuningTremor(Gains,OscillatorParam,CostParam,SimuInfo)


Gains
SimuInfo.Gains=Gains;

%% Patient Data
Phi_patient=CostParam.Phi_ref;%SimuInfo.Setpoint(1)*ones(length(Phi),1);
Phidot_patient=CostParam.Phidot_ref;
Psi_patient=CostParam.Psi_ref;%SimuInfo.Setpoint(2)*ones(length(Psi),1);
Psidot_patient=CostParam.Psidot_ref;




%% Simulation Data
[motionData]=ForwardSimuControl(SimuInfo);
SimuInfo.ElapsedTime=toc
t_simu=motionData.data(:,1);
Phi_simu=rad2deg(motionData.data(:,19));
Psi_simu=rad2deg(motionData.data(:,17));
Phidot_simu=rad2deg(motionData.data(:,39));
Psidot_simu=rad2deg(motionData.data(:,37));

%% Simulation Downsampling
[Phi_simu,t_new] = resample(Phi_simu,t_simu,CostParam.Fs_gyro);
[Psi_simu,t_new] = resample(Psi_simu,t_simu,CostParam.Fs_gyro);

Psi_simu=Psi_simu-mean(Psi_simu);

[Phidot_simu,t_new] = resample(Phidot_simu,t_simu,CostParam.Fs_gyro);
[Psidot_simu,t_new] = resample(Psidot_simu,t_simu,CostParam.Fs_gyro);

Nf=length(Phi_simu);
Ni=ceil(SimuInfo.Ni);

%% Cost for Tuning
alpha=1;
beta=1;
do_shuffle=0;
number_channels=1;



    if (sum(isnan(motionData.data(:)))~=0)
        J=1e6;
    else
        [KLest, Hest, KL_means, H_means, N]=kl_estimation(Phi_patient(Ni:Ni+Nf-1), Phi_simu, alpha, beta, do_shuffle, number_channels);
        J1=max(max(KLest,KL_means'));

        [KLest, Hest, KL_means, H_means, N]=kl_estimation(Psi_patient(Ni:Ni+Nf-1), Psi_simu, alpha, beta, do_shuffle, number_channels);
        J2=max(max(KLest,KL_means'));

        [KLest, Hest, KL_means, H_means, N]=kl_estimation(Phidot_patient(Ni:Ni+Nf-1), Phidot_simu, alpha, beta, do_shuffle, number_channels);
        J3=max(max(KLest,KL_means'));

        [KLest, Hest, KL_means, H_means, N]=kl_estimation(Psidot_patient(Ni:Ni+Nf-1), Psidot_simu, alpha, beta, do_shuffle, number_channels);
        J4=max(max(KLest,KL_means'));

        J=J1+J2+J3+J4
    end
    
    
    
    
end

