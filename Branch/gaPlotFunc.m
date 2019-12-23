function gaPlotFunc(Generation,costs)
figure(2000)
plot(Generation, costs(:,Generation+1),'k*');
% ll=colorbar;
% set(ll,'color','w')
    drawnow;
    grid on;
    hold on;
end

