    if t<=1
        phi_ref=deg2rad(SimuInfo.Setpoint(1));
        psi_ref=deg2rad(SimuInfo.Setpoint(2));
    end
    
    if t>1 && t<=3 
        phi_ref=deg2rad(-7);
        psi_ref=deg2rad(10);

    end
    
    if t>3 && t<=5
        phi_ref=deg2rad(5);
        psi_ref=deg2rad(10);
    end
    
    if t>5 && t<=7 
        phi_ref=deg2rad(0);
        psi_ref=deg2rad(25);
    end
    
    if t>7 && t<=9
        phi_ref=deg2rad(10);
        psi_ref=deg2rad(15);

    end
    
    if t>9 && t<=10
        phi_ref=deg2rad(-4);
        psi_ref=deg2rad(12);

    end
