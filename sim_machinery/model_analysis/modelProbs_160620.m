function [permMod, xsimMod] = modelProbs_160620(x,m,p,R)
if ~isfield(R.analysis.BAA,'flag')
    R.analysis.BAA.flag = 0;
end
R.plot.flag= 1;

%% Compute KL Divergence
[KL DKL] = KLDiv(R,p,m,1);
R.Mfit.DKL = DKL;
N = R.analysis.modEvi.N;


%% Resample parameters
% Compute indices of parameters to be optimized
[pInd,pMu,pSig] = parOptInds_110817(R,p,m.m); % in structure form
% Form descriptives
pIndMap = spm_vec(pInd); % in flat form
pSigMap = spm_vec(pSig);
[par,MAP] = postDrawCopula(R,R.Mfit,p,pIndMap,pSigMap,N);

a = gcp;
ppm = ParforProgMon('Model Probability Calculation',N,1);
parforArg = a.NumWorkers;

%%
figure(5)
pnew = par{1};
u = innovate_timeseries(R,m);
[r2,pnew,feat_sim,xsims,xsims_gl,wflag] = computeSimData_160620(R,m,u,pnew,0,1);
wfstr = ones(1,N);
R.plot.flag= 0;

while wfstr(end)>0
    parfor (jj = 1:N, parforArg)
        %     parfor jj = 1:N
        pnew = par{jj};
        u = innovate_timeseries(R,m);
        [r2,pnew,feat_sim,xsims,xsims_gl,wflag] = computeSimData_160620(R,m,u,pnew,0);
        [ACC R2w] = computeObjective(R,r2)
        %     R.plot.outFeatFx({},{feat_sim},R.data.feat_xscale,R,1)
        wfstr(jj) = any(wflag);
        r2rep{jj} = r2;
        accrep{jj} = ACC;
        par_rep{jj} = pnew;
        feat_rep{jj} = feat_sim;
        disp(jj); %
        if ~R.analysis.BAA.flag
            ppm.increment();
            xsims_rep{jj} = [];
        else
            xsims_rep{jj} = xsims_gl;
        end
    end
    
    if ~R.analysis.BAA.flag
        wfstr(end) = 0;
    end
end
delete(ppm);
permMod.r2rep = [r2rep{:}];
permMod.par_rep = par_rep;
permMod.feat_rep = feat_rep;
permMod.DKL = DKL;
permMod.KL = KL;
permMod.ACCrep = [accrep{:}];
xsimMod = xsims_rep;
permMod.MAP = MAP;
[a b] = max([r2rep{:}]);
permMod.bestP = par_rep{b};


% Do some basic plotting
if ~R.analysis.BAA.flag
    % Temporary EPS
    eps = R.analysis.modEvi.eps; % temporary (calculated later from whole model family)
    
    figure
    r2bank = permMod.r2rep;
    [h r] = hist(r2bank,50); %D is your data and 140 is number of bins.
    h = h/sum(h); % normalize to unit length. Sum of h now will be 1.
    bar(h, 'DisplayName', 'Model NRMSE');
    xD = r(2:2:end);
    xL = 2:2:length(r); % list of indices
    set(gca,'XTick',xL)
    set(gca,'XTickLabel',strsplit(num2str(xD,2),' '))
    
    legend('show');
    ylabel('P(D-D*)'); xlabel('D-D*');
    hold on
    Yval = get(gca,'YLim');
    
    tmp = abs(xD-eps);
    [idx idx] = min(tmp); %index of closest value
    epsm = xL(xD==xD(idx)); %closest value
    
    plot([epsm epsm],Yval,'B--','linewidth',3)
    
    Pmod = numel(r2bank(r2bank>eps))/R.analysis.modEvi.N;
    annotation(gcf,'textbox',...
        [0.28 0.81 0.19 0.09],...
        'String',{sprintf('eps = %.2f',eps),sprintf('P(m|D) = %.2f',Pmod)},...
        'HorizontalAlignment','right',...
        'FitBoxToText','off',...
        'LineStyle','none');
    set(gcf,'Position',[680 437 1070 541])
    % saveallfiguresFIL_n([R.rootn 'outputs\' R.out.tag '\modelEvidence.jpg'],'-jpg',1,'-r200',1);
end
