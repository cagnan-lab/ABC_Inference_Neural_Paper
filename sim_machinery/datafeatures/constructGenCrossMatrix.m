function [F feat_out wflag meanconf] = constructGenCrossMatrix(dataS,chloc_name,chlist,fsamp,N,R)
if isempty(N)
    N = floor(fsamp/R.obs.csd.df);
end
if ~isfield(R.obs,'logscale')
    R.obs.logscale = 1;
end
wflag = 0;


% Construct NPD matrix from data - take mean across channel replicates
O = numel(R.condnames);
for C = 1:O
    % Compute the CrossSpectral Density for Everything
    [csdMaster,fMaster] = cpsd(dataS{C}',dataS{C}',hanning(256),[],256,256,'mimo');
    
    for chI = 1:size(chloc_name,2)
        for chJ = 1:size(chloc_name,2)
            if chI == chJ
                % Your Univariate Measure
                Pxy = squeeze(csdMaster(:,chJ,chI));
                F = fMaster;
                
                F_scale = R.frqz;
                
                if nargin>5
                    Pxy = interp1(F,Pxy,F_scale,'pchip');
                else
                    Pxy =  Pxy(F>4);
                end
                if R.obs.trans.logdetrend == 1
                    Pxy(Pxy<0) = 1e-32;
                    Pxy = log10(Pxy); F_scale = log10(F_scale);
                    [xCalc yCalc b Rsq] = linregress(F_scale',Pxy');
                    [dum bi] = intersect(F_scale,xCalc);
                    Pxy = Pxy(1,bi)-yCalc';
                    Pxy = 10.^Pxy; F_scale = 10.^(F_scale(bi));
                else
                    Pxy(isnan(F_scale)) = [];
                    F_scale(isnan(F_scale)) = [];
                end
                
                if R.obs.logscale == 1
                    Pxy = log10(Pxy);
                end
                if R.obs.trans.norm == 1
                    Pxy = (Pxy-nanmean(Pxy))./nanstd(Pxy);
                end
                
                if R.obs.trans.zerobase == 1
                    Pxy = Pxy - min(Pxy);
                end
                
                if R.obs.trans.gauss3 == 1
                    %                             Pxy = smoothdata(Pxy,'gaussian');
                    f = fit(F_scale',Pxy','gauss3');
                    Pxy = f(F_scale)';
                end
                
                if R.obs.trans.gausSm > 0
                    gwid = R.obs.trans.gausSm/diff(F_scale(1:2)); % 10 Hz smoothing
                    Pxy = smoothdata(Pxy,'gaussian',gwid);
                end
                Pxy(isnan(Pxy)) = 0;
                Pxy = Pxy; %.*tukeywin(length(Pxy),0.25)';
                
            elseif chI ~= chJ % Diagonal
                % Your Functional Connectivity Metric
                Pxy = squeeze(csdMaster(:,chJ,chI));
                F = fMaster;
                
                F_scale = R.frqz;
                F_scale(isnan(F_scale)) = [];
                if nargin>5
                    Pxy = interp1(F,Pxy,F_scale,'pchip');
                else
                    Pxy =  Pxy(F>4);
                end
                
                if R.obs.trans.norm == 1
                    Pxy = (Pxy-nanmean(Pxy))./nanstd(Pxy);
                    Pxy = Pxy - min(Pxy);
                end
                
                if R.obs.trans.gauss3 == 1
                    %                             Pxy = smoothdata(Pxy,'gaussian');
                    f = fit(F_scale',Pxy','gauss3');
                    Pxy = f(F_scale)';
                end
                if R.obs.trans.gausSm > 0
                    gwid = R.obs.trans.gausSm/diff(F_scale(1:2)); % 10 Hz smoothing
                    Pxy = smoothdata(Pxy,'lowess',gwid);
                end
                
            end
            xcsd(C,chJ,chI,1:4,:) = repmat(Pxy,4,1);
        end
    end
end

if R.obs.trans.normcat == 1
    % Normalize each component by concatanating the conditions
    for chI = 1:size(chloc_name,2)
        for chJ = 1:size(chloc_name,2)
            Xd = xcsd(:,chJ,chI,1:4,:); %here you select both conditions
            XM = mean(Xd(:));
            XV = std(Xd(:));
            xcsd(:,chJ,chI,1:4,:) = (Xd)./XV; % Rescale
        end
    end
end


feat_out = xcsd;
F = F_scale;
meanconf = [];
