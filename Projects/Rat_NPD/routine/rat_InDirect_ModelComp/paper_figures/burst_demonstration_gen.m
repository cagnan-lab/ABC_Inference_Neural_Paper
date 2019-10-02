clear; close all
R = ABCAddPaths('Rat_NPD','rat_InDirect_ModelComp');
R.projectn = 'Rat_NPD';
R.out.tag = 'rat_InDirect_ModelComp'; % Task tag
R = simannealsetup_InDirect_ModelComp(R);
cmap =brewermap(3,'Set1');

xsets = {[35 37],[35 37],[64 66]};
for srcgen = 1:3
    if srcgen == 1 % Random Noise
        data{1} = randn(4,506001);
        fsamp = 1/R.IntP.dt;
        time = linspace(0,size(data{1},2)/fsamp,size(data{1},2));
    elseif srcgen == 2
        load('C:\Users\timot\Documents\GitHub\SimAnneal_NeuroModel\Projects\Rat_NPD\data\EmpiricalRecordings\L21_lesion_rat_020317.mat')
        data{1} = FTdata.trial{1}([1 14 5 18],:);
        fsamp = FTdata.fsample;
        time = FTdata.time{1};
    elseif srcgen == 3
        load('C:\Users\timot\Documents\GitHub\SimAnneal_NeuroModel\Projects\Rat_NPD\routine\InDrt_ModCompRev2\BetaBurstAnalysis\Data\BB_InDrt_ModCompRev2_ConnectionSweep_CON_1_xsim.mat')
        data{1} = xsim{6}{1}(1:4,:);
        fsamp = 1/R.IntP.dt;
        time = linspace(0,size(data{1},2)/fsamp,size(data{1},2));
    end
    
    data{1} =  (data{1}-mean(data{1},2))./std(data{1},[],2);
    
    % CK [0.00001 0.125 0.25 0.5 0.75 1 1.25  1.5 3 5];
    figure(1)
    ax(1) = subplot(3,3,srcgen);
    a(1,:) = plot(time,data{1}-cumsum(repmat(6,size(data{1},1),1))); hold on
    % ylim([-3.2e-5 -0.3e-5])
    
    BPdata = bandpass(data{1}',[4 48],fsamp)';
    BPdata = (BPdata-mean(BPdata,2))./std(BPdata,[],2);
    ax(2) = subplot(3,3,srcgen+3);
    a(2,:) = plot(time,BPdata-cumsum(repmat(6,size(data{1},1),1))); hold on
    
    BPdata = bandpass(data{1}',[14 30],fsamp)';
    Hdata = abs(hilbert(BPdata')');
    
    ax(3) = subplot(3,3,srcgen+6);
    a(3,:) = plot(time,BPdata-cumsum(repmat(2,size(data{1},1),1))); hold on
    a(4,:) = plot(time,Hdata-cumsum(repmat(2,size(data{1},1),1)));
    % ylim([-1.3e-5 -1e-6])
    
    for i = 1:size(data{1},1)
        set(a(:,i),'Color',cmap(srcgen,:),'LineWidth',2)
    end
    
    linkaxes(ax,'x'); xlim(xsets{srcgen})
    legend({'MMC'  'STR'  'GPE'  'STN'} )
    set(gcf,'Position',[1121          34         573         924])
    % Statistics of Envelope
    Env = Hdata(4,:);
    
    BB = [];
    BB.AEnv{1} = Env; BB.guide = {}; BB.Tvec{1} = time;
    BB.epsAmp = prctile(Env,75); 
    BB.powfrq = 19; 
    BB.fsamp = 1/(time(2)-time(1));
    R.condname  = {''};
    R.BB.minBBlength = 1.5;
    R.BB.pairInd = [1 1];
    BB = defineBetaEvents(R,BB,0,0);
    BB.segAmp{1} = (BB.segAmp{1}-min(BB.segAmp{1}))./(max(BB.segAmp{1})-min(BB.segAmp{1}));
    
    
    figure(2)
    subplot(1,2,1)
    grid on
    box off
    spt = linspace(0,1,25); %logspace(log10(0.1),log10(1),25);
    [h e] = histcounts(BB.segAmp{1},spt,'Normalization','count');
    h = (h./time(end)).*60;
    lgnfit = fittype('sx.*(exp(-0.5*((log(x)-mu)./sigma).^2)./(x.*sqrt(2*pi).*sigma))',...
        'independent',{'x'},...
        'dependent',{'y'},...
        'coefficients',{'mu','sigma','sx'});
   f =  fit(binEdge2Mid(e)',(h)',lgnfit,'lower',[-1 0.01 0.1],'upper',[5 5 100],'StartPoint',[-0.5 0.25 1.5]);
    spt = linspace(0,1,100); % logspace(log10(0.1),log10(1),100);
    p = plot(spt,f(spt)); hold on 
    p.Color = cmap(srcgen,:);
    p.LineWidth = 1.5;
    sc = scatter(binEdge2Mid(e),(h),'filled');
    sc.MarkerFaceColor = cmap(srcgen,:);
    sc.MarkerFaceAlpha = 0.8;
    xlabel('Burst Amplitude (a.u.)'); ylabel('Occurence Rate (min^-1)'); xlim([0.25 1])
    
    subplot(1,2,2)
    grid on
    box off
    spt = linspace(0,500,25);
    [h e] = histcounts(BB.segDur{1},spt,'Normalization','count');
    h = (h./time(end)).*60;
   f =  fit(binEdge2Mid(e)',(h)',lgnfit,'lower',[1.5 0.01 0.1],'upper',[10 5 5e3],'StartPoint',[4 0.25 500]);
    spt = linspace(0,500,100); %logspace(log10(20),log10(500),100);
    p = plot(spt,f(spt)); hold on 
    p.Color = cmap(srcgen,:);
        p.LineWidth = 1.5;

    sc = scatter(binEdge2Mid(e),(h),'filled');
    sc.MarkerFaceColor = cmap(srcgen,:);
    sc.MarkerFaceAlpha = 0.8;
    xlabel('Burst Duration (ms)'); ylabel('Occurence Rate (min^-1)'); xlim([0 450]);

    y = slideWindow(Env,floor(5.*fsamp),0);
    y(:,end) = [];
    
    for i = 1:size(y,2)
        X = y(:,i);
        X = X./std(X);
        F_factor(i) = var(X)/mean(X);
    end
    disp([mean(F_factor) std(F_factor)]);
end


set(figure(1),'Position',[21          34        1076         924])
set(figure(2),'Position',[21          34        1076         377])