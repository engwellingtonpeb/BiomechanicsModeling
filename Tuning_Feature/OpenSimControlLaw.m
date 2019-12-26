function [u,ALPHA] = OpenSimControlLaw(t,SimuInfo,ERR_POS)
%-------------------------------------------------------------------------%
%                  Federal University of Rio de Janeiro                   %
%                 Biomedical Engineering Program - COPPE                  %
%                                                                         %
%  Author: Wellington Cássio Pinheiro, MSc.                               %
%  Advisor: Luciano Luporini Menegaldo                                    %         
%  Date: 24/12/2019                                                       %
%  Last Update: DSc - Version 1.0                                                      %
%-------------------------------------------------------------------------%
persistent xk1


[Ak,Bk,Ck,Dk]=ssdata(SimuInfo.Kz);

    if length(xk1)<(length(Ak))
        xk1=zeros(length(Ak),1);
    end

xplus=(Ak*xk1)+(Bk*ERR_POS);
u=Ck*xk1+Dk*ERR_POS;
xk1=xplus;

%%
u=[u(1) u(2) u(3) u(4)];


%% GANHOS ADAPTATIVOS PARA ELIMINAR UM MÚSCULO COMO FUNÇÃO DO ERRO

eps_phi=rad2deg(err_pos(1));
eps_psi=rad2deg(err_pos(2));

ALPHA1=((-0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5);
ALPHA2=(0.5*((exp(eps_phi)-exp(-eps_phi))/((exp(eps_phi))+exp(-eps_phi))))+0.5;

ALPHA3=(0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+.5;
ALPHA4=(-0.5*((exp(eps_psi)-exp(-eps_psi))/((exp(eps_psi))+exp(-eps_psi))))+0.5;

ALPHA=[ALPHA1 ALPHA2 ALPHA3 ALPHA4];
%[du_1,du_2] = oscillator(SimuInfo,t);
% INPUT CONTROLE

%  if t<1 
%     u1=ALPHA1*(SimuInfo.Gains(1)*u(1)); %ECRL
%     u2=ALPHA2*(SimuInfo.Gains(2)*u(2)); %FCU
%     u3=ALPHA3*(SimuInfo.Gains(3)*u(3)); %PQ
%     u4=ALPHA4*(SimuInfo.Gains(4)*u(4)); %SUP
%  
%  else 
%      
%     u1=ALPHA1*(SimuInfo.Gains(1)*u(1)+.025*du_1); %ECRL
%     u2=ALPHA2*(SimuInfo.Gains(2)*u(2)+.015*du_2); %FCU
%     u3=ALPHA3*(SimuInfo.Gains(3)*u(3)+0.75*du_1); %PQ
%     u4=ALPHA4*(SimuInfo.Gains(4)*u(4)+0.7*du_2); %SUP
%     
%     u1=ALPHA1*0.1*du_1; %ECRL
%     u2=ALPHA1*0.1*du_2; %FCU
%     u3=ALPHA1*0.1*du_1; %PQ 
%     u4=ALPHA1*0.1*du_2; %SUP
%     
% end
% 
% 
% u=[u1 u2 u3 u4];
% 
% %Actuators saturation (muscle excitation limits 0<=u<=1)
% 
%     if SimuInfo.Saturation=='1'
%         for i=1:length(u)
%             if u(i)>=1
%                 u(i)=1;
%             end
% 
%             if u(i)<0
%                 u(i)=0;
%             end
%         end
%     end
% 




end

