function plotOsim(t, phi_ref, psi_ref, phi, psi, u)



    subplot(3,1,1)
    plot(t,rad2deg(phi_ref),'go',t,rad2deg(phi),'r.')
    axis([t-3 t -15 25])
    drawnow;
    grid on;
    hold on;
    
    subplot(3,1,2)
    plot(t,rad2deg(psi_ref),'go',t,rad2deg(psi),'k.')
    axis([t-3 t 50 100])
    drawnow;
    grid on;
    hold on;
    
    subplot(3,1,3)
    plot(t,u(1),'b.',t,u(2),'r.')
    axis([t-3 t -1 1])
    drawnow;
    grid on;
    hold on;
% 
% %     subplot(4,1,3)
% %     plot(t,Y1(1,end),'b.',t,Y1(2,end),'r.')
% %     axis([t-3 t -2 2])
% %     drawnow;
% %     grid on;
% %     hold on;
% % 
% %     subplot(4,1,4)
% %     plot(t,u(3),'b.',t,u(4),'r.')
% %     axis([t-3 t -1 1])
% %     drawnow;
% %     grid on;
% %     hold on;
% % 
% %     subplot(4,1,4)
% %     plot(t,u(1),'b.',t,u(2),'r.')
% %     axis([t-3 t -1 1])
% %     drawnow;
% %     grid on;
% %     hold on;
% 
% % 




end