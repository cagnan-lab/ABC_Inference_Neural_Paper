function plotSweepSpectra(Hz,feat,featemp,cmap,legn,legsel,condsel,chsel)
if nargin<8
    chsel = 4;
end
j = 0;
for i = condsel
    j = j+1;
    if max(squeeze(feat{i}(1,4,4,1,:)))<1e-8; % If STN is over reasonable level
        a(i) = plot(Hz,squeeze(feat{i}(1,chsel(1),chsel(2),chsel(3),:)),'color',cmap(i,:),'LineWidth',2);
        %     a(i) = plot(Hz,squeeze(feat{i}(1,4,1,2,:)),'color',cmap(i,:),'LineWidth',2);
        hold on
        pind(j) = i;
    end
end
% a(i+1) = plot(Hz,2e-14.*squeeze(featemp(1,4,4,1,:)),'k:','LineWidth',2);

% a(legsel(2)).LineStyle = '--';
% legend(a(legsel),legn)
xlim([0 48])
xlabel('Frequency (Hz)')
ylabel('Amplitude (uV Hz^-1)')
title('Simulated STN Spectra')
box off
grid on