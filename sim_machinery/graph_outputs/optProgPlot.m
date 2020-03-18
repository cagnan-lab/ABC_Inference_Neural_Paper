function [] = optProgPlot(Tm,tbr2,p,r2bank,eps_rec,bestr2,pInd,pSig,R)

subplot(2,2,1)
plot(Tm,tbr2)
%     xlim([-R.SimAn.Tm-0.02 -0.25])
hold on
for i = 1:size(Tm,2)
    bplot(r2bank{i}(end,:),Tm(i),'width',0.01);
    r2med(i) = median(r2bank{i});
end

if size(Tm,2)>=10
    disp('You need to find the logisticfit tools!')
%     [Tm,r2med] = remnan(Tm,r2med);
%     lfit = logisticfit(Tm',r2med',[-0.5 -5 1.5 2]);
%     plot(Tm',lfit(Tm'))
%     lfit = logfit(Tm',r2med',[1 1]);
%     plot(Tm',lfit(Tm'))
end
ylim([-1 1])
axis square
subplot(2,2,2)
hold on
plot(Tm,eps_rec,'r','LineWidth',3)
plot(Tm,bestr2,'b','LineWidth',3)
axis square

subplot(2,1,2)
par = full(spm_vec(p));
parMu = par(spm_vec(pInd));
bar(parMu)
hold on
parSig = par(spm_vec(pSig));
errorbar(1:size(parSig,1),parMu,parSig,'.')
%     ylim([1.2*min(par) 1.2*max(par)]);
xlim([0 length(parMu)])
ylim([R.SimAn.pOptBound.*0.25])
xlabel('parameter')
ylabel('Posterior')
