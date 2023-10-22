    if t<=1
        phi_ref=deg2rad(SimuInfo.Setpoint(1));
        psi_ref=deg2rad(SimuInfo.Setpoint(2));


    end
    
    if t>1 && t<=3 
        phi_ref=deg2rad(10);
        psi_ref=deg2rad(20);

        
    end
    
    if t>3 && t<=5
        phi_ref=deg2rad(-10);
        psi_ref=deg2rad(20);

    end
    
    if t>5 && t<=7 
        phi_ref=deg2rad(0);
        psi_ref=deg2rad(20);
        
    end
    
    if t>7 && t<=9
        phi_ref=deg2rad(0);
        psi_ref=deg2rad(30);

    end
    
    if t>9 && t<=11
        phi_ref=deg2rad(0);
        psi_ref=deg2rad(10);

    end


    if t>11 && t<=13 
        phi_ref=deg2rad(5);
        psi_ref=deg2rad(30);
        
        
    end
    
    if t>13 && t<=15
        phi_ref=deg2rad(10);
        psi_ref=deg2rad(10);

    end
    
    if t>15 && t<=17 
        phi_ref=deg2rad(-5);
        psi_ref=deg2rad(30);

    end
    
    if t>17 && t<=19
        phi_ref=deg2rad(-10);
        psi_ref=deg2rad(10);
    end
    
    if t>19 && t<=21
        phi_ref=deg2rad(0);%%%*
        psi_ref=deg2rad(20);

    end

        if t>21 && t<=23 
        phi_ref=deg2rad(-5);
        psi_ref=deg2rad(30);

    end
    
    if t>23 && t<=25
        phi_ref=deg2rad(-10);
        psi_ref=deg2rad(10);
    end